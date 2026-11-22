# SAR Logic Digital Macro - Implementation Summary

This document provides a summary of the macro implementation for the SAR Logic, intended for the analog integration engineer. The deliverables are provided in this directory.

## File Deliverables
- **GDS**: `gds/` (Layout for integration)
- **LEF**: `lef/` (Abstract for top-level routing)
- **DEF**: `def/` (Design Exchange Format)
- **LIB**: `lib/` (Timing and power models across corners)
- **SPEF**: `spef/` (Parasitics)
- **Netlist**: `nl/` (Gate-level netlist)
- **SDF**: `sdf/` (Standard Delay Format)

## Key Metrics & Physical Characteristics

Flow: LibreLane, PDK gf180mcuD, `gf180mcu_fd_sc_mcu7t5v0`, 40 ns clock (25 MHz), fixed-die floorplan.
Source run: `experiments/dim_71x430/runs/r1`.

### Area
- **Dimensions (Die Bbox)**: 71.0 x 430.0 um
- **Die Area**: 30,530 um²
- **Core Bbox**: (7.28, 7.84) to (63.84, 419.44) um
- **Core Area**: 23,281 um²
- **Standard Cell Utilization**: 59.6% (excluding fill)
- **Standard Cell Count**: 777

### Timing (Worst Case across corners)
| Corner | Setup WS | Hold WS |
|---|---|---|
| tt 25C 3.30V | +22.96 ns | +0.93 ns |
| ff -40C 3.60V | +26.73 ns | +0.32 ns |
| ss 125C 3.00V | +14.03 ns | +2.37 ns |

- **Worst Setup Slack**: +14.03 ns (ss); **Worst Hold Slack**: +0.32 ns (ff)
- **Setup/Hold TNS**: 0 in all corners
- **Worst Clock Skew**: ~0.58 ns (ss)

### Power (tt 25C 3.30V)
- **Total Power**: ~1.89 mW
- **Internal Power**: ~1.20 mW
- **Switching Power**: ~0.68 mW
- **Leakage Power**: ~0.59 uW
- **Worst IR Drop**: ~0.06 mV (avg ~0.017 mV)

### Physical Verification
- **Magic DRC Errors**: 0
- **Routing DRC Errors**: 0
- **LVS Errors**: 0
- **Antenna Violations**: 0
- **KLayout DRC**: not run (gf180mcuD ships no KLayout runset)

### Known Electrical Warnings (not timing failures)
- **Max slew violations**: 60, all in the ss 125C corner (0 in tt/ff)
- **Max fanout violations**: 17 (all corners)
- **Max cap violations**: 0

The previous 136 x 154 um run had 76 slew and 14 fanout violations, so these are not new.

### Integration Notes
- The macro is characterized at 3.3 V corners. If it is placed on a 5 V digital rail, level shifting is required at the DAC-switch / control boundary.
- The die is tall and narrow. Pins `comp_out`, `samp_*`, `dac_p[*]`, `dac_n[*]`, `cmp_rst`, `cmp_clk` are on the west edge, `dout[*]` east, `clk`/`start`/`rst_n` north, `busy`/`eoc`/`dout_valid` south. Confirm this matches the top-level routing.

The macro is DRC and LVS clean and meets setup and hold timing in all three corners. Review the slew/fanout warnings above before sign-off.
