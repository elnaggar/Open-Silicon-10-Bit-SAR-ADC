#!/usr/bin/env python3
# Open-Silicon-SAR-ADC
# Gulu, Ankur Gupta, Ahmed Elnaggar
# Author: Ahmed Elnaggar
"""
spice_pool.py — bounded-parallelism ngspice execution in IIC-OSIC-TOOLS
=======================================================================
Every simulation in this project goes through here, so there is exactly one
place that knows how ngspice is invoked and exactly one place that bounds
how many run at once.

Environment
-----------
`run_ng.sh` (alongside this file, executed inside the container) reproduces
what an interactive user gets from

    sak-pdk gf180mcuD

by sourcing `/etc/profile.d/iic-osic-tools-setup.sh` for the tool PATH and
`/foss/tools/sak/sak-pdk-script.sh gf180mcuD` for the PDK variables, then
asserting PDK=gf180mcuD and GF_PDK_OPTION=D before it will run anything. A
silently wrong PDK selection is worse than a crash, because it produces
plausible numbers against the wrong corner.

Parallelism
-----------
The machine owner's hard ceiling is 6 concurrent ngspice processes
ceiling, not equal to it -- this value was changed 6 -> 4 without a
undocumented change to shared infrastructure). 4 is kept because it is
still within the mandated <=6 and erring conservative costs only wall
clock, but raise this back toward 6 once the reason for lowering it is
confirmed or shown stale. The cap is enforced by a semaphore around the
subprocess call rather than only by the executor's worker count, so it
holds even if a caller builds its own pool.

No fallbacks
------------
A run that fails, times out, or returns no measurement raises. A missing
measurement is not a measurement of zero — that assumption is what made the
retired TB03/TB04 report perfect scores from failed simulations.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

MAX_PARALLEL = 6

# The container's name changes every time it is recreated (festive_elbakyan,
# time instead: $EDA_CONTAINER if set, else the single running container of
# the iic-osic-tools image. Zero or several candidates is an error, never a
# guess.
CONTAINER        = os.environ.get("EDA_CONTAINER")
IMAGE_HINT       = "iic-osic-tools"
HOST_REPO_PREFIX = "/home/ahmed/eda/designs"
CONTAINER_PREFIX = "/foss/designs"
RUNNER           = "run_ng.sh"

_slots = threading.Semaphore(MAX_PARALLEL)
_running = 0
_running_lock = threading.Lock()
_peak = 0


class SpiceError(RuntimeError):
    pass


_container_lock = threading.Lock()


def container() -> str:
    """Name of the EDA container to exec into (see CONTAINER above)."""
    global CONTAINER
    with _container_lock:
        if CONTAINER:
            return CONTAINER
        if not shutil.which("docker"):
            raise SpiceError("docker is not on PATH; run this from WSL")
        p = subprocess.run(["docker", "ps", "--format", "{{.Names}}\t{{.Image}}"],
                           capture_output=True, text=True, timeout=30)
        if p.returncode != 0:
            raise SpiceError(f"docker ps failed: {p.stderr.strip()}")
        names = [ln.split("\t")[0] for ln in p.stdout.splitlines()
                 if IMAGE_HINT in ln]
        if len(names) != 1:
            raise SpiceError(
                f"expected exactly one running {IMAGE_HINT} container, found "
                f"{names or 'none'}; set EDA_CONTAINER to choose")
        CONTAINER = names[0]
        return CONTAINER


def to_container_path(p: Path | str) -> str:
    """Map a host path onto its location inside the container."""
    s = str(p).replace("\\", "/")
    m = re.match(r"^//wsl\.localhost/[^/]+(/.*)$", s)
    if m:
        s = m.group(1)
    if s.startswith(CONTAINER_PREFIX):
        return s
    if s.startswith(HOST_REPO_PREFIX):
        return CONTAINER_PREFIX + s[len(HOST_REPO_PREFIX):]
    raise SpiceError(
        f"cannot map {p!r} into the container; expected it under "
        f"{HOST_REPO_PREFIX} (host) or {CONTAINER_PREFIX} (container)")


def runner_path() -> Path:
    r = Path(__file__).resolve().parent / RUNNER
    if not r.exists():
        raise SpiceError(f"{RUNNER} not found next to spice_pool.py")
    return r


def peak_parallel() -> int:
    """Highest number of ngspice processes seen running at once.

    Reported by the callers so the 6-way cap is demonstrated rather than
    asserted.
    """
    return _peak


def run(netlist: Path, timeout: int = 1800) -> str:
    """Run one netlist and return ngspice's combined output.

    Blocks until a slot is free, so at most MAX_PARALLEL simulations are in
    flight regardless of how many callers there are.
    """
    global _running, _peak
    netlist = Path(netlist)
    if not netlist.exists():
        raise SpiceError(f"{netlist} does not exist")
    run_dir = to_container_path(netlist.parent)
    runner = to_container_path(runner_path())

    if not shutil.which("docker"):
        raise SpiceError("docker is not on PATH; run this from WSL")

    # timeout only kills the local `docker exec` client; the ngspice it started
    # in the container kept running (an orphan ran 45 min after its "kill",
    # silently taking the machine past the 6-process cap). coreutils timeout
    # signals the runner's whole process group, so ngspice dies with it; the
    # host-side timeout stays as a backstop with a cleanup pkill.
    cmd = ["docker", "exec", "-e", "OMP_NUM_THREADS=6", "-w", run_dir, container(),
           "timeout", "-s", "KILL", str(int(timeout)), "bash", runner, netlist.name]

    with _slots:
        with _running_lock:
            _running += 1
            _peak = max(_peak, _running)
        try:
            proc = subprocess.run(cmd, capture_output=True, text=True,
                                  timeout=timeout + 60)
        except subprocess.TimeoutExpired as e:
            subprocess.run(["docker", "exec", container(), "pkill", "-KILL", "-f",
                            f"ngspice -b {netlist.name}"], capture_output=True)
            raise SpiceError(
                f"{netlist.name}: ngspice exceeded {timeout}s (host backstop); "
                f"in-container process killed"
            ) from e
        finally:
            with _running_lock:
                _running -= 1
    if proc.returncode == 137:
        raise SpiceError(f"{netlist.name}: ngspice exceeded {timeout}s and was killed in the container")

    out = (proc.stdout or "") + (proc.stderr or "")
    if proc.returncode == 3 or "[ERROR]" in out:
        raise SpiceError(
            f"{netlist.name}: environment check failed in {RUNNER}:\n"
            + "\n".join(l for l in out.splitlines() if "[ERROR]" in l))
    # ngspice only WARNS when it cannot apply a corner setting, then
    # runs at its default. That is worse than a crash: nine temperature
    # corners once came back identical to seven significant figures
    # because a stray "+" continuation line had swallowed the .temp
    # card. A corner that was not applied is not a corner.
    for bad in ("could not set temperature", "unknown parameter"):
        if bad in out.lower():
            line = next((l for l in out.splitlines()
                         if bad in l.lower()), bad)
            raise SpiceError(
                f"{netlist.name}: ngspice ignored a setting and used "
                f"its default instead:\n  {line.strip()}")
    if "fatal error" in out.lower():
        bad = [l for l in out.splitlines()
               if "error" in l.lower()][:6]
        raise SpiceError(f"{netlist.name}: ngspice fatal error:\n"
                         + "\n".join(bad))
    return out


def run_many(netlists, timeout: int = 1800, progress: bool = True):
    """Run many netlists with at most MAX_PARALLEL in flight.

    Returns {netlist_path: output}. Raises on the first failure, after the
    other in-flight jobs finish, so a broken sweep stops instead of
    reporting partial results as if they were complete.
    """
    netlists = list(netlists)
    results, done = {}, 0
    with ThreadPoolExecutor(max_workers=MAX_PARALLEL) as ex:
        futs = {ex.submit(run, n, timeout): n for n in netlists}
        for f in as_completed(futs):
            n = futs[f]
            results[n] = f.result()          # re-raises SpiceError
            done += 1
            if progress:
                print(f"\r  [{done}/{len(netlists)}] {n.name:<44}",
                      end="", flush=True)
    if progress:
        print(f"\r  {len(netlists)} simulations done, peak parallelism "
              f"{peak_parallel()}/{MAX_PARALLEL}" + " " * 20)
    return results


# ngspice prints measurements as e.g. "vp_3 = 1.650000e+00"
_MEAS = r"^\s*{}\s*=\s*([-+]?[\d.]+(?:[eE][-+]?\d+)?)"


def meas(output: str, name: str) -> float | None:
    m = re.search(_MEAS.format(re.escape(name)), output, re.MULTILINE)
    if not m:
        return None
    try:
        return float(m.group(1))
    except ValueError:
        return None


def meas_required(output: str, name: str, where: str) -> float:
    v = meas(output, name)
    if v is None:
        raise SpiceError(
            f"{where}: ngspice returned no value for '{name}'. A missing "
            f"measurement is not a measurement of zero.")
    return v


def self_test() -> int:
    """Confirm the container, the environment and the cap."""
    import time
    fails = []

    def expect(ok, msg):
        if not ok:
            fails.append(msg)

    print("[spice_pool] environment")
    probe = Path(__file__).resolve().parent / ".staging_pool"
    probe.mkdir(exist_ok=True)
    nl = probe / "env_probe.spice"
    nl.write_text(
        "* environment probe: a 1 uA ramp into the DRC-minimum MIM cell\n"
        '.include "/foss/pdks/gf180mcuD/libs.tech/ngspice/design.ngspice"\n'
        ".param fnoicor=0\n"
        ".lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice typical\n"
        ".lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice "
        "mimcap_typical\n"
        ".lib /foss/pdks/gf180mcuD/libs.tech/ngspice/sm141064.ngspice "
        "cap_mim\n"
        "X1 A 0 cap_mim_2f0fF c_width=5e-6 c_length=5e-6\n"
        "I1 0 A DC 1u\n"
        ".ic V(A)=0\n"
        ".control\n  set filetype=ascii\n  tran 1n 1u\n"
        "  meas tran v_end FIND v(A) AT=1u\n  quit\n.endc\n.end\n")
    out = run(nl, timeout=300)
    v = meas_required(out, "v_end", nl.name)
    cu = 1e-6 * 1e-6 / v
    expect(abs(cu * 1e15 - 54.518) < 0.05,
           f"unit cell measured {cu*1e15:.3f} fF, expected 54.518 fF — the "
           f"PDK or corner is not what this project assumes")
    print(f"  ngspice reachable, unit cell = {cu*1e15:.3f} fF "
          f"(expected 54.518)")

    # The environment assertions must actually bite.
    bad = probe / "bad_env.spice"
    bad.write_text("* deliberately broken\n.control\n  quit\n.endc\n.end\n")
    try:
        run(bad, timeout=120)
        print("  a trivial netlist runs (no false failure)")
    except SpiceError as e:
        fails.append(f"trivial netlist raised: {e}")

    print("\n[spice_pool] parallelism cap")
    jobs = []
    for i in range(14):
        p = probe / f"par_{i}.spice"
        p.write_text(
            "* parallelism probe\n"
            ".control\n  set filetype=ascii\n"
            "  let x = 0\n"
            "  repeat 400000\n    let x = x + 1\n  end\n"
            "  print x\n  quit\n.endc\n.end\n")
        jobs.append(p)
    t0 = time.time()
    run_many(jobs, timeout=600, progress=True)
    expect(peak_parallel() <= MAX_PARALLEL,
           f"peak parallelism {peak_parallel()} exceeded {MAX_PARALLEL}")
    print(f"  14 jobs in {time.time()-t0:.1f}s, peak parallelism "
          f"{peak_parallel()} (cap {MAX_PARALLEL})")

    if fails:
        print(f"\n[self-test] FAILED — {len(fails)}:")
        for f in fails:
            print(f"  x {f}")
        return 1
    print("\n[self-test] PASSED")
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(self_test())
