# Comparator Monte Carlo Testbench

This folder contains the mismatch/offset Monte Carlo testbench and exported data for the StrongARM comparator.

## Testbench

- `tb_comp_monte.sch`: Monte Carlo comparator testbench using GF180 statistical mismatch models.

## Model Setup

The Monte Carlo testbench enables mismatch variation with:

```spice
.param sw_stat_global=0
.param sw_stat_mismatch=1
.param mc_skew=1
.lib $::180MCU_MODELS/sm141064.ngspice statistical
```

## Included Result Artifacts

- `plots/comp_mc_probability_curve.png`: Initial Monte Carlo decision probability curve.
- `plots/comp_mc_probability_wide_curve.png`: Wider input-difference probability curve.
- `plots/comp_offset_histogram.png`: Input-referred offset histogram from 50 Monte Carlo mismatch runs.

Large raw `.txt` Monte Carlo exports are intentionally not committed. They can be regenerated from `tb_comp_monte.sch`.

## Current Interpretation

The first-pass comparator is functionally correct, but the simulated mismatch spread is too large for a robust 10-bit SAR ADC without further comparator sizing, offset calibration, redundancy, or a preamplifier.

Latest offset histogram summary:

- Mean offset: `+0.88 mV`.
- Sigma offset: `12.68 mV`.
- Three-sigma offset: `38.05 mV`.
- Half LSB for the 10-bit, 0-3 V ADC target: `1.465 mV`.
- Simulated `|Vos| <= 0.5 LSB` yield: `8%`.
