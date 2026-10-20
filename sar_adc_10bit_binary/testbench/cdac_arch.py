#!/usr/bin/env python3
# Open-Silicon-SAR-ADC
# Gulu, Ankur Gupta, Ahmed Elnaggar
# Author: Ahmed Elnaggar
"""
cdac_arch.py  —  Exact charge-domain model of the four CDAC architectures
===========================================================================
Shared model used by analyze_weights.py and the ported TB05/TB07/TB08.

Topology
--------
Every array here is a two-node split ladder (the plain binary array is the
degenerate case with no LSB sub-array):

      LSB caps ──┬── VLSB ──[ C_b ]── VOUT ──┬── MSB caps
                 │                            │
              dummy_L                      dummy_M

All bottom plates are driven to 0 or VREF, so for a small-signal perturbation
every non-switching cap is a capacitance to AC ground.

Exact weights (derived, not assumed)
------------------------------------
Let C_L = dummy_L + Σ(LSB caps), C_M = dummy_M + Σ(MSB caps), C_b the bridge.

Charge conservation on the two floating top plates gives, for a bottom-plate
step ΔV:

  MSB cap C_k:   ΔV_out = ΔV · C_k / [ C_M + C_b·C_L/(C_b + C_L) ]
  LSB cap C_k:   ΔV_out = ΔV · C_k · C_b / [ C_M·C_L + C_b·(C_M + C_L) ]

The second expression is identical to C_k·α/C_eff with
α = C_b/(C_b + C_L) and C_eff = C_M + C_b·C_L/(C_b + C_L), which is how it is
written below. Both forms are verified against each other in the self-test.

Fully differential operation doubles the swing, hence the factor 2·VREF.

Bridge sizing
-------------
Exact binary continuation across the bridge requires the largest LSB cap,
referred through the bridge, to equal half the smallest MSB cap:

    m_max · α = 1/2        with α = C_b/(C_b + C_L)

For the 5+5 array (C_L = 32·Cu, m_max = 16) that gives C_b = 32/31 = 1.0323·Cu,
i.e. a cap_mim length of 5.161 µm. The netlists use **L = 5.24 µm → 1.048·Cu**,
a **+1.53 % bridge error**, which is a deterministic linearity error present in
`split_cdac.spice` and `split_cdac_11bit.spice` before any mismatch. The
12-bit array avoids the issue entirely with an integer m=2 bridge.
`BRIDGE_IDEAL` records the intended value so the two can be compared.
"""

from __future__ import annotations

import numpy as np

VREF     = 2.027
# ── cap_mim_2f0fF, straight from the PDK model card ───────────────────────
# sm141064.ngspice, .subckt cap_mim_2f0ff:
#     c_c0 = c_cox*c_area + c_capsw*c_peri
#     c_cox   = 1.99e-3  F/m^2  = 1.99   fF/µm^2
#     c_capsw = 2.383e-10 F/m   = 0.2383 fF/µm
#
# The perimeter term is NOT negligible. At the 5x5 µm unit cell it contributes
# 4.77 fF of 54.52 fF — 8.7 % — so the cell is NOT the 2.0 fF/µm^2 * 25 µm^2 =
# 50 fF that a density figure suggests, and capacitance is NOT proportional to
# area. Measured in ngspice: 54.518 fF at 5x5, 106.652 fF at 5x10 (x1.956 for
# x2.0 the area), 28.450 fF at 5x2.5 (x0.522 for x0.5 the area).
#
# Consequence for the design: exact capacitor RATIOS are only obtainable from
# `m` parallel copies of one identical cell, never by scaling a dimension.
# redundant12's m=2 bridge is exact for this reason; a single 5.169 µm device
# is not.
C_COX_FF_UM2  = 1.99          # fF/µm^2, area term
C_CAPSW_FF_UM = 0.2383        # fF/µm,   perimeter (fringe) term

# DRC MIMTM.8a (gf180mcuD selects mim_option 'B'; MIM-A's MIM.8a is identical)
MIM_MIN_AREA_UM2 = 25.0
MIM_MAX_AREA_UM2 = 10_000.0

CU_W_UM = 5.0                 # the unit cell sits exactly on the DRC floor:
CU_L_UM = 5.0                 # 5 x 5 = 25 µm^2. It cannot be made smaller.

# Cu IS IRREDUCIBLE FOR THIS DESIGN. Two independent limits pin it:
#   * 25 µm^2 is the DRC minimum MIM area (MIMTM.8a), and the cell is on it;
#   * 2.0 fF/µm^2 is the only MIM module available here. The PDK also models
#     1.5 and 1.0 fF/µm^2 cells (which would give 44.33 fF and 31.28 fF at
#     the same area) but those are optional process adders and are not
#     available for this design.
# So switched charge cannot be reduced by capacitor sizing at all, and the
# design must actually meet. cap_drc.py enforces both limits.


