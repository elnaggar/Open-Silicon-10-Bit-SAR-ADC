#!/usr/bin/env python3
# Open-Silicon-SAR-ADC
# Gulu, Ankur Gupta, Ahmed Elnaggar
# Author: Ahmed Elnaggar
"""
plot_dynamic_spectrum.py -- the output spectrum and ENOB-vs-frequency figure
for design #1 (binary10_opt_bootx), read from results/behav_dynamic.json
(produced by sar_dyn.py).

Extracted from the larger report-figure generator this design's campaign
used internally; this is the single figure relevant to the FFT dynamic
test, with no other dependency on that report-building pipeline.
"""
from __future__ import annotations

import json
from pathlib import Path

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt                                  # noqa: E402
import sys as _sys
_sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import plotstyle as PS   # keep_visible: an axis may never crop data

HERE = Path(__file__).resolve().parent
RES = HERE / "results"
OUT = HERE / "plots"
OUT.mkdir(exist_ok=True)

plt.rcParams.update({"figure.dpi": 150, "font.size": 8.5, "axes.grid": True,
                     "grid.alpha": 0.25, "grid.linewidth": 0.5,
                     "axes.spines.top": False, "axes.spines.right": False,
                     "axes.labelsize": 8.5, "axes.titlesize": 9,
                     "legend.fontsize": 7.5, "figure.facecolor": "white"})
BUDGET = dict(color="#c0392b", lw=0.9, ls="--")
C1, C3 = "#1f4e79", "#1a7a3c"


def J(n):
    return json.loads((RES / n).read_text(encoding="utf-8"))


def save(fig, name):
    if len(fig.axes) == 1:
        l = fig.axes[0].get_legend()
        if l:
            l.set_bbox_to_anchor((1.04, 0.5))
            l._loc = 6
            l.set_ncols(1)
    if fig._suptitle is not None:
        fig.tight_layout(rect=[0, 0, 1, 0.92])
    else:
        fig.tight_layout()
    fig.savefig(OUT / name, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(f"  {name}")


def main():
    dy = J("behav_dynamic.json")
    rows = dy["rows"]

    def get(arch, b):
        return next(r for r in rows if r["arch"] == arch and r["m_bin"] == b)

    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.8, 3.6))
    hi = max(r["m_bin"] for r in rows)
    for arch, lab, col in (("binary10_opt_r", "as built", C1),
                           ("binary10_opt_bootx", "bootstrap", C3)):
        r = get(arch, hi)
        x = np.array(r["codes"], float)
        x -= x.mean()
        P = np.abs(np.fft.rfft(x)) ** 2
        P[0] = P.max() * 1e-12
        db = 10 * np.log10(P / P.max())
        f = np.arange(len(db)) / (2.0 * (len(db) - 1))
        a1.plot(f, db, lw=1.0, color=col,
                label=f"{lab}: SNDR {r['sndr_dB']:.1f} dB, "
                      f"ENOB {r['enob_bits']:.2f}")
    a1.set_xlabel("frequency / f$_s$")
    a1.set_ylabel("dBFS")
    PS.keep_visible(a1, "y", -110, 5, label="spectrum [dBFS]")
    a1.legend(frameon=False, loc="lower right")
    a1.set_title(f"Output spectrum at {get('binary10_opt_r', hi)['f_in']/1e3:.0f}"
                 f" kHz\n({2.0*hi/dy['settings']['n']*100:.0f} % of Nyquist, "
                 f"{dy['settings']['n']} coherent conversions)")

    bins = sorted({r["m_bin"] for r in rows})
    x = np.arange(len(bins))
    for i, (arch, lab, col) in enumerate((("binary10_opt_r", "as built", C1),
                                          ("binary10_opt_bootx", "bootstrap",
                                           C3))):
        a2.bar(x + (i - 0.5) * 0.36,
               [get(arch, b)["enob_bits"] for b in bins], 0.36, label=lab,
               color=col)
    ceil = (61.96 + dy["settings"]["dbfs"] - 1.76) / 6.02
    a2.axhline(ceil, label=f"ceiling at {dy['settings']['dbfs']:+g} dBFS",
               **BUDGET)
    a2.set_xticks(x)
    a2.set_xticklabels([f"{2.0*b/dy['settings']['n']*100:.0f} % of Nyquist\n"
                        f"({get('binary10_opt_r', b)['f_in']/1e3:.0f} kHz)"
                        for b in bins], fontsize=7)
    PS.keep_visible(a2, "y", 7.5, 10.2, label="ENOB [bits]")
    a2.set_ylabel("ENOB [bits]")
    a2.legend(frameon=False)
    a2.set_title("ENOB vs. input frequency")
    fig.suptitle("Dynamic performance: output spectrum and ENOB rolloff", y=1.03)
    save(fig, "dynamic_spectrum.png")


if __name__ == "__main__":
    main()
