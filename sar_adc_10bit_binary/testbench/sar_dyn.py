#!/usr/bin/env python3
# Open-Silicon-SAR-ADC
# Gulu, Ankur Gupta, Ahmed Elnaggar
# Author: Ahmed Elnaggar
"""
sar_dyn.py - dynamic performance: SNDR, SFDR, ENOB from a real sine input.

Everything else in this record is static INL/DNL. That cannot see the one
error the sampling switch actually makes: its settling is signal-dependent,
which is distortion, and distortion is invisible to a static transfer curve.
So this runs a coherent sine through the whole converter and takes an FFT of
the output word.

What it needs that a single conversion does not
-----------------------------------------------
* Many conversions in ONE transient, so the behavioural register has to be
  cleared at the start of every TRACK phase. XSPICE d_dff's reset is ACTIVE
  HIGH in this build (measured), and `sar_behav.top_subckt(reset_net=...)`
  wires it.
* The fine transient step. `step_valid.py` showed V_dac(code) is immune to
  the step, but the CODE is not, and an FFT needs the code. 250 ps here
  against the 2500 ps a static sweep can use, which is why this costs about
  ten times as much per conversion.
* Coherent sampling: f_in = M/N * f_s with M odd and coprime to N, so the
  tone lands exactly in bin M and no window is needed. Anything else leaks
  signal power into neighbouring bins and understates SNDR.

Two input frequencies are run: one low, and one near Nyquist where
sampling-settling distortion is worst.
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "cdac" / "simulation"))

import spice_pool as SP                                          # noqa: E402
import sar_behav as SB                                           # noqa: E402

RESULTS = HERE / "results"
RESULTS.mkdir(exist_ok=True)

ACQ = 8
WARMUP = 2                                    # discarded, settles the pipe


def _timing_for(arch):
    """(nb, hold, trial, conv) for `arch`, read AFTER SB.use_arch(arch).

    SB.TRIAL_CYC/SB.HOLD_CYCLES once at import time -- correct only by
    coincidence, because every --archs this script had ever been given
    was 10 bits, matching sar_behav's own default before anything calls
    use_arch(). A 12-bit arch (design #2, redundant12_opt) exposed it:
    SB.N_BITS stayed 10 regardless of --archs, so the dynamic testbench
    was built for the wrong bit count and ngspice's own measurement
    points didn't land anywhere real ("ngspice returned no value for
    'c2b0'" -- G1's gate caught it; this is what a real, not-silenced,
    failure looks like). Fixed by making every caller resolve timing
    per-job, after switching architectures, instead of once at import.
    """
    SB.use_arch(arch)
    nb = SB.N_BITS
    hold = SB.HOLD_CYCLES
    trial = SB.TRIAL_CYC
    conv = ACQ + hold + nb * trial + 1
    return nb, hold, trial, conv


def _pwl(points, tr):
    out = []
    for i, (t, v) in enumerate(points):
        if i and t > points[i - 1][0]:
            out.append(f"{t:.9e} {points[i-1][1]:.4f}")
        out.append(f"{t + (tr if i else 0):.9e} {v:.4f}")
    return " ".join(out)


def netlist(arch, n_conv, m_bin, amp_diff, vcm, t_clk, temp_c, vdd, corner,
            step_div, ref_r=0.0, ref_c=0.0, ref_l=0.0,
            switching='setup', tri_suffix='', dev_seed=None):
    nb, hold, trial, conv = _timing_for(arch)
    a = SB.ARCHS[arch]
    tr = t_clk / 50.0
    tot = (n_conv + WARMUP) * conv * t_clk
    f_s = 1.0 / (conv * t_clk)
    f_in = m_bin / n_conv * f_s

    # Per-conversion periodic controls
    samp = f"PULSE(0 {vdd} 0 {tr:.4e} {tr:.4e} {ACQ*t_clk:.9e} " \
           f"{conv*t_clk:.9e})"
    rst = f"PULSE(0 {vdd} {0.10*t_clk:.9e} {tr:.4e} {tr:.4e} " \
          f"{1.5*t_clk:.9e} {conv*t_clk:.9e})"

    lat = []
    for k in range(nb):
        b = nb - 1 - k
        off = (ACQ + hold + k * trial + trial - 1 + SB.LATCH_FRAC) * t_clk
        lat.append(f"V_LAT{b} LATCH{b} 0 PULSE(0 {vdd} {off:.9e} {tr:.4e} "
                   f"{tr:.4e} {0.5*t_clk:.9e} {conv*t_clk:.9e})")

    pts = [(0.0, 0.0)]
    for c in range(n_conv + WARMUP):
        base = c * conv * t_clk
        for k in range(nb):
            t0 = base + (ACQ + hold + k * trial + 2) * t_clk
            pts += [(t0, vdd), (t0 + t_clk, 0.0)]
    pts.append((tot, 0.0))
    cmp_pwl = _pwl(pts, tr)

    if ref_r <= 0.0 and ref_l <= 0.0:
        refnet = f"V_VREF  VREF  0 DC {SB.VREF}"
    else:
        refnet = (f"V_VREF  VREF_SRC 0 DC {SB.VREF}\n"
                  f"R_REF   VREF_SRC VREF_M {ref_r:.6e}\n"
                  + (f"L_REF   VREF_M VREF {ref_l:.6e}\n" if ref_l > 0
                     else "R_REF2  VREF_M VREF 1e-9\n")
                  + (f"C_DEC   VREF 0 {ref_c:.6e}" if ref_c > 0 else ""))

    tri_inc = (f'.include "cdac_driver_tri{tri_suffix}.spice"' + chr(10)
               if switching == 'mcs_real' else '')
    # analog_tg_dummy/analog_tg_small, defined in TG_FILE, which
    # sar_behav.testbench() already includes conditionally
    # (needs_tg_cells) but this function never did -- binary arrays
    # don't need it, so it was never missed until a 12-bit array hit
    # this path. SB.stage(arch), called by run_one() before netlist(),
    # already writes TG_FILE into the same staging dir this netlist is
    # written to, so a plain relative include resolves.
    tg_inc = (f'.include "{SB.TG_FILE}"' + chr(10)
              if SB.needs_tg_cells(arch) else '')
    # sw_stat_mismatch is 0 by default in the PDK, so device mismatch is
    # off unless a seed is given.
    dev_mm = ('' if dev_seed is None else
              f'.param sw_stat_mismatch=1' + chr(10) +
              f'.option seed={dev_seed}' + chr(10))
    vmid = (f'V_VMID VMID 0 DC {SB.VREF/2.0:.9f}'
            if switching == 'mcs_real' else '')

    dummy = (f"V_DUMMY_P DUMMY_P 0 DC {SB.VREF}\n"
             f"V_DUMMY_N DUMMY_N 0 DC {SB.VREF}"
             if a.get("dummy_ports", True) else "")

    # Sample the word in the last clock of each conversion, before the next
    # reset clears the register.
    meas = []
    for c in range(n_conv + WARMUP):
        t = (c * conv + conv - 0.25) * t_clk
        for b in range(nb):
            meas.append(f"  meas tran c{c}b{b} FIND v(DACN{b}) AT={t:.9e}")

    return f"""* SAR ADC dynamic test - {arch}