def mim_cap_F(w_um: float, l_um: float, check_drc: bool = True) -> float:
    """cap_mim_2f0fF capacitance [F] for a drawn geometry, per the PDK model.

    Raises if the geometry breaks MIMTM.8a/8b: the ngspice model is a formula
    with no enforced limits and will happily return a value for a device that
    cannot be manufactured, which is exactly how the 12.5 µm^2 "half-area"
    array came to be simulated and believed.
    """
    area = w_um * l_um
    # check_drc=False is for MISMATCH modelling only. Mismatch is a
    # fabrication variation of a device that is drawn legally, so a
    # perturbed capacitance is not a layout rule violation -- the length is
    # only a vehicle for expressing a capacitance to the ngspice model.
    # Never disable it for a geometry that is actually drawn.
    if check_drc and area < MIM_MIN_AREA_UM2 - 1e-9:
        raise ValueError(
            f"cap_mim {w_um} x {l_um} µm = {area:.3f} µm^2 violates "
            f"MIMTM.8a (minimum MIM area {MIM_MIN_AREA_UM2:g} µm^2). The "
            f"5x5 µm unit cell is already on the floor.")
    if check_drc and area > MIM_MAX_AREA_UM2 + 1e-9:
        raise ValueError(
            f"cap_mim {w_um} x {l_um} µm = {area:.1f} µm^2 violates "
            f"MIMTM.8b (maximum {MIM_MAX_AREA_UM2:g} µm^2); use parallel caps.")
    peri = 2.0 * (w_um + l_um)
    return (C_COX_FF_UM2 * area + C_CAPSW_FF_UM * peri) * 1e-15


def mim_length_for_ratio(ratio: float, w_um: float = CU_W_UM,
                         check_drc: bool = True) -> float:
    """Drawn length [µm] giving `ratio` times the unit cell, fringe included.

    Solving c_cox*w*L + c_capsw*2*(w+L) = ratio * C_unit for L. Using
    term and lands 0.14 % low at ratio 32/31.
    """
    target = ratio * mim_cap_F(w_um, CU_L_UM, check_drc) * 1e15   # fF
    # c = c_cox*w*L + c_capsw*2*(w + L)
    #   = (c_cox*w + 2*c_capsw) * L  +  2*c_capsw*w
    # The perimeter contributes to BOTH terms; dropping its factor of 2 in
    # the L coefficient puts the answer 2.3 % long.
    a = C_COX_FF_UM2 * w_um + 2.0 * C_CAPSW_FF_UM    # coefficient of L
    b = 2.0 * C_CAPSW_FF_UM * w_um                   # constant term
    return (target - b) / a


CU_F = mim_cap_F(CU_W_UM, CU_L_UM)   # 54.516 fF (ngspice: 54.518 fF)
N_OUT    = 10                # target resolution
N_LEVELS = 1 << N_OUT        # 1024 output codes

# Pelgrom coefficient for cap_mim at W=L=5 µm: 2.5 % sigma on ONE unit cell.
# A cap built from m parallel unit cells averages down as 1/sqrt(m).
SIGMA_UNIT_PCT = 2.5

# Geometric bridge ratio actually in the netlists (cap_mim is area-dominated at
# these sizes, so C scales as W·L): 5.24 µm / 5.0 µm.
# Ratios to the unit cell, computed through the real model rather than from
# length alone. The as-drawn 5.24 µm bridge is 1.0459 Cu, not 5.24/5 = 1.048.
BRIDGE_NETLIST = mim_cap_F(CU_W_UM, 5.24) / CU_F
BRIDGE_IDEAL   = 32.0 / 31.0         # 1.03226 — exact binary continuation


