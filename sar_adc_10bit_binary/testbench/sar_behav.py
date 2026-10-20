#!/usr/bin/env python3
# Open-Silicon-SAR-ADC
# Gulu, Ankur Gupta, Ahmed Elnaggar
# Author: Ahmed Elnaggar
"""
sar_behav.py — SAR ADC top level with a behavioural SAR (option C)
===================================================================
The synthesised macro `sar_logic_diff` cannot be used to verify the analog
path: its `dac_n` bits are the *inverse* of the same ten flops that drive
`dac_p` (confirmed in the P&R netlist as well as the SPICE view), so both
plates are never simultaneously at ground and the first bit trial starts
from a corrupted residue. That is a digital defect and it is tracked
separately in NOTES.md.

This module replaces **only the SAR register and its timing** with a
behavioural equivalent, and keeps everything else exactly as it is drawn:

    CDAC          split_cdac_opt_r / diff_cdac_opt_r   real devices, 3.3 V
    drivers       cdac_driver_array_*                  real devices, 3.3 V
    comparator    comp_tot                             real devices, 3.3 V
    SAR register  20 x XSPICE d_dff                    behavioural
    FSM timing    PWL sources                          behavioural

No standard cells and no 5 V devices appear at all, so the analog-only rule
holds here without the exemption `sar_top.py` needed.

Why d_dff and not a Python co-simulation
----------------------------------------
The FSM's *timing* is fixed and known — 8 track clocks, 2 hold clocks, then
2 settle + 1 compare + 1 latch per bit — so it needs no counter, only ten
one-shot latch edges that can be written as PWL. What genuinely depends on
the conversion is which of `dac_p[b]` / `dac_n[b]` goes high, and that is one
flip-flop each. Twenty flops and eleven PWL sources reproduce the register
exactly, and the whole conversion then runs in a **single transient** with
the real settling history intact. Driving the loop from Python instead would
need one SPICE run per bit trial (10x the runs) and would have to re-create
the settling history in each one.

Set-and-up, reproduced exactly
------------------------------
`sar_logic_diff.v`:

    if (comp_out) dac_p[bit] <= 1'b1;   else dac_n[bit] <= 1'b1;
    sar_reg[bit] <= ~comp_out;

with `comp_out = 1` meaning V_OUT_P < V_OUT_N. Two flops per bit, both
starting cleared (`ic=0`), one clocked edge each, give precisely this:

    flop_p[b]:  D = comp_out    -> dac_p[b]
    flop_n[b]:  D = ~comp_out   -> dac_n[b]

and `dout[b] == dac_n[b]`, so the output word is read straight off the N-side
flops. Before bit b is decided both its flops are 0 and both its capacitors
sit at ground, which is the property the synthesised macro loses.

`comp_out` is taken from comp_tot's **Qb** — measured, not assumed, by
comp_polarity.py: Q = 1 when vinp > vinn, the opposite of what the FSM
documents it expects.

Weights and full scale
----------------------
`cdac_arch.weights_from_caps` carries a factor 2 for *complementary*
differential switching, where both arrays move on every trial. Set-and-up
moves only one side per trial, so the differential step per bit is **half**
the tabulated weight. Working through the residue,

    vin_diff = SUM_b (2*dout[b] - 1) * w_b/2  = (w_0/2)*(2*code - 1023)

so one code step of input is `w_0` — the tabulated LSB weight — and full
scale is 1024*w_0 = 2*VREF differential, i.e. +/-VREF. `lsb_volts()` and
`code_of_vin()` below are the only place that conversion is written down.

The excursion this implies is worth stating: set-and-up only ever pulls a
top plate **up**, never down, and at full scale one side absorbs the entire
SUM w_b/2 = VREF of movement. VCM is therefore a real design variable here
and not just a bias point — see the `vcm` sweep in tb_sar_behav.py.
"""

from __future__ import annotations

import json
import re
import shutil
import sys
import threading
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
CDAC_SIM = HERE  # this folder: netlists are kept alongside the scripts here
sys.path.insert(0, str(CDAC_SIM))

import spice_pool as SP                                          # noqa: E402
from cdac_arch import (ARCHS, VREF, nominal_weights,             # noqa: E402
                       SIGMA_UNIT_PCT)

STAGE = HERE / ".staging_behav"
PDK = "/foss/pdks/gf180mcuD/libs.tech/ngspice"

N_BITS = 10


def n_bits(arch: str) -> int:
    """Bit trials this architecture performs.

    The binary array does ten; the redundant split arrays do eleven or
    twelve, because sub-radix bits buy decision margin at the cost of extra
    trials. It is the length of the weight table, not a property of the
    output word width.
    """
    return len(nominal_weights(arch))


def use_arch(arch: str) -> int:
    """Point the module's bit count at `arch`.

    N_BITS is read at call time by every netlist builder here and by
    tb_sar_behav, so setting it once at the top of a runner is enough. It is
    a module global rather than an argument because it appears in nine call
    signatures that are otherwise stable, and no runner mixes bit counts
    inside one process.
    """
    global N_BITS
    N_BITS = n_bits(arch)
    return N_BITS


# The MIM model has only three statistical sections (typical / ss / ff), so
# the mixed transistor corners fs and sf take the typical capacitor. Naming
# the mapping here keeps a wrong ".lib mimcap_fs" from silently falling
# through as a missing section.
MIMCAP = {"typical": "mimcap_typical", "ff": "mimcap_ff",
          "ss": "mimcap_ss", "fs": "mimcap_typical", "sf": "mimcap_typical"}

