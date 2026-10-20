#!/usr/bin/env python3
# Open-Silicon-SAR-ADC
# Gulu, Ankur Gupta, Ahmed Elnaggar
# Author: Ahmed Elnaggar
"""
plotstyle.py  —  Shared plotting theme and output options for CDAC testbenches
===============================================================================
Single source of truth for how verification plots look and where they go. Used
by both `split_cdac_verification/tb*/plot_tb*.py` and
`cdac/simulation/analyze_weights.py`.

Why this exists
---------------
Each testbench previously carried its own copy of the same hex colours, its own
`savefig(dpi=200)`, and its own axis handling. Three consequences:

  * PNG at 200 dpi on a near-black background was the only possible output —
    unusable in a printed report and impossible to redirect elsewhere.
  * Several plots pinned their y-axis to the pass limit
    (e.g. `set_ylim(-0.7, 0.7)` for a ±0.5 LSB INL limit), so a FAILING result
    was drawn off-canvas and the plot looked clean. That is the same defect
    class as the result-fallback bugs described in
    `split_cdac_verification/DEPRECATED.md`: a broken measurement rendered as a
    good one.
  * Missing data was coerced to 0.0 in at least one place, which plots as a
    perfect result.

Everything here is built so those three cannot recur:

  `safe_limits()`   always includes the data, even when it blows past the limit
  `peak_abs()`      NaN-safe peak, returns NaN rather than a misleading 0
  `mark_missing()`  draws an explicit banner when data is absent or invalid
  `add_plot_args()` gives every plot script --outdir/--format/--dpi/--theme

Usage
-----
    import sys; sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
    from plotstyle import (THEMES, add_plot_args, apply_theme, new_figure,
                           save_figure, safe_limits, peak_abs, annotate_status)

    ap = argparse.ArgumentParser(); add_plot_args(ap)
    args = ap.parse_args()
    fig, ax = new_figure(args, figsize=(10, 6))
    ...
    save_figure(fig, "tb01_inl_dnl", args)
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np

# ────────────────────────────────────────────────────────────────────────────
# Themes
# ────────────────────────────────────────────────────────────────────────────
# Semantic slots so plot code never names a raw colour. Accent hues are chosen
# to stay legible on both backgrounds.

THEMES = {
    "dark": {
        "fig":     "#0d1117",
        "panel":   "#161b22",
        "fg":      "#ffffff",
        "muted":   "#9da7b3",
        "grid":    "#30363d",
        "spine":   "#30363d",
        "legend":  "#1c2128",
        "ok":      "#3fb950",
        "bad":     "#f85149",
        "warn":    "#d29922",
        "primary": "#58a6ff",
        "accent":  "#39d0d8",
        "series":  ["#58a6ff", "#39d0d8", "#d29922", "#f85149",
                    "#bc8cff", "#3fb950", "#ff9bce", "#8b949e"],
    },
    "light": {
        "fig":     "#ffffff",
        "panel":   "#f6f8fa",
        "fg":      "#1f2328",
        "muted":   "#57606a",
        "grid":    "#d0d7de",
        "spine":   "#8c959f",
        "legend":  "#ffffff",
        "ok":      "#1a7f37",
        "bad":     "#cf222e",
        "warn":    "#9a6700",
        "primary": "#0969da",
        "accent":  "#1b7c83",
        "series":  ["#0969da", "#1b7c83", "#9a6700", "#cf222e",
                    "#8250df", "#1a7f37", "#bf3989", "#57606a"],
    },
}

FORMATS = ("png", "svg", "pdf")


# ────────────────────────────────────────────────────────────────────────────
# CLI
# ────────────────────────────────────────────────────────────────────────────

def add_plot_args(parser: argparse.ArgumentParser) -> argparse.ArgumentParser:
    """Attach the output options every plot script should accept."""
    g = parser.add_argument_group("plot output")
    g.add_argument("--outdir", type=Path, default=None,
                   help="directory for the figure (default: ../plots)")
    g.add_argument("--format", dest="fmt", default="png", choices=FORMATS,
                   help="figure format; svg/pdf are vector, for reports (default png)")
    g.add_argument("--dpi", type=int, default=200,
                   help="raster resolution, ignored for svg/pdf (default 200)")
    g.add_argument("--theme", default="dark", choices=sorted(THEMES),
                   help="colour theme; use light for print (default dark)")
    g.add_argument("--transparent", action="store_true",
                   help="save with a transparent background")
    g.add_argument("--no-show-limits", dest="show_limits", action="store_false",
                   help="omit the pass/fail limit lines")
    return parser


def theme_of(args) -> dict:
    return THEMES[getattr(args, "theme", "dark")]


# ────────────────────────────────────────────────────────────────────────────
# Figure construction
# ────────────────────────────────────────────────────────────────────────────

def apply_theme(fig, axes, args) -> dict:
    """Paint a figure and its axes in the selected theme. Returns the theme."""
    t = theme_of(args)
    fig.patch.set_facecolor(t["fig"])
    for ax in np.atleast_1d(np.asarray(axes, dtype=object)).ravel():
        if ax is None:
            continue
        ax.set_facecolor(t["panel"])
        ax.tick_params(colors=t["muted"], which="both")
        for sp in ax.spines.values():
            sp.set_edgecolor(t["spine"])
        ax.xaxis.label.set_color(t["muted"])
        ax.yaxis.label.set_color(t["muted"])
        ax.title.set_color(t["fg"])
    return t


def new_figure(args, figsize=(10, 6), nrows=1, ncols=1, **kw):
    """`plt.subplots` with the theme already applied."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, axes = plt.subplots(nrows, ncols, figsize=figsize, **kw)
    apply_theme(fig, axes, args)
    return fig, axes