ARCHS: dict[str, dict] = {
    "binary10": {
        "label":     "Binary CDAC (10-bit, unsplit)",
        "netlist":   "diff_cdac.spice",
        "driver":    "cdac_driver_array",
        "dummy_ports": False,      # no DUMMY_P/DUMMY_N in the port list
        "lsb":       [],
        "dummy_lsb": 0.0,
        "bridge":    None,                     # no bridge, single array
        "msb":       [1, 2, 4, 8, 16, 32, 64, 128, 256, 512],
        "dummy_msb": 1.0,                      # XLSB_dummy_n sits on VOUT_N
        "redundant": False,
    },
    "split10": {
        "label":     "Split binary CDAC (5 MSB + 5 LSB)",
        "netlist":   "split_cdac.spice",
        "dummy_ports": True,
        "driver":    "cdac_driver_array",
        "lsb":       [1, 2, 4, 8, 16],
        "dummy_lsb": 1.0,
        "bridge":    BRIDGE_NETLIST,
        "msb":       [1, 2, 4, 8, 16],
        "dummy_msb": 0.0,                      # no MSB dummy in this netlist
        "redundant": False,
    },
    "redundant11": {
        "label":     "Redundant split CDAC (11-bit, sub-radix)",
        "netlist":   "split_cdac_11bit.spice",
        "dummy_ports": True,
        "driver":    "cdac_driver_array_11bit",
        "lsb":       [1, 2, 4, 8, 16],
        "dummy_lsb": 1.0,
        "bridge":    BRIDGE_NETLIST,
        "msb":       [1, 1, 2, 4, 8, 16],      # duplicated m=1 = the redundancy
        "dummy_msb": 0.0,
        "redundant": True,
    },
    "redundant12": {
        "label":     "Redundant split CDAC (12-bit, integer bridge)",
        "netlist":   "split_cdac_12bit.spice",
        "dummy_ports": True,
        "driver":    "cdac_driver_array_12bit",
        "lsb":       [1, 2, 4, 8, 16, 32],
        "dummy_lsb": 1.0,
        "bridge":    2.0,                      # m=2 at L=5 µm — exactly 2·Cu
        "msb":       [1, 2, 4, 8, 16, 32],
        "dummy_msb": 1.0,
        "redundant": True,
    },
}


# ── Optimized variants ──────────────────────────────────────────────────────
# Generated by make_optimized.py from the as-built netlists above. The as-built
# entries are kept so the improvement stays measurable. Differences:
#   drivers sized per-bit from a real droop/settling sweep, uniform
ARCHS["binary10_opt"] = dict(
    ARCHS["binary10"],
    label="Binary CDAC (10-bit), optimized",
    netlist="diff_cdac_opt.spice",
    driver="cdac_driver_array_opt",
)
ARCHS["split10_opt"] = dict(
    ARCHS["split10"],
    label="Split binary CDAC (5+5), optimized",
    netlist="split_cdac_opt.spice",
    driver="cdac_driver_array_split_opt",
    bridge=BRIDGE_IDEAL,          # the whole point of the fix
)
# redundant12_cu25 (Cu = 25 fF, c_length 2.5 µm) was REMOVED: 5 x 2.5 µm
# is 12.5 µm^2, half the DRC minimum MIM area of 25 µm^2 (MIMTM.8a). It
# The only legal route to a smaller unit capacitor is the 1.0 fF/µm^2 MIM
# mask option (31.28 fF at the same 25 µm^2), which is an optional
# process adder, not a layout change.
ARCHS["redundant12_opt"] = dict(
    ARCHS["redundant12"],
    label="Redundant split CDAC (12-bit), optimized",
    netlist="split_cdac_12bit_opt.spice",
    driver="cdac_driver_array_12bit_opt",
)

# ────────────────────────────────────────────────────────────────────────────
# Verification cases
# ────────────────────────────────────────────────────────────────────────────
# A *case* is an architecture plus a digital-backend mode. Cases 3 and 4 share
# one netlist and differ only in whether the backend knows the measured
# capacitor weights, so any purely analog measurement (droop, slew, charge
# injection, PSRR) is identical between them and is computed once and reused.
# Only the code-mapping measurements (ENOB, static INL) actually differ.

ARCHS["redundant12_bbm"] = dict(
    ARCHS["redundant12_opt"],
    label="Redundant split CDAC (12-bit), optimized, break-before-make drivers",
    driver="cdac_driver_array_12bit_bbm",
)
ARCHS["redundant12_nmos"] = dict(
    ARCHS["redundant12_opt"],
    label="Redundant split CDAC (12-bit), optimized, NMOS-only top-plate switch",
    netlist="split_cdac_12bit_nmos.spice",
)

ARCHS["redundant12_boot"] = dict(
    ARCHS["redundant12_opt"],
    label="Redundant split CDAC (12-bit), optimized, ideal bootstrapped top-plate switch",
    netlist="split_cdac_12bit_boot.spice",
)

ARCHS["redundant12_nmos2"] = dict(
    ARCHS["redundant12_opt"],
    label="Redundant split CDAC (12-bit), optimized, NMOS-only switch and dummy",
    netlist="split_cdac_12bit_nmos2.spice",
)

ARCHS["binary10_opt_r"] = dict(
    ARCHS["binary10_opt"],
    label=ARCHS["binary10_opt"].get("label", "binary10_opt")
          + ", PVT-robust switch",
    netlist="diff_cdac_opt_r.spice",
)

