# SAR Logic (diff) Macro Deliverables - six variants (3 floorplans x {40 ns, 19 ns})

Each subfolder is self-contained: GDS, LEF, lib, netlist, SDF, SPEF, DEF, mag, metrics, `config.yaml`, `macro_summary.md`.

| Variant | Die (um) | Area (um²) | Util | Setup WS (ns) | Hold WS (ns) | DRC/LVS errors |
|---|---|---|---|---|---|---|
| A_136x154_util45 | 136 x 154 | 20,966 | 82% | 12.17 | 0.33 | 0/0 |
| B_75x430 | 75 x 430 | 32,250 | 56% | 13.46 | 0.28 | 0/0 |
| C_71x430 | 71 x 430 | 30,530 | 60% | 14.03 | 0.32 | 0/0 |

## 19 ns (~1 MS/s) variants - timing closed at all corners, all simulations pass at 19 ns

| Variant | Die (um) | Area (um²) | Util | ss Setup WS (ns) | Hold WS (ns) | DRC/LVS |
|---|---|---|---|---|---|---|
| A_136x154_util45_19ns | 136 x 154 | 20,966 | 75% | 5.09 | 0.30 | 0/0 |
| B_75x430_19ns | 75 x 430 | 32,250 | 54% | 2.41 | 0.28 | 0/0 |
| C_71x430_19ns | 71 x 430 | 30,530 | 56% | 4.67 | 0.30 | 0/0 |

The 40 ns variants (A/B/C) are timing-closed at 40 ns (~0.5 MS/s) only; at 19 ns their ss corner fails. Use the `_19ns` variants for 1 MS/s.
Variant C 40 ns simulations: `../variants/C_71x430/sim`.
