# SAR Logic (diff) Macro - Variant B_75x430

Flow: LibreLane, PDK gf180mcuD, `gf180mcu_fd_sc_mcu7t5v0`, 40 ns clock (25 MHz), 3.3 V corners.
`config.yaml` in this folder reproduces this variant (see `../../variants/run_variant.sh`).

## Area
- Die: 75.0 x 430.0 um = 32,250 um²
- Core: 60.5 x 411.6 um = 24,894 um²
- Std-cell utilization (excl. fill): 56.2%  (817 cells)

## Timing (worst slack, ns)
| Corner | Setup | Hold |
|---|---|---|
| tt 25C 3.30V | 22.51 | 0.85 |
| ff -40C 3.60V | 26.35 | 0.28 |
| ss 125C 3.00V | 13.46 | 2.22 |

## Power (tt)
- Total 1.90 mW (internal 1.20, switching 0.70, leakage 0.61 uW)

## Verification
- Magic DRC: 0, routing DRC: 0, LVS: 0, antenna violating nets: 0
- KLayout DRC not run (no gf180mcuD runset)
- Max-slew violations: 63 (ss corner), max-fanout violations: 14, max-cap: 0

## Integration notes
- Characterized at 3.3 V; a 5 V rail needs level shifting at the DAC-switch / control boundary.
- Timing is closed at a 40 ns clock (about 500 kS/s). Not verified at 1 MS/s (19 ns).