ARCHS["split10_opt_r"] = dict(
    ARCHS["split10_opt"],
    label=ARCHS["split10_opt"].get("label", "split10_opt")
          + ", PVT-robust switch",
    netlist="split_cdac_opt_r.spice",
)

ARCHS["binary10_opt_boot"] = dict(
    ARCHS["binary10_opt_r"],
    label=ARCHS["binary10_opt_r"].get("label", "binary10_opt_r")
          + ", ideal bootstrapped sampling switch",
    netlist="diff_cdac_opt_boot.spice",
)

ARCHS["binary10_opt_bootx"] = dict(
    ARCHS["binary10_opt_r"],
    label=ARCHS["binary10_opt_r"].get("label", "binary10_opt_r")
          + ", transistor-level bootstrapped sampling switch",
    netlist="diff_cdac_opt_bootx.spice",
)

ARCHS["binary10_opt_bootx_c12"] = dict(
    ARCHS["binary10_opt_bootx"],
    netlist="diff_cdac_opt_bootx_c12.spice",
)

ARCHS["binary10_opt_bootx_c12h"] = dict(
    ARCHS["binary10_opt_bootx"],
    netlist="diff_cdac_opt_bootx_c12h.spice",
)

ARCHS["binary10_opt_bootx_c24h"] = dict(
    ARCHS["binary10_opt_bootx"],
    netlist="diff_cdac_opt_bootx_c24h.spice",
)

# True V_CM-based (MCS) switching on the same netlist/driver, cap/32 output
# sweep) and results/behav_dynamic_mcs_real.json already characterizes
# dynamically (ENOB 9.66, with mismatch seeds), but which was never given
# its own ARCHS entry, so no driver script could select it by name. See
ARCHS["binary10_opt_bootx_c24h_mcs"] = dict(
    ARCHS["binary10_opt_bootx_c24h"],
    label=ARCHS["binary10_opt_bootx_c24h"].get("label", "binary10_opt_bootx_c24h")
          + ", true V_CM-based MCS switching, cap/32 driver (F-31)",
    switching="mcs_real",
    tri_suffix="_d32",
)

ARCHS["binary10_opt_bootx_c24h_w"] = dict(
    ARCHS["binary10_opt_bootx"],
    netlist="diff_cdac_opt_bootx_c24h_w.spice",
)

ARCHS["binary10_opt_bootx_c24h_wm2"] = dict(
    ARCHS["binary10_opt_bootx"],
    netlist="diff_cdac_opt_bootx_c24h_wm2.spice",
)

ARCHS["binary10_opt_bootx_c24h_e7"] = dict(
    ARCHS["binary10_opt_bootx"],
    netlist="diff_cdac_opt_bootx_c24h_e7.spice",
)

ARCHS["binary10_opt_bootx_c24h_e10"] = dict(
    ARCHS["binary10_opt_bootx"],
    netlist="diff_cdac_opt_bootx_c24h_e10.spice",
)

ARCHS["binary10_opt_bootx_c32n4e13"] = dict(
    ARCHS["binary10_opt_bootx"],
    netlist="diff_cdac_opt_bootx_c32n4e13.spice",
)

CASES: dict[str, dict] = {
    "case1_binary_uncal": {
        "label":      "Binary-weighted CDAC, uncalibrated",
        "short":      "binary-uncal",
        "arch":       "binary10",
        "calibrated": False,
    },
    "case2_split_uncal": {
        "label":      "Split binary CDAC, uncalibrated",
        "short":      "split-uncal",
        "arch":       "split10",
        "calibrated": False,
    },
    "case3_redundant_uncal": {
        "label":      "Split CDAC with redundancy, uncalibrated",
        "short":      "redundant-uncal",
        "arch":       "redundant12",
        "calibrated": False,
    },
    "case4_redundant_cal": {
        "label":      "Split CDAC with redundancy + foreground calibration",
        "short":      "redundant-cal",
        "arch":       "redundant12",
        "calibrated": True,
    },
}


# ── Optimized counterparts of the four cases ────────────────────────────────
CASES["case1o_binary_opt"] = {
    "label":      "Binary-weighted CDAC, optimized, uncalibrated",
    "short":      "binary-opt",
    "arch":       "binary10_opt",
    "calibrated": False,
}
CASES["case2o_split_opt"] = {
    "label":      "Split binary CDAC, optimized, uncalibrated",
    "short":      "split-opt",
    "arch":       "split10_opt",
    "calibrated": False,
}
CASES["case3o_redundant_opt"] = {
    "label":      "Split CDAC with redundancy, optimized, uncalibrated",
    "short":      "redundant-opt",
    "arch":       "redundant12_opt",
    "calibrated": False,
}
CASES["case4o_redundant_opt_cal"] = {
    "label":      "Split + redundancy + calibration, optimized",
    "short":      "redundant-opt-cal",
    "arch":       "redundant12_opt",
    "calibrated": True,
}

