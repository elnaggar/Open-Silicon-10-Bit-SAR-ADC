Open-Silicon-SAR-ADC
Gulu, Ankur Gupta, Ahmed Elnaggar
Author: Ahmed Elnaggar

---

# SAR ADC — 10-bit binary CDAC, integrated top level

The assembled, best-validated configuration of design #1: a differential
10-bit binary-weighted CDAC SAR-ADC in GF180MCU-D. This folder brings
together the CDAC array, its driver, the bootstrapped sampling switch,
and the comparator into one place, with just the circuit files and the
testbench needed to simulate and plot them

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
the exact netlist the measured ENOB above was run against

**CDAC driver — `cdac_driver_array_opt.spice`** (plus
`cdac_driver_array.spice`, which it depends on for its buffer cells).
Ten `bp_buffer_medium` units, one per bit, sized by sweeping the buffer
multiplier against settling time and reference droop

**Comparator — `comp_tot.spice` in this package is the *resized*
comparator** (`comp_tot_opt3_final.spice` in the wider campaign,
renamed here to the name the testbench actually reads). A resized input pair
(2.0 um -> 2.99 um) and tail switch (4.0 um -> 8.78 um) fixes it —
validated 0/80 fine-DNL failures (was 15/80), 0/135 PVT x supply
failures, 0/120 mismatch failures, with ENOB/SNDR/SFDR/THD **unchanged**
(`testbench/results/behav_dynamic_resized_comparator.json`: 9.668 /
59.96 / 71.98 / -73.44, matching the as-delivered comparator's own
numbers to 3 decimal places). Same measured dynamic performance, a real
defect fixed, no measured downside — used here as the better choice.

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