# FSM timing from sar_logic_diff.v (the part of the macro that is sound).
# The converter is never in TRACK at power-up; it enters TRACK from an idle
# hold. That is not cosmetic for a bootstrapped sampling switch: the boost
# capacitor is charged during hold, so starting the transient in TRACK leaves
# it uncharged and the switch never boosts at all. Measured before this was
# added: overdrive 0.70 V instead of 3.60 V, and the sampling gate stuck high
# because it had never been grounded.
PRE_HOLD_CYCLES = 4     # idle hold before the first acquisition
ACQ_CYCLES = 8          # S_TRACK
HOLD_CYCLES = 2         # S_HOLD_T + S_HOLD_B
# moving by tens of nanovolts (not microvolts) between 1 and 2 cycles at
# the 22 ns signed-off period -- three orders of magnitude below 1 LSB
# (~2 mV) -- so 1 cycle is not a corner-cut, it is the array's actual
# settling time with ~22x margin to spare. Cuts 51 clocks/conversion to
# just short of. sar_logic_diff.v's SETTLE_CYC default was changed to
# match -- this constant and that parameter must stay in sync.
SETTLE_CYC = 1          # S_SETTLE, per bit (was 2, F-60)
CMP_CYC = 1             # S_CMP,    per bit
LATCH_CYC = 1           # S_UPDATE, per bit
TRIAL_CYC = SETTLE_CYC + CMP_CYC + LATCH_CYC        # 3 (was 4)

# Where inside the LATCH cycle the register captures. comp_tot's NAND SR
# latch holds its state once clk falls (both raw outputs precharge high, so
# S = R = 1), so capturing a quarter-cycle after the compare window closes is
# clean: no race with the falling strobe and no dependence on the comparator
# still being in evaluate.
LATCH_FRAC = 0.25


class BehavError(RuntimeError):
    pass


# ──────────────────────────────────────────────────────────────────────────
# Timing
# ──────────────────────────────────────────────────────────────────────────
def schedule(t_clk: float, acq_cycles: int = ACQ_CYCLES,
             pre_hold: int = PRE_HOLD_CYCLES) -> dict:
    """Absolute times of every phase boundary, in seconds.

    `acq_cycles` is a parameter rather than the FSM constant because the
    track window is the binding limit for the unsplit array: it samples onto
    55.8 pF per side through the same NMOS switch the 1.74 pF split array
    uses, so the RTL's 8 clocks are ample for one and not the other.
    """
    t_track = pre_hold * t_clk
    t_hold = (pre_hold + acq_cycles) * t_clk
    t0 = (pre_hold + acq_cycles + HOLD_CYCLES) * t_clk
    trials = []
    for k in range(N_BITS):
        base = t0 + k * TRIAL_CYC * t_clk
        trials.append({
            "bit": N_BITS - 1 - k,
            "settle": base,
            "cmp_rise": base + SETTLE_CYC * t_clk,
            "cmp_fall": base + (SETTLE_CYC + CMP_CYC) * t_clk,
            "latch": base + (SETTLE_CYC + CMP_CYC + LATCH_FRAC) * t_clk,
            "end": base + TRIAL_CYC * t_clk,
        })
    return {"t_track": t_track, "t_hold": t_hold, "t_trial0": t0,
            "trials": trials, "t_end": trials[-1]["end"] + t_clk}


def _pwl(points, tr: float) -> str:
    """PWL argument list from (time, value) breakpoints with edge time tr."""
    out = []
    for i, (t, v) in enumerate(points):
        if i and t > points[i - 1][0]:
            out.append(f"{t:.6e} {points[i-1][1]:.4f}")
        out.append(f"{t + (tr if i else 0):.6e} {v:.4f}")
    return " ".join(out)


# ──────────────────────────────────────────────────────────────────────────
# Code <-> voltage
# ──────────────────────────────────────────────────────────────────────────
def lsb_volts(arch: str) -> float:
    """Differential input step per output code [V].

    See the module docstring: set-and-up halves the tabulated weights, and
    the two cancel, so one code equals the bit-0 tabulated weight exactly.
    """
    return float(nominal_weights(arch)[0])


def full_scale_V(arch: str) -> float:
    """Largest differential input the array can resolve [V].

    Half the sum of the tabulated weights, because set-and-up halves each
    weight and at full scale every bit is switched. For the binary array
    that is identically 511.5*w0 - the code-1023 edge - and for the
    redundant arrays, whose raw word is not a binary code, it is the only
    definition that means anything.
    """
    return 0.5 * float(np.sum(nominal_weights(arch)))


def code_of_vin(arch: str, vin: float | np.ndarray):
    """Ideal transfer function, unrounded, so residuals stay visible."""
    return np.asarray(vin) / lsb_volts(arch) + (1 << (N_BITS - 1)) - 0.5


def vin_of_code(arch: str, code):
    return (np.asarray(code, dtype=float)
            - (1 << (N_BITS - 1)) + 0.5) * lsb_volts(arch)