def style_legend(ax, args, **kw):
    t = theme_of(args)
    return ax.legend(facecolor=t["legend"], labelcolor=t["fg"],
                     edgecolor=t["spine"], framealpha=0.85, **kw)


def style_grid(ax, args, axis="both"):
    t = theme_of(args)
    ax.grid(True, axis=axis, color=t["grid"], lw=0.6, ls="--", alpha=0.7)
    ax.set_axisbelow(True)


def suptitle(fig, text, args, **kw):
    t = theme_of(args)
    return fig.suptitle(text, color=t["fg"], fontsize=kw.pop("fontsize", 14),
                        fontweight=kw.pop("fontweight", "bold"), **kw)


# ────────────────────────────────────────────────────────────────────────────
# Axis limits that never hide data
# ────────────────────────────────────────────────────────────────────────────

def safe_limits(data, limits=(), pad=0.15, symmetric=False,
                floor_at_zero=False):
    """Axis limits guaranteed to contain every finite datum AND the limit lines.

    The old code pinned axes to just past the pass limit, so a failing curve was
    drawn outside the axes and the plot looked clean. Never do that: if the data
    exceeds the limit, the axis must grow to show it.

    Parameters
    ----------
    data          : array-like, NaNs ignored
    limits        : pass/fail limit values that must remain visible
    pad           : fractional padding added to the span
    symmetric     : force limits symmetric about zero
    floor_at_zero : clamp the lower bound to 0 (for magnitude-only axes)

    Returns (lo, hi), or None when there is nothing finite to show.
    """
    vals = np.asarray(np.atleast_1d(data), dtype=float).ravel()
    vals = vals[np.isfinite(vals)]
    lims = np.asarray([l for l in np.atleast_1d(limits) if np.isfinite(l)],
                      dtype=float).ravel() if len(np.atleast_1d(limits)) else np.array([])

    pool = np.concatenate([vals, lims]) if len(lims) else vals
    if pool.size == 0:
        return None

    lo, hi = float(np.min(pool)), float(np.max(pool))
    if symmetric:
        m = max(abs(lo), abs(hi))
        lo, hi = -m, m
    span = hi - lo
    if span <= 0:
        span = max(abs(hi), 1.0) * 0.2
    lo -= span * pad
    hi += span * pad
    if floor_at_zero:
        lo = 0.0
    return lo, hi


def peak_abs(data) -> float:
    """NaN-safe peak magnitude. Returns NaN if nothing is finite.

    Deliberately does NOT return 0.0 for empty input — a peak of zero reads as
    a flawless result, which is exactly the lie this codebase kept telling.
    """
    vals = np.asarray(np.atleast_1d(data), dtype=float).ravel()
    vals = vals[np.isfinite(vals)]
    return float(np.max(np.abs(vals))) if vals.size else float("nan")


def coverage(data) -> tuple[int, int]:
    """(finite points, total points) — for reporting how complete a sweep is."""
    vals = np.asarray(np.atleast_1d(data), dtype=float).ravel()
    return int(np.sum(np.isfinite(vals))), int(vals.size)


# ────────────────────────────────────────────────────────────────────────────
# Annotation
# ────────────────────────────────────────────────────────────────────────────

def limit_lines(ax, args, limits, orientation="h", label=None):
    """Draw pass/fail limits, honouring --no-show-limits."""
    if not getattr(args, "show_limits", True):
        return
    t = theme_of(args)
    draw = ax.axhline if orientation == "h" else ax.axvline
    for i, lv in enumerate(np.atleast_1d(limits)):
        draw(lv, color=t["bad"], lw=1.5, ls="--",
             label=label if i == 0 else None)


def annotate_status(ax, args, ok: bool | None, text: str, loc=(0.98, 0.94)):
    """Corner PASS/FAIL/NO-DATA badge.

    `ok=None` renders as an explicit NO DATA warning rather than a pass.
    """
    t = theme_of(args)
    if ok is None:
        tag, colour = "NO DATA", t["warn"]
    elif ok:
        tag, colour = "PASS", t["ok"]
    else:
        tag, colour = "FAIL", t["bad"]
    ax.text(loc[0], loc[1], f"{text}  →  {tag}", transform=ax.transAxes,
            ha="right" if loc[0] > 0.5 else "left", va="top",
            color=colour, fontsize=10, fontweight="bold",
            bbox=dict(facecolor=t["legend"], edgecolor=colour,
                      alpha=0.9, boxstyle="round,pad=0.35"))