# Measurements whose result depends on the backend mode, not just the array.
CALIBRATION_SENSITIVE = {"enob"}


def case_arch(case: str) -> str:
    return CASES[case]["arch"]


def case_is_calibrated(case: str) -> bool:
    return CASES[case]["calibrated"]


def cases_for_arch(arch: str) -> list[str]:
    return [c for c, v in CASES.items() if v["arch"] == arch]


# Extraction testbenches only exist for these.
# Bit count doubles as the filename tag: extract_<tag>bit_<seed>.spice
HAS_EXTRACTION = {"redundant11": "11", "redundant12": "12",
                  "redundant12_opt": "12opt"}


def n_bits(arch: str) -> int:
    a = ARCHS[arch]
    return len(a["lsb"]) + len(a["msb"])


# ────────────────────────────────────────────────────────────────────────────
# Exact weight model
# ────────────────────────────────────────────────────────────────────────────

def weights_from_caps(c_lsb, dummy_lsb, c_bridge, c_msb, dummy_msb) -> np.ndarray:
    """Differential weight per bit [V], LSB-first, from actual cap values.

    Capacitances are in units of Cu (any consistent unit works — only ratios
    matter). Accepts perturbed values, which is what the Monte Carlo uses.
    """
    c_lsb = np.asarray(c_lsb, dtype=float)
    c_msb = np.asarray(c_msb, dtype=float)

    C_L = float(dummy_lsb) + float(c_lsb.sum())
    C_M = float(dummy_msb) + float(c_msb.sum())

    if c_bridge is None or c_lsb.size == 0:
        # Single array: every cap sits directly on the output node.
        C_eff = C_M
        return 2.0 * VREF * c_msb / C_eff

    c_b   = float(c_bridge)
    alpha = c_b / (c_b + C_L)
    C_eff = C_M + c_b * C_L / (c_b + C_L)
    k     = 2.0 * VREF / C_eff
    return np.concatenate([c_lsb * alpha * k, c_msb * k])


def nominal_weights(arch: str, bridge: float | None = "as-is") -> np.ndarray:
    """Ideal-capacitor weights. `bridge` overrides the netlist value."""
    a = ARCHS[arch]
    cb = a["bridge"] if bridge == "as-is" else bridge
    return weights_from_caps(a["lsb"], a["dummy_lsb"], cb, a["msb"], a["dummy_msb"])


def alpha_of(arch: str, bridge: float | None = "as-is") -> float:
    """Bridge attenuation, 0 for an unsplit array."""
    a  = ARCHS[arch]
    cb = a["bridge"] if bridge == "as-is" else bridge
    if cb is None or not a["lsb"]:
        return 0.0
    C_L = a["dummy_lsb"] + sum(a["lsb"])
    return cb / (cb + C_L)


def total_cap_F(arch: str) -> float:
    """Effective sampling capacitance per side [F] — sets kT/C and droop."""
    a   = ARCHS[arch]
    C_L = a["dummy_lsb"] + sum(a["lsb"])
    C_M = a["dummy_msb"] + sum(a["msb"])
    cb  = a["bridge"]
    cu  = a.get("cu_F", CU_F)      # per-architecture unit capacitor
    if cb is None or not a["lsb"]:
        return C_M * cu
    return (C_M + cb * C_L / (cb + C_L)) * cu


def switched_charge_C(arch: str) -> float:
    """Worst-case charge drawn from VREF in one full-scale transition [C].

    Every bottom plate slews by VREF, so the charge is VREF times the sum of
    all switched capacitors (the dummies and bridge do not switch). This is
    what sets reference droop, and it is why array size matters for TB05.
    """
    a = ARCHS[arch]
    return VREF * (sum(a["lsb"]) + sum(a["msb"])) * a.get("cu_F", CU_F)


# ────────────────────────────────────────────────────────────────────────────
# Code mapping and DAC linearity
# ────────────────────────────────────────────────────────────────────────────

def _all_patterns(nb: int) -> np.ndarray:
    codes = np.arange(1 << nb, dtype=np.int64)
    return ((codes[:, None] >> np.arange(nb)) & 1).astype(np.float64)