# ──────────────────────────────────────────────────────────────────────────
# Netlist
# ──────────────────────────────────────────────────────────────────────────
def _defang(text: str) -> str:
    """Comment out a leading '+' line so an include cannot eat a directive.

    `cdac_driver_array.spice` begins with `+ sch_path: ...`, an xschem export
    artifact. A leading '+' is a SPICE continuation, so when that file is
    included it continues whatever line precedes the include. Here that line
    was `.temp`, which became `.temp -40.0 sch_path: /foss/...` and was
    rejected:

        Warning: Could not set temperature to -40.0 sch_path: ...
        Doing analysis at TEMP = 27.000000 and TNOM = 27.000000

    ngspice warns rather than fails, so nine temperature corners ran silently
    at 27 C and returned numbers identical to seven significant figures. The
    array-level testbenches escape it only because they put `.temp` after all
    their includes; this fixes the file rather than relying on that ordering.
    """
    out, seen = [], False
    for line in text.splitlines():
        if not seen and line.strip():
            seen = True
            if line.lstrip().startswith("+"):
                line = "* [defanged leading continuation] " + line.lstrip()[1:]
        out.append(line)
    return "\n".join(out) + "\n"


_stage_lock = threading.Lock()
_staged: set = set()


# Subcircuits the split arrays instantiate but do not all define. The 5+5
# arrays carry their own copies of these two transmission gates; the 12-bit
# redundant array does not, and stage() deliberately refuses to include
# split_cdac.spice wholesale because split_cdac_opt_r defines the same two
# cells and silently redefining a cell in the sampling path is exactly the
# class of error this harness exists to avoid. So the cells are extracted on
# their own, from the one file that is their source.
TG_CELLS = ("analog_tg_dummy", "analog_tg_small")
TG_SOURCE = "split_cdac.spice"
TG_FILE = "analog_tg_cells.spice"


def _subckts(text: str) -> set[str]:
    return {m.group(1).lower()
            for m in re.finditer(r"(?im)^\.subckt\s+(\S+)", text)}


SAMP_INV = "inv_x1"


def _extract_subckt(text: str, name: str) -> str:
    """One .subckt block, verbatim, including its .ends."""
    out, keep = [], False
    for line in text.splitlines():
        s = line.strip().lower()
        if s.startswith(".subckt ") and s.split()[1] == name.lower():
            keep = True
        if keep:
            out.append(line)
        if keep and s.startswith(".ends"):
            break
    if not out:
        raise BehavError(f"{name} not found in {TG_SOURCE}")
    return chr(10).join(out)


def needs_tg_cells(arch: str) -> bool:
    """True when this arch's array uses the shared gates but lacks them."""
    txt = (CDAC_SIM / ARCHS[arch]["netlist"]).read_text(errors="replace")
    have = _subckts(txt)
    return any(c not in have and c in txt.lower() for c in TG_CELLS)


def stage(arch: str, seed: int | None = None,
          sigma_pct: float | None = None) -> Path:
    """Stage the netlists this top level needs, one directory per variant.

    With `seed` set, the capacitor array is copied through
    `calibrate_ls._perturb`, which draws an independent Pelgrom deviation for
    every cap_mim instance (sigma_unit/sqrt(m) for an m-cell capacitor) and
    applies it to CAPACITANCE by solving the PDK model for the length that
    delivers it. Scaling c_length directly would under-inject by 4.3 %,
    Reusing that function rather than writing a second one keeps the
    top-level mismatch identical to the array-level mismatch.

    Each (arch, seed, sigma) gets its own directory, and each is written
    exactly once under a lock. Re-copying on every conversion is a real race
    once conversions run in parallel: one thread truncates comp_tot.spice
    while another thread's ngspice is reading it, and that run then silently
    reports no measurements.

    Deliberately does NOT stage split_cdac.spice: it defines
    `analog_tg_dummy` and `analog_tg_small`, and so does split_cdac_opt_r, so
    including both silently redefines two subcircuits in the sampling path.
    """
    a = ARCHS[arch]
    key = (arch, seed, sigma_pct)
    tag = f"{arch}_nom" if seed is None else f"{arch}_s{seed}_{sigma_pct}"
    d = STAGE / tag
    with _stage_lock:
        if key in _staged:
            return d
        d.mkdir(parents=True, exist_ok=True)
        tri = sorted(x.name for x in CDAC_SIM.glob("cdac_driver_tri*.spice"))
        for f in dict.fromkeys(["cdac_driver_array.spice",
                                f"{a['driver']}.spice",
                                "comp_tot.spice"] + tri):
            src = CDAC_SIM / f
            if not src.exists():
                raise BehavError(f"{f} not found in {CDAC_SIM}")
            (d / f).write_text(_defang(src.read_text(errors="replace")),
                               encoding="utf-8")

        if needs_tg_cells(arch):
            src = (CDAC_SIM / TG_SOURCE).read_text(errors="replace")
            (d / TG_FILE).write_text(
                "* extracted from " + TG_SOURCE + " by sar_behav.stage()"
                + chr(10) + chr(10).join(_extract_subckt(src, c)
                                         for c in TG_CELLS) + chr(10),
                encoding="utf-8")

        txt = _defang((CDAC_SIM / a["netlist"]).read_text())
        if seed is not None:
            from calibrate_ls import _perturb          # noqa: E402
            if sigma_pct is None:
                sigma_pct = a.get("sigma_unit_pct", SIGMA_UNIT_PCT)
            txt, n = _perturb(txt, seed, sigma_pct)
            if n == 0:
                raise BehavError(
                    f"{a['netlist']}: no cap_mim instance carried a "
                    f"c_length, so mismatch injection would be a no-op")
        (d / a["netlist"]).write_text(txt)
        _staged.add(key)
    return d


