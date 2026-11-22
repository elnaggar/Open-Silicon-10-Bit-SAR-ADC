# SAR logic (diff) layout variants  — gf180mcuD, gf180mcu_fd_sc_mcu7t5v0, 3.3 V corners

Shared inputs live one level up: `../src`, `../tb`, `../pnr.sdc`, `../signoff.sdc`, `../pin_order.cfg`.
Each variant = its own `config.yaml` + `final/` (GDS/LEF/lib/nl/sdf/spef/...) + `sim/` logs.

| Variant | Die | Floorplan | Setup WS | Hold WS |
|---|---|---|---|---|
| A_136x154_util45 | 136.1 x 154.0 | relative, util 45% | 12.16 ns | 0.32 ns |
| B_75x430 | 75 x 430 (32,250 um²) | absolute | +13.46 ns | +0.28 ns |
| C_71x430 | 71 x 430 (30,530 um²) | absolute | +14.03 ns | +0.32 ns |

Re-run after editing a config:  `variants/run_variant.sh C_71x430 mytag`  (output in `variants/C_71x430/runs/mytag`).
Clock is constrained at 40 ns (25 MHz). The testbench default is 19 ns (~1 MS/s); see sim notes in C_71x430/sim.
`../macro_deliverables` currently holds variant C.