def dac_levels(w_meas: np.ndarray, w_assumed: np.ndarray,
               redundant: bool) -> np.ndarray:
    """Analog level produced for each of the 1024 output codes.

    The digital backend decides which raw bit pattern represents output code k,
    using the weights it BELIEVES (`w_assumed`); the array then produces the
    level set by the weights it actually HAS (`w_meas`).

      * non-redundant (10 raw bits, 1024 codes): the map is 1:1 binary. There
        is no freedom, so digital calibration cannot change the transfer curve
        at all — uncalibrated and calibrated are identical by construction.
      * redundant (11 or 12 raw bits): more patterns than codes, so the backend
        picks, per code, the pattern whose assumed level is closest to the
        target. That is exactly what a foreground-calibration lookup does.
    """
    nb = len(w_assumed)
    if not redundant:
        if (1 << nb) != N_LEVELS:
            raise ValueError(
                f"non-redundant array has {nb} bits = {1<<nb} codes, "
                f"expected {N_LEVELS}")
        B = _all_patterns(nb)                       # already in code order
        return B @ w_meas

    targets = np.arange(N_LEVELS) * (w_assumed.sum() / (N_LEVELS - 1))
    B_all   = _all_patterns(nb)
    lv      = B_all @ w_assumed
    order   = np.argsort(lv)
    lv, B_s = lv[order], B_all[order]

    j = np.clip(np.searchsorted(lv, targets), 1, len(lv) - 1)
    pick = np.where(np.abs(lv[j] - targets) < np.abs(lv[j - 1] - targets), j, j - 1)
    return B_s[pick] @ w_meas