def top_subckt(arch: str, reset_net: str = "NULL",
               switching: str = "setup",
               tri_suffix: str = "") -> str:
    """CDAC + drivers + comparator + behavioural SAR register.

    Every net here is a plain name — no brackets. ngspice parses `v(x[0])`
    as element 0 of a vector called `x` rather than as the node, which has
    already produced two rounds of meaningless measurements in this project.
    Keeping brackets inside the subcircuit port lists only avoids it here.
    """
    a = ARCHS[arch]
    cdac = a["netlist"].replace(".spice", "")
    drv = a["driver"]
    dummy = a.get("dummy_ports", True)

    hi = range(N_BITS - 1, -1, -1)
    swp = " ".join(f"SWP{i}" for i in hi)
    swn = " ".join(f"SWN{i}" for i in hi)
    dp = " ".join(f"DACP{i}" for i in hi)
    dn = " ".join(f"DACN{i}" for i in hi)

    dum = "DUMMY_P DUMMY_N " if dummy else ""

    # One flop pair per bit, each clocked by its own one-shot latch edge.
    # D_p = comp_out (= comparator Qb), D_n = ~comp_out (= comparator Q).
    # d_dff ports: data clk set reset out Nout. The reset is ACTIVE HIGH in
    # this ngspice build (measured), so `reset_net` must be pulsed high to
    # clear the register, and NULL leaves it permanently unasserted.
    flops = "\n".join(
        f"A_FF{b} d_comp_out d_latch{b} NULL {reset_net} d_dacp{b} NULL "
        f"sar_dff\n"
        f"A_FG{b} d_comp_q   d_latch{b} NULL {reset_net} d_dacn{b} NULL "
        f"sar_dff"
        for b in range(N_BITS))

    din = " ".join(f"d_dacp{b} d_dacn{b}" for b in range(N_BITS))
    aout = " ".join(f"DACP{b} DACN{b}" for b in range(N_BITS))
    lat_a = " ".join(f"LATCH{b}" for b in range(N_BITS))
    lat_d = " ".join(f"d_latch{b}" for b in range(N_BITS))

    # Bottom-plate drive. "setup" is the as-built two-level scheme; "mcs"
    # rests the plates at VREF/2 and moves the deciding bit's capacitor down
    # on one side and up on the other, so the differential moves by the same
    # weight while the common mode does not move at all.
    if switching == "mcs":
        half = VREF / 2.0
        lines = []
        for b in range(N_BITS):
            lines.append(
                f"B_SWP{b} SWP{b} 0 V = (v(DACN{b})>1.65) ? 0 : "
                f"((v(DACP{b})>1.65) ? {VREF} : {half:.9f})")
            lines.append(
                f"B_SWN{b} SWN{b} 0 V = (v(DACN{b})>1.65) ? {VREF} : "
                f"((v(DACP{b})>1.65) ? 0 : {half:.9f})")
        drivers = chr(10).join(lines)
    elif switching == "mcs_real":
        # Real three-level drivers. P side: UP = dac_p (plate to VREF),
        # DN = dac_n (plate to GND). N side: the two are exchanged, which is
        # what makes the N plate move opposite to the P plate.
        fam = "" if N_BITS == 10 else str(N_BITS)
        cell = f"cdac_driver_tri{fam}{tri_suffix}"
        drivers = (f"X_DRV_P VREF VMID {swp} {dp} {dn} VDD33 VSS {cell}"
                   + chr(10) +
                   f"X_DRV_N VREF VMID {swn} {dn} {dp} VDD33 VSS {cell}")
    elif switching == "setup":
        drivers = (f"X_DRV_P VREF {swp} {dp} VSS {drv}" + chr(10) +
                   f"X_DRV_N VREF {swn} {dn} VSS {drv}")
    else:
        raise BehavError(f"unknown switching scheme {switching!r}")

    samp_inv = SAMP_INV
    return f"""* ---- SAR ADC top level, behavioural SAR register ----
* Sampling-switch complement from the real inverter, not an ideal source,
* so the non-overlap the array sees is the one simulated.
X_INV_SAMP VDD33 samp_top samp_top_b VSS {samp_inv}

{drivers}

X_CDAC {swp} VOUT_P VIN_P VIN_N VOUT_N {swn} {dum}samp_top samp_top_b \
VDD33 VSS {cdac}

* comp_out from Qb: comp_polarity.py measures Q = 1 when vinp > vinn, while
* the FSM is written for comp_out = 1 meaning V_OUT_P < V_OUT_N.
X_COMP VOUT_P VDD33 VOUT_N cmp_clk VSS comp_q comp_out comp_tot

* ---- behavioural SAR register ----
A_ADC [comp_out comp_q {lat_a}] [d_comp_out d_comp_q {lat_d}] sar_adc
{flops}
A_DAC [{din}] [{aout}] sar_dac

* Differential residue as a real node, so it can be measured directly;
* `meas ... FIND` takes one vector, not an expression.
E_DIFF VDIFF 0 VOUT_P VOUT_N 1.0
"""


# Which inverter drives samp_top_b. It was hardwired to inv_x1 (W = 0.5/1.0
# um) while the bootstrap's clamp devices MN1 and MN2 present 48 um of gate
# width between them - a fanout of about 100:1. The boosted node couples back
# through those gates and a driver that weak cannot hold the node, which is
# what puts MN1 and MN2 72 mV above VDD at the absolute-maximum supply


_MACRO_DELAY_CACHE: dict | None = None
# The zero-delay reference: what every number before Phase 2 Tier A assumed.
_NO_DELAY = {"samp_top": 0.0, "cmp_clk": 0.0, "dac_max": 0.0}