* {n_conv} conversions (+{WARMUP} warm-up), tone in bin {m_bin},
* f_in = {f_in:.4f} Hz, f_s = {f_s:.4f} Hz, amplitude {amp_diff:.4f} Vpk diff
.include "{SB.PDK}/design.ngspice"
.param fnoicor=0
.lib {SB.PDK}/sm141064.ngspice {corner}
.lib {SB.PDK}/sm141064.ngspice {SB.MIMCAP[corner]}
.lib {SB.PDK}/sm141064.ngspice cap_mim
.lib {SB.PDK}/sm141064.ngspice res_typical
.temp {temp_c}

.include "cdac_driver_array.spice"
.include "{a['driver']}.spice"
.include "comp_tot.spice"
.include "{a['netlist']}"
{tg_inc}{tri_inc}{dev_mm}

.model sar_adc adc_bridge(in_low=0.9 in_high=2.4)
.model sar_dac dac_bridge(out_low=0 out_high={vdd} out_undef={vdd/2:.4f}
+ t_rise=100p t_fall=100p)
.model sar_dff d_dff(clk_delay=100p set_delay=100p reset_delay=100p
+ rise_delay=100p fall_delay=100p ic=0)

{SB.top_subckt(arch, "d_rst", switching, tri_suffix)}
A_RST [rst_a] [d_rst] sar_adc

V_VDD33 VDD33 0 DC {vdd}
V_VSS   VSS   0 DC 0
{refnet}
{dummy}
{vmid}

* Coherent differential sine on the top plates.
V_VIN_P VIN_P 0 DC {vcm} SIN({vcm} {amp_diff/2:.9f} {f_in:.9f})
V_VIN_N VIN_N 0 DC {vcm} SIN({vcm} {-amp_diff/2:.9f} {f_in:.9f})

V_SAMP samp_top 0 {samp}
V_RST  rst_a    0 {rst}
V_CMPC cmp_clk  0 PWL({cmp_pwl})
{chr(10).join(lat)}

.ic V(VOUT_P)={vcm} V(VOUT_N)={vcm}

