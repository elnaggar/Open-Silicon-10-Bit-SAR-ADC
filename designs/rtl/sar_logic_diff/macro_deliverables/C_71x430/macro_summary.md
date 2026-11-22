# SAR Logic (diff) Macro - Variant C_71x430

Flow: LibreLane, PDK gf180mcuD, `gf180mcu_fd_sc_mcu7t5v0`, 40 ns clock (25 MHz), 3.3 V corners.
`config.yaml` in this folder reproduces this variant (see `../../variants/run_variant.sh`).

## Area
- Die: 71.0 x 430.0 um = 30,530 um²
- Core: 56.6 x 411.6 um = 23,280 um²
- Std-cell utilization (excl. fill): 59.6%  (777 cells)

## Timing (worst slack, ns)
| Corner | Setup | Hold |
|---|---|---|
| tt 25C 3.30V | 22.96 | 0.93 |
| ff -40C 3.60V | 26.73 | 0.32 |
| ss 125C 3.00V | 14.03 | 2.37 |

## Power (tt)
- Total 1.89 mW (internal 1.20, switching 0.68, leakage 0.59 uW)

## Verification
- Magic DRC: 0, routing DRC: 0, LVS: 0, antenna violating nets: 0
- KLayout DRC not run (no gf180mcuD runset)
- Max-slew violations: 60 (ss corner), max-fanout violations: 17, max-cap: 0

## Integration notes
- Characterized at 3.3 V; a 5 V rail needs level shifting at the DAC-switch / control boundary.
- Timing is closed at a 40 ns clock (about 500 kS/s). Not verified at 1 MS/s (19 ns).
