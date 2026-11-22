# SAR Logic (diff) Macro - Variant A_136x154_util45

Flow: LibreLane, PDK gf180mcuD, `gf180mcu_fd_sc_mcu7t5v0`, 40 ns clock (25 MHz), 3.3 V corners.
`config.yaml` in this folder reproduces this variant (see `../../variants/run_variant.sh`).

## Area
- Die: 136.1 x 154.0 um = 20,966 um²
- Core: 122.6 x 121.5 um = 14,903 um²
- Std-cell utilization (excl. fill): 82.2%  (621 cells)

## Timing (worst slack, ns)
| Corner | Setup | Hold |
|---|---|---|
| tt 25C 3.30V | 21.79 | 0.94 |
| ff -40C 3.60V | 25.92 | 0.33 |
| ss 125C 3.00V | 12.17 | 2.42 |

## Power (tt)
- Total 1.60 mW (internal 0.93, switching 0.67, leakage 0.45 uW)

## Verification
- Magic DRC: 0, routing DRC: 0, LVS: 0, antenna violating nets: 0
- KLayout DRC not run (no gf180mcuD runset)
- Max-slew violations: 76 (ss corner), max-fanout violations: 14, max-cap: 0

## Integration notes
- Characterized at 3.3 V; a 5 V rail needs level shifting at the DAC-switch / control boundary.
- Timing is closed at a 40 ns clock (about 500 kS/s). Not verified at 1 MS/s (19 ns).