def best_fit_inl_dnl(levels: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    """INL/DNL in LSB against a best-fit line — removes gain and offset error."""
    idx = np.arange(len(levels))
    slope, offset = np.polyfit(idx, levels, 1)
    if slope == 0:
        raise ValueError("degenerate transfer curve (zero slope)")
    inl = (levels - (slope * idx + offset)) / slope
    dnl = np.diff(levels) / slope - 1.0
    return inl, dnl


def selection_floor_lsb(w: np.ndarray, redundant: bool) -> float:
    """Analytic estimate of the best INL any digital backend can reach.

    Non-redundant: the code map is exact, so there is no selection residual and
    the floor is 0 — all INL is weight error.

    Redundant: the achievable level set is not uniform, so the backend must
    round each target to the nearest reachable level. The rounding residual is
    bounded by half the largest gap in that set.

    Two caveats make this an *estimate* rather than a hard lower bound on the
    reported INL, and both are small:

      * the LSB here is FS/(N-1), matching the spacing of the target grid in
        `dac_levels`. Using FS/N instead would introduce a 1/1023 bias.
      * INL is measured against a BEST-FIT line, which absorbs a little of the
        rounding residual as gain/offset. Measured peak INL can therefore sit a
        fraction of a percent below this figure.

    The self-test asserts agreement within 5 % in either direction, which is
    what validates the model; a large gap above the floor is real deterministic
    error (bridge mis-sizing), not rounding.
    """
    if not redundant:
        return 0.0
    lv = np.sort(_all_patterns(len(w)) @ w)
    max_gap = float(np.max(np.diff(lv)))
    lsb_ref = float(w.sum()) / (N_LEVELS - 1)
    return 0.5 * max_gap / lsb_ref


def redundancy_margin(w: np.ndarray) -> dict:
    """No-missing-code analysis.

    The authoritative test measures the achievable level set directly: the
    array has no missing codes at 10-bit resolution when the largest gap
    between adjacent reachable levels is at most 1 LSB10.

    The per-bit condition w[i] <= Σ_{j<i} w[j] + w[0] is reported as a
    diagnostic (it localises which bit is marginal), but it is NOT used as the
    verdict: for an exactly-binary array the condition holds with slack
    identically zero, and floating-point rounding then makes a strict `>= 0`
    test fail on ~1e-18. The measured level set has no such sensitivity.
    """
    lsb    = float(w[0])
    below  = np.concatenate(([0.0], np.cumsum(w)[:-1]))
    slack  = below + lsb - w
    worst  = int(np.argmin(slack))
    tol    = 1e-9 * lsb

    lv      = np.sort(_all_patterns(len(w)) @ w)
    max_gap = float(np.max(np.diff(lv)))
    lsb10   = float(w.sum()) / (N_LEVELS - 1)

    return {
        "all_codes_reachable":   bool(max_gap <= lsb10 * (1 + 1e-9)),
        "max_level_gap_lsb10":   round(max_gap / lsb10, 5),
        "max_level_gap_vs_step": round(max_gap / lsb, 5),
        "distinct_levels":       int(np.unique(np.round(lv, 12)).size),
        "n_patterns":            int(lv.size),
        "tightest_bit":          worst,
        "tightest_slack_steps":  round(float(slack[worst] / lsb), 6),
        "per_bit_condition_ok":  bool(np.all(slack >= -tol)),
    }


def evaluate(w_meas: np.ndarray, w_nom: np.ndarray, redundant: bool) -> dict:
    """Uncalibrated and calibrated DAC INL/DNL for one weight set."""
    out = {}
    for tag, assumed in (("uncalibrated", w_nom), ("calibrated", w_meas)):
        inl, dnl = best_fit_inl_dnl(dac_levels(w_meas, assumed, redundant))
        out[tag] = {
            "inl_peak_lsb": round(float(np.max(np.abs(inl))), 4),
            "dnl_peak_lsb": round(float(np.max(np.abs(dnl))), 4),
            "pass_inl":     bool(np.max(np.abs(inl)) < 0.5),
            "pass_dnl":     bool(np.max(np.abs(dnl)) < 1.0),
            "_inl":         inl,
        }
    return out


# ────────────────────────────────────────────────────────────────────────────
# Static-limited ENOB
# ────────────────────────────────────────────────────────────────────────────

def intent_weights(arch):
    """Weights the digital backend is DESIGNED to expect.

    Not the same as `nominal_weights`: the 5+5 and 11-bit netlists carry a
    +1.53% bridge error (L=5.24 um where exact binary continuation needs
    32/31 = 1.0323*Cu), and a backend built to the design intent does not know
    about it. Assuming the erroneous value would cancel the error against
    itself and hide it. The 12-bit array's m=2 bridge is already exact, so
    intent and nominal coincide there.
    """
    a = ARCHS[arch]
    if a["bridge"] is not None and abs(a["bridge"] - BRIDGE_NETLIST) < 1e-12:
        return nominal_weights(arch, bridge=BRIDGE_IDEAL)
    return nominal_weights(arch)


def adc_enob(w_meas, w_assumed, redundant, n=4096, cycles=401, amp=0.99,
             out_bits=N_OUT):
    """SNDR / ENOB of a near-full-scale sine through the STATIC transfer curve.

    Includes
    --------
    quantisation of the achievable level set, truncation to the `out_bits`
    output word, and every distortion term arising from capacitor weight error
    (i.e. this array's INL, expressed spectrally).

    Excludes
    --------
    everything dynamic: incomplete settling, reference droop, sampling-switch
    charge injection, comparator noise and offset, clock jitter, kT/C noise.
    A measured dynamic ENOB is therefore always LOWER than this. Treat it as the
    ceiling the array's linearity sets, not a prediction of silicon.

    Model
    -----
    Coherently sampled sine (`cycles` prime and coprime with `n`, so a
    rectangular window is exact and there is no leakage to correct). For each
    sample the converter settles to the nearest level the array can physically
    produce (`w_meas`); the backend interprets that pattern with the weights it
    believes (`w_assumed`) and emits an `out_bits` word. Two figures come out:

      enob_bits        after truncation to the output word — the deliverable
      enob_recon_bits  before truncation — headroom the array's linearity has

    For an over-ranged array (a redundant one whose finest step is below
    1 LSB_out) the second exceeds `out_bits` while the first cannot.
    """
    w_meas = np.asarray(w_meas, dtype=float)
    w_assumed = np.asarray(w_assumed, dtype=float)
    nb = len(w_meas)

    B_all = _all_patterns(nb)
    lv = B_all @ w_meas
    order = np.argsort(lv)
    lv, B = lv[order], B_all[order]

    fs_meas = float(lv[-1])
    k = np.arange(n)
    vin = 0.5 * fs_meas * (1.0 + amp * np.sin(2.0 * np.pi * cycles * k / n))

    j = np.clip(np.searchsorted(lv, vin), 1, len(lv) - 1)
    pick = np.where(np.abs(lv[j] - vin) < np.abs(lv[j - 1] - vin), j, j - 1)

    recon = B[pick] @ w_assumed              # backend's voltage estimate
    n_out = (1 << out_bits) - 1
    lsb_out = float(w_assumed.sum()) / n_out
    code = np.clip(np.round(recon / lsb_out), 0, n_out)
    out = code * lsb_out                     # the out_bits output word

    def sndr_of(sig_series):
        spec = np.abs(np.fft.rfft(sig_series - sig_series.mean())) ** 2
        spec[0] = 0.0
        s = float(spec[cycles])
        nz = float(spec.sum() - s)
        if nz <= 0:
            return float("inf"), float("inf")
        other = spec.copy()
        other[cycles] = 0.0
        return (10.0 * np.log10(s / nz),
                10.0 * np.log10(s / max(float(other.max()), 1e-300)))

    sndr, sfdr = sndr_of(out)
    sndr_r, _ = sndr_of(recon)
    return {"sndr_dB": round(float(sndr), 3),
            "enob_bits": round(float((sndr - 1.76) / 6.02), 3),
            "sfdr_dB": round(float(sfdr), 3),
            "enob_recon_bits": round(float((sndr_r - 1.76) / 6.02), 3)}


# ────────────────────────────────────────────────────────────────────────────
# Analytic mismatch Monte Carlo
# ────────────────────────────────────────────────────────────────────────────

def mc_weights(arch: str, rng, sigma_unit_pct: float | None = None):
    """One mismatch draw: perturb every capacitor, then re-derive the weights.

    Pelgrom: a cap of m parallel unit cells has sigma_C/C = sigma_unit/sqrt(m).
    Every instance is drawn independently, including the dummies and the bridge
    — the bridge is a single m=1 or m=2 device and is therefore one of the
    noisiest elements in the array, which is precisely why its ratio matters.
    """
    a = ARCHS[arch]
    if sigma_unit_pct is None:
        # A smaller unit cell mismatches more: sigma scales as 1/sqrt(area).
        sigma_unit_pct = a.get("sigma_unit_pct", SIGMA_UNIT_PCT)
    s = sigma_unit_pct / 100.0

    def draw(m):
        m = float(m)
        return m * (1.0 + rng.normal(0.0, s / np.sqrt(m))) if m > 0 else 0.0  # zero-ok: a zero-size capacitor has zero mismatch

    c_lsb = [draw(m) for m in a["lsb"]]
    c_msb = [draw(m) for m in a["msb"]]
    d_l   = draw(a["dummy_lsb"])
    d_m   = draw(a["dummy_msb"])
    c_b   = None if a["bridge"] is None else draw(a["bridge"])
    return weights_from_caps(c_lsb, d_l, c_b, c_msb, d_m)


def mc_inl(arch: str, n: int, seed: int = 0,
           sigma_unit_pct: float = SIGMA_UNIT_PCT) -> dict:
    """INL distribution under capacitor mismatch, uncalibrated and calibrated.

    Analytic rather than SPICE-based, so thousands of samples are cheap. That
    matters: 10 SPICE seeds cannot support a yield claim (10/10 clean gives
    only a ~74 % lower bound at 95 % confidence), whereas n = 2000 pins yield
    to roughly +/-1 %.
    """
    a     = ARCHS[arch]
    w_nom = nominal_weights(arch)
    rng   = np.random.default_rng(seed)
    peaks = {"uncalibrated": [], "calibrated": []}

    for _ in range(n):
        w = mc_weights(arch, rng, sigma_unit_pct)
        ev = evaluate(w, w_nom, a["redundant"])
        for tag in peaks:
            peaks[tag].append(ev[tag]["inl_peak_lsb"])

    out = {"arch": arch, "n": n, "sigma_unit_pct": sigma_unit_pct, "seed": seed}
    for tag, vals in peaks.items():
        v = np.asarray(vals)
        n_pass = int(np.sum(v < 0.5))
        out[tag] = {
            "inl_mean_lsb":  round(float(v.mean()), 4),
            "inl_sigma_lsb": round(float(v.std()), 4),
            "inl_p50_lsb":   round(float(np.percentile(v, 50)), 4),
            "inl_p99_lsb":   round(float(np.percentile(v, 99)), 4),
            "inl_worst_lsb": round(float(v.max()), 4),
            "yield_pct":     round(100.0 * n_pass / n, 2),
            # Wilson score interval is well behaved at p near 0 and 1, unlike
            # the normal approximation.
            "yield_ci95":    wilson_ci(n_pass, n),
        }
    return out


def wilson_ci(k: int, n: int, z: float = 1.959963985) -> list[float]:
    """95 % Wilson score interval for k successes in n trials, IN PERCENT.

    Returns e.g. [86.2, 100.0] for 24/24 and [91.24, 100.0] for 40/40 —
    already scaled, so a caller must NOT multiply by 100 again. Four call
    sites did, and printed [8620, 10000].
    """
    if n == 0:
        return [0.0, 100.0]
    p  = k / n
    d  = 1.0 + z * z / n
    c  = (p + z * z / (2 * n)) / d
    hw = z * np.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / d
    return [round(100.0 * max(0.0, c - hw), 2), round(100.0 * min(1.0, c + hw), 2)]


# --- generated architectures -------------------------------------------
# opt_boot.py writes one registration per optimisation trial.  They used to be
# appended here, which grew the shared file by 40 entries per study and put
# machine-written text in the middle of a hand-maintained one.  They live in
# cdac_arch_generated.py now; this loads them if it exists.  Keeping them out
# of here also means a study can rewrite its own registrations without
# touching a file another agent may be editing.
try:
    _gen = __file__.replace("cdac_arch.py", "cdac_arch_generated.py")
    with open(_gen, encoding="utf-8") as _fh:
        exec(compile(_fh.read(), _gen, "exec"))
except FileNotFoundError:
    pass