def macro_delays(corner: str | None) -> dict:
    """Measured clk -> output arrivals for the delivered macro, in seconds.

    Read from `results/macro_delays.json`, which
    `extract_macro_delays.py` writes by running OpenSTA against
    `macro_deliverables/` with its SPEF and a propagated clock. Nothing
    here is a literal: if the macro is re-hardened, re-run the extractor
    and every timing-aware result follows.

    `corner=None` returns zeros -- the pre-Tier-A reference, kept so the
    historical numbers stay reproducible.
    """
    global _MACRO_DELAY_CACHE
    if corner is None:
        return dict(_NO_DELAY)
    if _MACRO_DELAY_CACHE is None:
        p = HERE / "results" / "macro_delays.json"
        if not p.exists():
            raise BehavError(
                f"{p} is missing -- run extract_macro_delays.py in the "
                f"container first. A missing delay file must not silently "
                f"become a zero delay (rule 1).")
        _MACRO_DELAY_CACHE = json.loads(p.read_text())
    cs = _MACRO_DELAY_CACHE["corners"]
    if corner not in cs:
        raise BehavError(f"no macro delays for corner {corner!r}; "
                         f"have {sorted(cs)}")
    c = cs[corner]
    out = {"samp_top": c["ports_s"]["samp_top"],
           "cmp_clk": c["ports_s"]["cmp_clk"],
           "dac_max": c["dac_max_s"]}
    for k, v in out.items():
        if v is None:
            raise BehavError(f"macro delay {k} is null at corner {corner}")
    return out


