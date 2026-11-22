# SAR Logic (diff) Macro - Variant C_71x430_19ns

Flow: LibreLane, PDK gf180mcuD, `gf180mcu_fd_sc_mcu7t5v0`, **19 ns clock (52.6 MHz, ~1 MS/s)**, 3.3 V corners.
Delay cells (`dly*`) are excluded from resizer use (`EXTRA_EXCLUDED_CELLS` in `config.yaml`); this is what closes ss setup at 19 ns.
`config.yaml` reproduces this variant. Source run: `variants/C_71x430_19ns/runs/r2`.

## Area
- Die: 71.0 x 430.0 um = 30,530 um²
- Core: 56.6 x 411.6 um = 23,280 um²
- Std-cell utilization (excl. fill): 56.3%  (765 cells)

## Timing (worst slack, ns)
| Corner | Setup | Hold |
|---|---|---|
| tt 25C 3.30V | 10.52 | 0.89 |
| ff -40C 3.60V | 12.24 | 0.30 |
| ss 125C 3.00V | 4.67 | 2.30 |
Setup TNS: 0, hold TNS: 0

## Power (tt)
- Total 3.90 mW (internal 2.50, switching 1.40, leakage 0.60 uW)

## Verification
- Magic DRC: 0, routing DRC: 0, LVS: 0, antenna violating nets: 0
- KLayout DRC not run (no gf180mcuD runset)
- Max-slew violations: 44, max-fanout: 15, max-cap: 0 (not timing failures; review before sign-off)
- Simulation at 19 ns (`sim/`): RTL, zero-delay GLS, SDF GLS tt/ff/ss all PASS (1027 checks, 0 errors)

## Integration notes
- Characterized at 3.3 V; a 5 V rail needs level shifting at the DAC-switch / control boundary.
- ~52 cycles per conversion x 19 ns = ~0.99 us (~1.01 MS/s).
