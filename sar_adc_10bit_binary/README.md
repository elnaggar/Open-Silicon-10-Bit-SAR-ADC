Open-Silicon-SAR-ADC
Gulu, Ankur Gupta, Ahmed Elnaggar
Author: Ahmed Elnaggar

---

# SAR ADC — 10-bit binary CDAC, integrated top level

The assembled, best-validated configuration of design #1: a differential
10-bit binary-weighted CDAC SAR-ADC in GF180MCU-D. This folder brings
together the CDAC array, its driver, the bootstrapped sampling switch,
and the comparator into one place, with just the circuit files and the
testbench needed to simulate and plot them — no sizing or optimization
scripts.

## Measured performance

| Spec | Value | Source |
|---|---|---|
| Resolution | 10-bit, differential binary CDAC | — |
| ENOB | **9.66 bit** | `testbench/results/behav_dynamic.json` |
| SNDR | **59.91 dB** | same |
| SFDR | **68.49 dB** | same |
| Sampling | transistor-level bootstrapped switch | `diff_cdac_opt_bootx.spice` |
| Switching scheme | Anderson (Set-and-Down / Monotonic) | matches the delivered digital macro, `sar_logic_diff` |
| Process | GF180MCU-D, 3.3 V devices only | — |

## Which components, and why these

**CDAC array + bootstrap switch — `diff_cdac_opt_bootx.spice`.** This is
the exact netlist the measured ENOB above was run against. A more robust
clamp sizing exists (24 µm clamp, 200 fF ENB decoupling cap — see "What
was deliberately NOT used" below) and measures a *higher* ENOB in one
result file, but only under a different switching scheme this design
doesn't use. Swapping it in here would mean quoting a bigger number from
an unvalidated combination — not done.

**CDAC driver — `cdac_driver_array_opt.spice`** (plus
`cdac_driver_array.spice`, which it depends on for its buffer cells).
Ten `bp_buffer_medium` units, one per bit, sized by sweeping the buffer
multiplier against settling time and reference droop — the only driver
ever paired with this array in a measured result.

**Comparator — `comp_tot.spice` in this package is the *resized*
comparator** (`comp_tot_opt3_final.spice` in the wider campaign,
renamed here to the name the testbench actually reads). The as-delivered
comparator has a real, measured defect: in a ~0.3 ns regeneration
window, it can make a full-strength wrong decision on bits 0-2 despite
the input staying clearly on the correct side. A resized input pair
(2.0 um -> 2.99 um) and tail switch (4.0 um -> 8.78 um) fixes it —
validated 0/80 fine-DNL failures (was 15/80), 0/135 PVT x supply
failures, 0/120 mismatch failures, with ENOB/SNDR/SFDR/THD **unchanged**
(`testbench/results/behav_dynamic_resized_comparator.json`: 9.668 /
59.96 / 71.98 / -73.44, matching the as-delivered comparator's own
numbers to 3 decimal places). Same measured dynamic performance, a real
defect fixed, no measured downside — used here as the better choice.

### What was deliberately NOT used, and why

A clamp-resize variant of the bootstrap switch (24 µm clamp width, 6
fingers, plus a 10x10 um / ~200 fF MIM decoupling cap on the ENB node)
exists and was built to fix a separate, real over-voltage stress finding
(a junction forward-bias violation at the top PVT corner). It measures a
*higher* ENOB (9.76 bit) in one result file — but that result was run
under MCS (V_CM-based) switching, a different, separate, not-yet-
delivered switching scheme for this design. It has never been measured
for dynamic performance under the Anderson switching this design
actually uses. Using it here would mean presenting an unvalidated
combination as "the best," so the plain `diff_cdac_opt_bootx.spice`
(clamp W=4 um, nf=1, no ENB cap) is what's included — it's what the
9.66 ENOB number above was actually run against.

## Files

```
sar_adc_10bit_binary/
├── schematics/                  view-only; see the per-file notes below
│   ├── cdac_driver_array.sch
│   ├── cdac_driver_array_opt.sch, .sym
│   ├── diff_cdac_opt_bootx_c24h_e10.sch, .sym
│   ├── top_nmos_switch.sch, .sym
│   ├── comp_tot.sch, .sym
│   └── comp.sch, .sym
└── testbench/                   netlists + scripts, flat together (the
    │                            scripts expect same-directory access)
    ├── cdac_driver_array.spice
    ├── cdac_driver_array_opt.spice
    ├── diff_cdac_opt_bootx.spice
    ├── comp_tot.spice            the RESIZED comparator (see above)
    ├── sar_behav.py               builds the full top-level SPICE deck
    ├── sar_dyn.py                 the FFT testbench (SNDR/SFDR/THD/ENOB)
    ├── plot_dynamic_spectrum.py   plots results/behav_dynamic.json
    ├── cdac_arch.py                architecture registry (needed import)
    ├── spice_pool.py               docker/ngspice dispatch
    ├── plotstyle.py                 shared plot styling
    └── results/
        ├── behav_dynamic.json                    as-delivered comparator
        └── behav_dynamic_resized_comparator.json  resized comparator
```

### Schematic notes — two real gaps, stated directly

- **No `diff_cdac_opt_bootx.sch` exists anywhere in the source history.**
  `diff_cdac_opt_bootx_c24h_e10.sch`/`.sym`, included here, is the
  nearest available sibling — a different clamp-sizing variant (see "What
  was deliberately NOT used" above) — not a drawn view of the exact
  netlist this testbench simulates. If you need an exact schematic, it
  has to be drawn from `diff_cdac_opt_bootx.spice` directly.
- **`comp_tot.sch`/`.sym` show the comparator's topology correctly, but
  at the as-delivered sizing**, not the resized one used in
  `testbench/comp_tot.spice`. The topology is identical; only the input
  pair and tail switch dimensions differ (2.0 um -> 2.99 um and
  4.0 um -> 8.78 um). No schematic was ever drawn for the resized sizing.

## What's intentionally not here

No sizing, Optuna, or driver-buffer optimization scripts — only the
circuit files and the testbench needed to simulate and plot this exact
configuration. If you want to see how any component was arrived at
(the driver buffer sweep, the comparator resize search, the clamp/ENB
robustification), that's a separate, larger campaign history, not part
of this integrated build.

## Prerequisites

- Docker running the `iic-osic-tools` image (GF180MCU-D PDK + ngspice).
  `spice_pool.py` resolves the container name itself (`$EDA_CONTAINER`
  to pin one).
- Python 3 with `numpy` and `matplotlib`.
- At most 6 concurrent ngspice processes (`spice_pool.py` enforces this).

## Running it

```
docker exec <container> bash -lc \
  'export PDK_ROOT=/foss/pdks PDK=gf180mcuD; \
   cd /path/to/sar_adc_10bit_binary/testbench && \
   python3 sar_dyn.py --archs binary10_opt_bootx --n 128 --bins 13,61'
```

writes `results/behav_dynamic_setup.json`, using the resized comparator
already in place. Then:

```
python3 plot_dynamic_spectrum.py
```

writes `plots/dynamic_spectrum.png`.