def testbench(arch: str, vin_diff: float, vcm: float, t_clk: float,
              temp_c: float = 27.0, vdd: float = 3.3,
              corner: str = "typical", wrdata: str | None = None,
              acq_cycles: int = ACQ_CYCLES, ref_r: float = 0.0,
              ref_c: float = 0.0, ref_l: float = 0.0,
              dev_seed: int | None = None,
              switching: str | None = None, tri_suffix: str = "",
              macro_corner: str | None = None) -> str:
    """One conversion of a single input point.

    `macro_corner` selects which set of the delivered macro's measured
    clk -> output delays to apply: "typical", "ss", "ff", or None for the
    zero-delay reference the campaign used before Phase 2 Tier A. None is
    the default so every historical number stays reproducible; pass a
    corner explicitly to measure the macro's timing cost.

    `switching`/`tri_suffix` default to whatever `ARCHS[arch]` registers
    that does not register a switching scheme explicitly -- so existing
    callers that never passed these are unaffected.
    """
    a = ARCHS[arch]
    if switching is None:
        switching = a.get("switching", "setup")
    if not tri_suffix:
        tri_suffix = a.get("tri_suffix", "")
    s = schedule(t_clk, acq_cycles)
    tr = t_clk / 50.0
    vp, vn = vcm + vin_diff / 2.0, vcm - vin_diff / 2.0

    # Phase 2 Tier A: the delivered macro's real clk -> output arrivals,
    # read from results/macro_delays.json (written by
    # extract_macro_delays.py, OpenSTA on macro_deliverables/ with SPEF and
    # a propagated clock). Never typed here -- G13's rule applied to timing.
    #
    # Each signal takes ITS OWN delay. An earlier revision gave samp, cmp_clk
    # and the latches one common ~3.2 ns shift, which is a pure translation
    # of the whole waveform: the relative skew it actually injected was
    # 25 ps, and the settling margin -- the quantity this exercise exists to
    # measure -- was left untouched. Worse, it delayed the latches by
    # `cmp_clk` when the latches stand in for the DAC control outputs, which
    # are the SLOWEST ports on the macro. That errs optimistic on exactly the
    # number in question.
    d = macro_delays(macro_corner)
    d_samp_top = d["samp_top"]
    d_cmp_clk = d["cmp_clk"]
    # The latch edge stands in for the array actually seeing a new code, so
    # it carries the DAC control delay, not the strobe's.
    d_dac = d["dac_max"]
    # Everything that follows the last edge -- the final measurement and the
    # transient stop time -- has to clear the slowest signal, not an
    # arbitrary one.
    d_settle = max(d_samp_top, d_cmp_clk, d_dac)

    # samp_top: low for the pre-hold, high for acquisition, then low.
    samp = _pwl([(0.0, 0.0), (s["t_track"] + d_samp_top, vdd), (s["t_hold"] + d_samp_top, 0.0),
                 (s["t_end"] + d_samp_top, 0.0)], tr)

    # cmp_clk: one strobe per trial.
    pts = [(0.0, 0.0)]
    for tr_i in s["trials"]:
        pts += [(tr_i["cmp_rise"] + d_cmp_clk, vdd), (tr_i["cmp_fall"] + d_cmp_clk, 0.0)]
    pts.append((s["t_end"], 0.0))
    cmp_clk = _pwl(pts, tr)

    # One rising latch edge per bit, held high afterwards (edge-triggered,
    # so the level does not matter once it has fired).
    latches = "\n".join(
        "V_LAT{b} LATCH{b} 0 PWL({p})".format(
            b=t["bit"],
            p=_pwl([(0.0, 0.0), (t["latch"] + d_dac, vdd),
                    (s["t_end"] + d_dac, vdd)], tr))
        for t in s["trials"])

    # Transistor mismatch. The PDK defaults sw_stat_mismatch to 0, so
    # every earlier run in this record had perfectly matched devices and
    # a comparator offset of exactly zero. Setting it to 1 enables the
    # per-instance Pelgrom model (delvto = agauss(0, 0.7071*A_VT/
    # sqrt(W*L), 1)), and .option seed draws a different sample.
    dev_mm = ("" if dev_seed is None else
              f".param sw_stat_mismatch=1\n"
              f".option seed={dev_seed}\n")

    # Reference network. Both driver arrays are supplied from VREF and
    # the array switches up to 1023*Cu of bottom plates against it, ten
    # times per conversion, so a zero-impedance reference is an
    # optimistic assumption - and every top-level number taken before
    # this existed was taken with one. ref_r = 0 keeps that ideal
    # source; otherwise the source sits behind R (and optionally a bond
    # inductance) with C_dec at the die.
    if ref_r <= 0.0 and ref_l <= 0.0:
        ref_net = f"V_VREF  VREF  0 DC {VREF}"
    else:
        ref_net = (f"V_VREF  VREF_SRC 0 DC {VREF}\n"
                   f"R_REF   VREF_SRC VREF_M {ref_r:.6e}")
        if ref_l > 0.0:
            ref_net += f"\nL_REF   VREF_M VREF {ref_l:.6e}"
        else:
            ref_net += "\nR_REF2  VREF_M VREF 1e-9"
        if ref_c > 0.0:
            ref_net += f"\nC_DEC   VREF 0 {ref_c:.6e}"

    # MCS rests the bottom plates at VREF/2. It is shared by both
    # arrays, so an error in it is common mode and cancels in the
    # differential result - it sets where the plates rest, not the
    # size of the step.
    # The tri driver cell name carries the bit count, so a 12-bit array does
    # not silently include the 10-bit cell and then fail to find its own.
    # The 12-bit redundant array instantiates the shared transmission
    # gates without defining them; stage() extracts them separately.
    tg_inc = ((chr(10) + f'.include "{TG_FILE}"')
              if needs_tg_cells(arch) else "")
    tri_fam = "" if N_BITS == 10 else str(N_BITS)
    tri_inc = (f'.include "cdac_driver_tri{tri_fam}{tri_suffix}.spice"'
               if switching == "mcs_real" else "")
    vmid_src = (f"V_VMID VMID 0 DC {VREF/2.0:.9f}"
                if switching == "mcs_real" else "")

    # The split arrays terminate each sub-array with a dummy unit. It never
    # switches, so it only needs to be constant - but under MCS every other
    # plate rests at VREF/2, and leaving the dummies at VREF would push the
    # whole plate excursion up by a fixed amount for no reason. It is the
    # same on both sides either way, so this is headroom, not linearity.
    dummy_v = VREF / 2.0 if switching in ("mcs", "mcs_real") else VREF
    dummy_src = ("V_DUMMY_P DUMMY_P 0 DC {v:.9f}\n"
                 "V_DUMMY_N DUMMY_N 0 DC {v:.9f}"
                 .format(v=dummy_v)) if a.get("dummy_ports", True) else ""

    # Measurements -------------------------------------------------------
    m = []
    t_samp = s["t_hold"] - tr
    m.append(f"  meas tran vsamp FIND v(vdiff) AT={t_samp:.9e}")
    m.append(f"  meas tran vsp   FIND v(VOUT_P) AT={t_samp:.9e}")
    m.append(f"  meas tran vsn   FIND v(VOUT_N) AT={t_samp:.9e}")
    # After the switch is fully open and before the first bit trial. The
    # difference vhold - vsamp is the sampling pedestal: channel charge and
    # clock feedthrough from samp_top opening. It is signal-dependent, so its
    # variation across the input range is sampling distortion, and measuring
    # vsamp alone (which is taken while the switch is still closed) misses it
    # entirely.
    m.append(f"  meas tran vhold FIND v(vdiff) "
             f"AT={s['t_trial0'] - tr:.9e}")
    # Comparator input common mode drifts upward during a conversion because
    # set-and-up only ever pulls a plate up, and how far it drifts depends on
    # the code. Any common-mode dependence of the comparator offset therefore
    # turns straight into INL, so record where it ends up.
    m.append(f"  meas tran vcm_end FIND v(VOUT_P) "
             f"AT={s['t_end'] - tr:.9e}")
    m.append(f"  meas tran vcm_end_n FIND v(VOUT_N) "
             f"AT={s['t_end'] - tr:.9e}")
    for k, t in enumerate(s["trials"]):
        # residue the comparator actually saw, sampled just before its strobe
        m.append(f"  meas tran r{k} FIND v(vdiff) "
                 f"AT={t['cmp_rise'] - tr:.9e}")
    # Both halves of the differential pair are read at the SAME instant. A
    # previous revision measured DACN at t_end and DACP at t_end + d_cmp_clk,
    # sampling the two sides of the array 3.2 ns apart and manufacturing a
    # differential error out of nothing but the measurement.
    t_meas = s["t_end"] + d_settle - tr
    for b in range(N_BITS):
        m.append(f"  meas tran b{b}  FIND v(DACN{b}) AT={t_meas:.9e}")
        m.append(f"  meas tran p{b}  FIND v(DACP{b}) AT={t_meas:.9e}")
    m.append(f"  meas tran vres FIND v(vdiff) AT={t_meas:.9e}")
    # Reference excursion over the bit trials. It is code-dependent, because
    # how much charge each trial demands depends on which capacitors switch,
    # so it becomes INL rather than a gain error.
    m.append(f"  meas tran vrefmin MIN v(VREF) FROM={s['t_trial0']:.9e} "
             f"TO={s['t_end']:.9e}")
    m.append(f"  meas tran vrefmax MAX v(VREF) FROM={s['t_trial0']:.9e} "
             f"TO={s['t_end']:.9e}")
    # Headroom: set-and-up only pulls plates up, so the maxima are what bite.
    m.append(f"  meas tran vpmax MAX v(VOUT_P) FROM={s['t_trial0']:.9e} "
             f"TO={s['t_end']:.9e}")
    m.append(f"  meas tran vnmax MAX v(VOUT_N) FROM={s['t_trial0']:.9e} "
             f"TO={s['t_end']:.9e}")
    m.append(f"  meas tran vpmin MIN v(VOUT_P) FROM={s['t_trial0']:.9e} "
             f"TO={s['t_end']:.9e}")
    # Supply currents, averaged over one whole conversion. VREF carries the
    # capacitor-switching energy because both driver arrays are supplied
    # from it; VDD33 carries the comparator and the register bridges.
    m.append(f"  meas tran i_vdd  AVG i(V_VDD33) FROM={s['t_track']:.9e} "
             f"TO={s['t_end']:.9e}")
    m.append(f"  meas tran i_vref AVG i(V_VREF) FROM={s['t_track']:.9e} "
             f"TO={s['t_end']:.9e}")
    # MCS draws part of the plate charge from the VREF/2 rail, so leaving it
    # out understates the energy. With ideal tri-level B-sources there is no
    # such rail and the plate energy is not measured at all - which is why
    # the ideal-source energy figure is not comparable to a real driver.
    if switching == "mcs_real":
        m.append(f"  meas tran i_vmid AVG i(V_VMID) "
                 f"FROM={s['t_track']:.9e} TO={s['t_end']:.9e}")
    m.append(f"  meas tran vnmin MIN v(VOUT_N) FROM={s['t_trial0']:.9e} "
             f"TO={s['t_end']:.9e}")

    dump = ""
    if wrdata:
        probes = ("v(vout_p) v(vout_n) v(vdiff) v(cmp_clk) v(samp_top) "
                  "v(comp_out) "
                  + " ".join(f"v(dacp{b}) v(dacn{b})"
                             for b in (9, 8, 7, 0)))
        dump = f"  wrdata {wrdata} {probes}\n"

    return f"""* SAR ADC, behavioural SAR register — {arch}
* Vin_diff = {vin_diff:+.6f} V, VCM = {vcm} V, T = {temp_c} C, VDD = {vdd} V
* corner = {corner}, t_clk = {t_clk:.3e} s, acq = {acq_cycles} clocks\n* reference: R = {ref_r} ohm, L = {ref_l} H, C_dec = {ref_c} F
.include "{PDK}/design.ngspice"
.param fnoicor=0
.lib {PDK}/sm141064.ngspice {corner}
.lib {PDK}/sm141064.ngspice {MIMCAP[corner]}
.lib {PDK}/sm141064.ngspice cap_mim
.lib {PDK}/sm141064.ngspice res_typical
{dev_mm}.temp {temp_c}

* Analog blocks — 3.3 V devices only, no standard cells in this netlist.
.include "cdac_driver_array.spice"
.include "{a['driver']}.spice"
{tri_inc}
.include "comp_tot.spice"{tg_inc}
.include "{a['netlist']}"

* ---- XSPICE behavioural models (SAR register only) ----
* Thresholds set well inside the 3.3 V rails so a slow comparator edge is
* not read as a logic level before it has resolved.
.model sar_adc adc_bridge(in_low=0.9 in_high=2.4)
.model sar_dac dac_bridge(out_low=0 out_high={vdd} out_undef={vdd/2:.4f}
+ t_rise=100p t_fall=100p)
* ic=0: both flops of a bit start cleared, so an undecided bit has BOTH its
* capacitors at ground. That is the property the synthesised macro loses.
.model sar_dff d_dff(clk_delay=100p set_delay=100p reset_delay=100p
+ rise_delay=100p fall_delay=100p ic=0)

{top_subckt(arch, "NULL", switching, tri_suffix)}

V_VDD33 VDD33 0 DC {vdd}
V_VSS   VSS   0 DC 0
{ref_net}
{dummy_src}
{vmid_src}

* Differential input on the top plates through the sampling switch — the
* only sampling path the drawn netlist supports (see sar_top.py docstring).
V_VIN_P VIN_P 0 DC {vp:.9f}
V_VIN_N VIN_N 0 DC {vn:.9f}

V_SAMP  samp_top 0 PWL({samp})
V_CMPC  cmp_clk  0 PWL({cmp_clk})
{latches}

.ic V(VOUT_P)={vcm} V(VOUT_N)={vcm}

.control
  set filetype=ascii
  tran {t_clk/40:.4e} {s['t_end'] + d_settle:.6e} uic
{chr(10).join(m)}
{dump}  quit
.endc
.end
"""