.control
  set filetype=ascii
  tran {t_clk/step_div:.6e} {tot:.9e} uic
{chr(10).join(meas)}
  quit
.endc
.end
"""


def spectrum(codes, m_bin):
    """SNDR, SFDR, ENOB and THD from a coherently sampled code record."""
    x = np.asarray(codes, dtype=float)
    n = len(x)
    x = x - x.mean()
    X = np.fft.rfft(x)
    p = np.abs(X) ** 2
    p[0] = 0.0                                   # DC removed already
    sig = p[m_bin]
    tot = p[1:].sum()
    nd = tot - sig
    sndr = 10 * np.log10(sig / nd) if nd > 0 else float("inf")
    others = p[1:].copy()
    others[m_bin - 1] = 0.0
    spur = others.max()
    sfdr = 10 * np.log10(sig / spur) if spur > 0 else float("inf")
    harm = 0.0
    for h in range(2, 10):
        b = (h * m_bin) % n
        b = min(b, n - b)
        if 0 < b < len(p):
            harm += p[b]
    thd = 10 * np.log10(harm / sig) if harm > 0 else float("-inf")
    enob = (sndr - 1.76) / 6.02
    return {"sndr_dB": float(sndr), "sfdr_dB": float(sfdr),
            "thd_dB": float(thd), "enob_bits": float(enob),
            "n_samples": int(n), "bin": int(m_bin),
            "spur_bin": int(np.argmax(others) + 1),
            "amp_lsb_pk": float(np.abs(X[m_bin]) * 2 / n)}


def run_one(job):
    (arch, n_conv, m_bin, dbfs, vcm, t_clk, temp_c, vdd, corner, step_div,
     tag, switching, tri_suffix, dev_seed) = job
    fs_v = SB.full_scale_V(arch)
    amp = 0.88 * fs_v * (10 ** (dbfs / 20.0))
    st = SB.stage(arch)
    net = netlist(arch, n_conv, m_bin, amp, vcm, t_clk, temp_c, vdd, corner,
                  step_div, switching=switching, tri_suffix=tri_suffix,
                  dev_seed=dev_seed)
    p = st / f"dyn_{tag}.spice"
    p.write_text(net, encoding="utf-8")
    out = SP.run(p, timeout=14400)
    nb, _hold, _trial, conv = _timing_for(arch)
    # redundant12_opt's bit 6 is 1.03125x bit 5, not 2x (the sub-radix
    # discontinuity exactly at the sub-array boundary every time the
    # input sine crosses that code region, which is textbook harmonic
    # distortion. Using the array's own nominal_weights (already how
    # this project computes calibrated static INL, e.g.
    # analyze_weights.py) instead of `1 << b`, normalized by weights[0]
    # so the result stays in the same LSB-equivalent units `amp_lsb_pk`
    # below has always reported, fixes this. For a pure-binary array
    # weights[b]/weights[0] == 2**b exactly, so this reproduces the old
    # integer code bit-for-bit -- confirmed no change for design #1.
    weights = SB.nominal_weights(arch)
    w_lsb = [w / weights[0] for w in weights]
    codes = []
    for c in range(WARMUP, n_conv + WARMUP):
        bits = [SP.meas_required(out, f"c{c}b{b}", p.name) for b in range(nb)]
        codes.append(sum((1 if v > 1.65 else 0) * w_lsb[b]
                         for b, v in enumerate(bits)))
    r = spectrum(codes, m_bin)
    r.update(switching=switching, tri_suffix=tri_suffix,
             dev_seed=dev_seed,
             arch=arch, n_conv=n_conv, m_bin=m_bin, dbfs=dbfs, vcm=vcm,
             t_clk=t_clk, temp_c=temp_c, vdd=vdd, corner=corner,
             step_div=step_div, amp_V=amp, codes=codes, conv_clocks=conv,
             f_s=1.0 / (conv * t_clk),
             f_in=m_bin / n_conv / (conv * t_clk))
    return r


def main():
    ap = argparse.ArgumentParser(description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--archs", default="binary10_opt_r,binary10_opt_bootx")
    ap.add_argument("--n", type=int, default=128)
    ap.add_argument("--bins", default="13,61")
    ap.add_argument("--dbfs", type=float, default=-1.0)
    ap.add_argument("--vcm", type=float, default=1.20)
    ap.add_argument("--tclk", type=float, default=20e-9)
    ap.add_argument("--temp", type=float, default=27.0)
    ap.add_argument("--vdd", type=float, default=3.3)
    ap.add_argument("--corner", default="typical")
    ap.add_argument("--switching", default="setup")
    ap.add_argument("--tri-suffix", default="")
    ap.add_argument("--dev-seeds", default="none",
                    help="comma list; 'none' = matched devices")
    ap.add_argument("--step-div", type=int, default=80,
                    help="transient step = t_clk / this (80 -> 250 ps)")
    a = ap.parse_args()

    archs = a.archs.split(",")
    bins = [int(b) for b in a.bins.split(",")]
    for b in bins:
        if math.gcd(b, a.n) != 1:
            raise SystemExit(f"bin {b} is not coprime with N = {a.n}; the "
                             f"tone would not be coherent")
    # conv_clocks depends on arch (N_BITS); if --archs mixes bit counts the
    # banner shows the first one's and each row still carries its own real
    # value (see run_one) -- the banner is informational, the JSON is not.
    _nb0, _h0, _t0, conv0 = _timing_for(archs[0])
    f_s = 1.0 / (conv0 * a.tclk)
    print(f"dynamic test: {a.n} conversions (+{WARMUP} warm-up), "
          f"t_clk {a.tclk*1e9:g} ns, {conv0} clocks/conversion ({archs[0]})")
    print(f"  f_s = {f_s/1e3:.2f} kHz, step = {a.tclk/a.step_div*1e12:.0f} ps,"
          f" amplitude {a.dbfs:+g} dBFS, VCM {a.vcm} V")
    for b in bins:
        print(f"  bin {b:3d} -> f_in = {b/a.n*f_s/1e3:8.2f} kHz "
              f"({2.0*b/a.n*100:.1f} % of Nyquist)")
    dseeds = [None if s == "none" else int(s)
              for s in a.dev_seeds.split(",")]
    jobs = [(ar, a.n, b, a.dbfs, a.vcm, a.tclk, a.temp, a.vdd, a.corner,
             a.step_div, f"{ar[-5:]}_{b}_{ds}", a.switching,
             a.tri_suffix, ds)
            for ar in archs for b in bins for ds in dseeds]
    print(f"  {len(jobs)} runs\n")

    with ThreadPoolExecutor(max_workers=SP.MAX_PARALLEL) as ex:
        rows = list(ex.map(run_one, jobs))

    print("%-20s %6s %5s %10s %8s %8s %8s"
          % ("arch", "devmm", "bin", "f_in kHz", "SNDR", "SFDR", "ENOB"))
    print("-" * 82)
    for r in sorted(rows, key=lambda r: (r["arch"], r["m_bin"],
                                         str(r["dev_seed"]))):
        print("%-20s %6s %5d %10.1f %8.2f %8.2f %8.3f"
              % (r["arch"][:20], str(r["dev_seed"]), r["m_bin"],
                 r["f_in"] / 1e3, r["sndr_dB"], r["sfdr_dB"],
                 r["enob_bits"]))
    # Harmless for the two 10-bit archs this script originally shipped
    # with, misleading for anything else -- redundant12_opt's raw code
    # is 12 bits, so its measured ENOB can legitimately print above a
    # stale 10-bit reference without anything being wrong. Uses the
    # first arch's raw bit count; for a redundant array with fewer
    # distinct code values than 2**nb, the true achievable ceiling is
    # somewhat lower than this -- said explicitly rather than implied.
    _ideal_sndr = 6.02 * _nb0 + 1.76
    print(f"\nideal {_nb0}-bit SNDR is {_ideal_sndr:.2f} dB (ENOB {_nb0:.2f}) "
          f"with a full-scale input (raw bit count for {archs[0]} -- a "
          f"redundant array's true ceiling, fewer distinct codes than "
          f"2**{_nb0}, is somewhat lower than this);\nat {a.dbfs:+g} dBFS "
          f"the ceiling is {_ideal_sndr + a.dbfs:.2f} dB (ENOB "
          f"{(_ideal_sndr + a.dbfs - 1.76)/6.02:.3f}).")
    # The corner is a run-time choice here, so a fixed name lets a second
    # keeps the historic name so existing consumers still resolve; anything
    # else gets a distinct one, which is all collision-freedom requires.
    _dflt = (a.corner == "typical" and abs(a.temp - 27.0) < 1e-9
             and abs(a.vdd - 3.3) < 1e-9)
    _tag = "" if _dflt else f"_{a.corner}_{a.temp:+.0f}C_{a.vdd}V"
    # conv_clocks is per-row (each row's own arch may have a different
    (RESULTS / f"behav_dynamic_{a.switching}{_tag}.json").write_text(
        json.dumps({"settings": vars(a), "rows": rows},
                   indent=2), encoding="utf-8")
    print(f"\n  -> results/behav_dynamic_{a.switching}.json  (peak parallelism "
          f"{SP.peak_parallel()}/{SP.MAX_PARALLEL})")


if __name__ == "__main__":
    main()
