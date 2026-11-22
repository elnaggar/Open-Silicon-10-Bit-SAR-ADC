# SAR Logic (diff) Macro Deliverables - three variants

Each subfolder is self-contained: GDS, LEF, lib, netlist, SDF, SPEF, DEF, mag, metrics, `config.yaml`, `macro_summary.md`.

| Variant | Die (um) | Area (um²) | Util | Setup WS (ns) | Hold WS (ns) | DRC/LVS errors |
|---|---|---|---|---|---|---|
| A_136x154_util45 | 136 x 154 | 20,966 | 82% | 12.17 | 0.33 | 0/0 |
| B_75x430 | 75 x 430 | 32,250 | 56% | 13.46 | 0.28 | 0/0 |
| C_71x430 | 71 x 430 | 30,530 | 60% | 14.03 | 0.32 | 0/0 |

Simulation for variant C (RTL, zero-delay GLS, SDF GLS tt/ff/ss at 40 ns) is in `../variants/C_71x430/sim`.
Variants A and B were not re-simulated. At the 1 MS/s testbench clock (19 ns) the ss-corner SDF simulation fails (also on A); timing is only closed at 40 ns.