# ──────────────────────────────────────────────────────────────────────────
# Running one point
# ──────────────────────────────────────────────────────────────────────────
def parse(out: str, where: str) -> dict:
    """Pull one conversion out of ngspice's measurement block."""
    g = lambda n: SP.meas_required(out, n, where)
    bits = [g(f"b{b}") for b in range(N_BITS)]
    pbits = [g(f"p{b}") for b in range(N_BITS)]
    hi = lambda v: 1 if v > 1.65 else 0  # zero-ok: bit decision on a value Python requires non-None (None > x raises)
    dout = [hi(v) for v in bits]
    dp = [hi(v) for v in pbits]

    # Every bit must have resolved to exactly one side. If both flops of a
    # bit are 0 the trial never fired; if both are 1 the register is broken.
    bad = [b for b in range(N_BITS) if dout[b] + dp[b] != 1]
    code = sum(d << b for b, d in enumerate(dout))
    return {
        "code": code,
        "dout": dout,
        "dac_p": dp,
        "one_hot_ok": not bad,
        "bad_bits": bad,
        "vsamp": g("vsamp"),
        "vsp": g("vsp"),
        "vsn": g("vsn"),
        "vhold": g("vhold"),
        "vref_min": g("vrefmin"),
        "vref_max": g("vrefmax"),
        # ngspice reports current INTO the source, so supply current is the
        # negative of it.
        "i_vdd_A": -g("i_vdd"),
        "i_vref_A": -g("i_vref"),
        # V_VMID exists only in the MCS testbench, so this measurement is
        # legitimately absent under set-and-up. It is therefore the one
        # field here that may be None instead of raising - but it reports
        # None rather than 0.0, because "no VMID source in this netlist" and
        # "VMID drew no current" are different statements. (Nothing consumes
        # this field today; it is recorded for the reference-charge work.)
        "i_vmid_A": (lambda v: -v if v is not None else None)(
            SP.meas(out, "i_vmid")),
        "vcm_end": g("vcm_end"),
        "vcm_end_n": g("vcm_end_n"),
        "residue": [g(f"r{k}") for k in range(N_BITS)],
        "vres": g("vres"),
        "vpmax": g("vpmax"), "vnmax": g("vnmax"),
        "vpmin": g("vpmin"), "vnmin": g("vnmin"),
    }