def mark_missing(ax, args, n_missing: int, n_total: int):
    """State plainly, on the figure, that part of the data is absent.

    A gap in a curve is easy to miss; a labelled banner is not. Incomplete
    sweeps must never render as if they were complete.
    """
    if n_missing <= 0:
        return
    t = theme_of(args)
    ax.text(0.5, 0.5,
            f"{n_missing} of {n_total} points missing / non-finite",
            transform=ax.transAxes, ha="center", va="center",
            color=t["warn"], fontsize=13, fontweight="bold", alpha=0.85,
            bbox=dict(facecolor=t["fig"], edgecolor=t["warn"],
                      alpha=0.85, boxstyle="round,pad=0.5"))


def no_data_figure(args, title: str, message: str, name: str) -> Path:
    """Emit a figure that says the data is missing, instead of no figure at all.

    A stale PNG from a previous run is worse than an explicit blank, because it
    silently misrepresents the current state of the design.
    """
    fig, ax = new_figure(args, figsize=(9, 5))
    t = theme_of(args)
    ax.set_xticks([]); ax.set_yticks([])
    ax.set_title(title, fontsize=13, fontweight="bold")
    ax.text(0.5, 0.5, message, transform=ax.transAxes, ha="center", va="center",
            color=t["warn"], fontsize=12, fontweight="bold", wrap=True)
    return save_figure(fig, name, args)


# ────────────────────────────────────────────────────────────────────────────
# Output
# ────────────────────────────────────────────────────────────────────────────

def resolve_outdir(args, default: Path) -> Path:
    out = getattr(args, "outdir", None) or default
    out = Path(out)
    out.mkdir(parents=True, exist_ok=True)
    return out


def save_figure(fig, stem: str, args, default_dir: Path | None = None,
                tight: bool = True) -> Path:
    """Save honouring --outdir/--format/--dpi/--transparent, then close."""
    import matplotlib.pyplot as plt

    default_dir = default_dir or getattr(args, "_default_outdir", Path("plots"))
    outdir = resolve_outdir(args, default_dir)
    fmt    = getattr(args, "fmt", "png")
    path   = outdir / f"{stem}.{fmt}"

    if tight:
        try:
            fig.tight_layout()
        except Exception:
            pass  # tight_layout is advisory; never lose a figure over it

    kw = dict(bbox_inches="tight")
    if fmt == "png":
        kw["dpi"] = getattr(args, "dpi", 200)
    if getattr(args, "transparent", False):
        kw["transparent"] = True
    else:
        kw["facecolor"] = fig.get_facecolor()

    fig.savefig(path, format=fmt, **kw)
    plt.close(fig)
    print(f"[plot] {path}")
    return path


def keep_visible(ax, axis="y", lo=None, hi=None, pad=0.02, label=""):
    """Set an axis limit that cannot hide data that is already plotted.

    `safe_limits()` above is the right tool when you hold the data.  This is
    figure script that calls `set_ylim(0, 5.4)` on an axis whose artists are
    already drawn, and clips the one point the panel exists to show.

    Matplotlib already tracks what was drawn, in `ax.dataLim`, so the limit
    can be widened to include it without the caller passing the data twice.
    The requested bound is honoured as a MINIMUM extent, never as a crop.
    When it has to grow, it says so on stdout -- a silently widened axis is
    still a surprise, just a survivable one.
    """
    box = ax.dataLim
    dlo, dhi = (box.intervaly if axis == "y" else box.intervalx)
    if not (np.isfinite(dlo) and np.isfinite(dhi)):
        dlo, dhi = lo, hi                     # nothing drawn yet; trust caller
    want_lo = dlo if lo is None else min(lo, dlo)
    want_hi = dhi if hi is None else max(hi, dhi)
    if want_lo is None or want_hi is None:
        return None
    # A log axis must be padded geometrically.  Padding it linearly takes a
    # fraction of the FULL span off the bottom, which on a decade scale can
    # drag the lower bound towards zero and wreck the plot -- or go negative
    # and raise.  Same intent, multiplicative arithmetic.
    log = (ax.get_yscale() if axis == "y" else ax.get_xscale()) == "log"
    if log and want_lo > 0 and want_hi > 0:
        f = (want_hi / want_lo) ** pad
        want_lo, want_hi = want_lo / f, want_hi * f
    else:
        span = (want_hi - want_lo) or 1.0
        want_lo, want_hi = want_lo - pad * span, want_hi + pad * span
    grew = ((lo is not None and want_lo < lo - 1e-12)
            or (hi is not None and want_hi > hi + 1e-12))
    if grew:
        print(f"  [axis] {label or ax.get_ylabel() or 'axis'}: requested "
              f"{axis}=({lo}, {hi}) would clip the data; widened to "
              f"({want_lo:.4g}, {want_hi:.4g})")
    (ax.set_ylim if axis == "y" else ax.set_xlim)(want_lo, want_hi)
    return want_lo, want_hi