def convert(arch: str, vin_diff: float, vcm: float = 1.40,
            t_clk: float = 100e-9, temp_c: float = 27.0, vdd: float = 3.3,
            corner: str = "typical", tag: str = "",
            wrdata: str | None = None, timeout: int = 3600,
            acq_cycles: int = ACQ_CYCLES, seed: int | None = None,
            sigma_pct: float | None = None, ref_r: float = 0.0,
            ref_c: float = 0.0, ref_l: float = 0.0,
            dev_seed: int | None = None,
            switching: str | None = None, tri_suffix: str = "",
            macro_corner: str | None = None) -> dict:
    a = ARCHS[arch]
    if switching is None:
        switching = a.get("switching", "setup")
    if not tri_suffix:
        tri_suffix = a.get("tri_suffix", "")
    st = stage(arch, seed, sigma_pct)
    net = testbench(arch, vin_diff, vcm, t_clk, temp_c, vdd, corner, wrdata,
                    acq_cycles, ref_r, ref_c, ref_l, dev_seed, switching,
                    tri_suffix, macro_corner)
    name = f"conv_{tag or f'{vin_diff:+.6f}'}.spice".replace("+", "p")
    p = st / name
    p.write_text(net)
    out = SP.run(p, timeout=timeout)
    r = parse(out, p.name)
    r.update(vin=vin_diff, vcm=vcm, arch=arch, temp_c=temp_c, vdd=vdd,
             corner=corner, t_clk=t_clk, acq_cycles=acq_cycles,
             seed=seed, sigma_pct=sigma_pct, ref_r=ref_r,
             ref_c=ref_c, ref_l=ref_l, dev_seed=dev_seed,
             switching=switching, tri_suffix=tri_suffix)
    return r


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--arch", default="split10_opt_r")
    ap.add_argument("--vin", type=float, default=0.25)
    ap.add_argument("--vcm", type=float, default=1.40)
    ap.add_argument("--tclk", type=float, default=100e-9)
    a = ap.parse_args()

    lsb = lsb_volts(a.arch)
    print(f"{a.arch}: LSB {lsb*1e3:.4f} mV, full scale "
          f"+/-{full_scale_V(a.arch):.4f} V differential")
    print(f"one conversion at Vin = {a.vin:+.4f} V, VCM = {a.vcm} V\n")

    r = convert(a.arch, a.vin, a.vcm, a.tclk, tag="smoke")
    print(f"sampled  {r['vsamp']:+.6f} V  (applied {a.vin:+.6f} V, "
          f"error {(r['vsamp']-a.vin)*1e3:+.3f} mV)")
    print(f"  VOUT_P {r['vsp']:.4f} V   VOUT_N {r['vsn']:.4f} V\n")

    print("  trial  bit   residue seen      decision   dac_p dac_n")
    print("  " + "-" * 54)
    for k in range(N_BITS):
        b = N_BITS - 1 - k
        print(f"  {k:5d}  {b:3d}   {r['residue'][k]:+11.6f} V   "
              f"dout={r['dout'][b]}      {r['dac_p'][b]}     {r['dout'][b]}")
    print(f"\n  final residue {r['vres']:+.6f} V "
          f"({r['vres']/lsb:+.2f} LSB)")

    ideal = code_of_vin(a.arch, a.vin)
    print(f"\ncode {r['code']:4d}   ideal {float(ideal):8.2f}   "
          f"error {r['code']-float(ideal):+.2f} LSB")
    print(f"one-hot per bit: {'ok' if r['one_hot_ok'] else r['bad_bits']}")
    print(f"plate excursion: VOUT_P [{r['vpmin']:.3f}, {r['vpmax']:.3f}] V, "
          f"VOUT_N [{r['vnmin']:.3f}, {r['vnmax']:.3f}] V  (rail "
          f"0 - 3.300 V)")
