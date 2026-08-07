# SAR Logic Diff — Differential SAR Controller

Digital control logic for a **Successive-Approximation Register (SAR) ADC** with
a **differential** charge-redistribution CDAC topology.

This is an enhanced variant of `sar_logic` with explicit acquisition (track)
phase, bottom-plate sampling, comparator reset/strobe outputs, and differential
bottom-plate switch controls (`dac_p` / `dac_n`).

It is the digital heart of the [Open-Silicon 10-Bit SAR ADC](../../../README.md).
The module is fully parameterizable in resolution `N` (default `10`, matching the
target ADC).

---

## Block Diagram

```
                +---------------------------------------------+
      start --->|                                             |---> busy
        clk --->|            sar_logic_diff                   |---> eoc
      rst_n --->|    (Differential SAR FSM controller)        |---> dout_valid
   comp_out --->|                                             |===> dout[N-1:0]
                |                                             |===> dac_p[N-1:0]
                |                                             |===> dac_n[N-1:0]
                |                                             |---> samp_top
                |                                             |---> samp_bot
                |                                             |---> cmp_rst
                |                                             |---> cmp_clk
                +---------------------------------------------+
```

---

## Ports

| Name         | Dir | Width   | Description                                                        |
|--------------|-----|---------|----------------------------------------------------------------------|
| `clk`        | in  | 1       | System clock.                                                        |
| `rst_n`      | in  | 1       | **Asynchronous**, active-low reset.                                 |
| `start`      | in  | 1       | Begin a conversion (sampled only in `IDLE`). Single-cycle pulse.    |
| `comp_out`   | in  | 1       | Comparator decision. `1` = Vdac ≤ Vin → keep current bit.          |
| `samp_top`   | out | 1       | Top-plate switch control (track phase).                              |
| `samp_bot`   | out | 1       | Bottom-plate switch control (track phase).                           |
| `cmp_rst`    | out | 1       | Comparator reset / precharge, active high.                           |
| `cmp_clk`    | out | 1       | Comparator strobe, active high.                                      |
| `dac_p`      | out | `N`     | Differential CDAC P-side bottom-plate controls.                      |
| `dac_n`      | out | `N`     | Differential CDAC N-side bottom-plate controls (complement of dac_p).|
| `busy`       | out | 1       | High for the entire duration of a conversion.                        |
| `eoc`        | out | 1       | **End Of Conversion** — 1-cycle pulse when the result is ready.     |
| `dout`       | out | `N`     | Converted digital output code.                                       |
| `dout_valid` | out | 1       | 1-cycle pulse, asserted together with `eoc`; qualifies `dout`.      |

### Parameters

| Name          | Default | Description                              |
|---------------|---------|------------------------------------------|
| `N`           | `10`    | ADC resolution / DAC word width.         |
| `ACQ_CYCLES`  | `8`     | Track/acquisition length, in clocks.     |
| `SETTLE_CYC`  | `2`     | CDAC settling allowed per bit trial.     |
| `CMP_CYC`     | `1`     | Comparator regeneration time.            |

---

## Operation

The controller is an 8-state FSM:

```
         start                                               bit_idx == 0
  IDLE ────────► TRACK ──► HOLD_T ──► HOLD_B ──► SETTLE ──► CMP ──► LATCH ──► DONE ──► IDLE
                                                    ▲                   │
                                                    └───────────────────┘
                                                     (N iterations, MSB → LSB)
```

| State     | Action                                                                    |
|-----------|---------------------------------------------------------------------------|
| `IDLE`    | Wait for `start`. Clears `sar_reg`, sets `busy` when triggered.           |
| `TRACK`   | Acquisition phase: both switches closed for `ACQ_CYCLES` clocks.          |
| `HOLD_T`  | Open top-plate switch first (bottom-plate sampling).                      |
| `HOLD_B`  | Release bottom plates, apply MSB trial code.                              |
| `SETTLE`  | Wait `SETTLE_CYC` clocks for DAC to settle; then release comparator.     |
| `CMP`     | Wait `CMP_CYC` clocks for comparator to regenerate.                      |
| `LATCH`   | Capture comparator decision, prepare next bit trial or finish.            |
| `DONE`    | Latch `dout`, pulse `eoc` and `dout_valid`, return to `IDLE`.             |

---

## Directory Structure

```
sar_logic_diff/
├── config.yaml                 # LibreLane RTL-to-GDS configuration
├── base.sdc                    # Timing constraints (PnR + signoff)
├── pin_order.cfg               # I/O pin placement
├── tb_sdf_wrapper_template.v   # SDF annotation wrapper template
├── README.md                   # This file
├── src/
│   └── sar_logic_diff.v        # Synthesizable RTL
├── tb/
│   └── tb_diff.v               # Testbench (TODO)
├── scripts/
│   ├── run_all_experiments.sh
│   ├── run_all_functional_gls.sh
│   ├── run_all_gls.sh
│   └── test_sdf.sh
├── docs/                       # Architecture diagrams (TODO)
├── experiments/                 # LibreLane experiment configs
├── runs/                       # LibreLane run outputs
├── macro_deliverables/         # Final hardened macro files
├── signoff_reports/            # Tapeout signoff reports
└── sim_outputs/                # Simulation outputs
```

---

## RTL-to-GDS Flow

This design uses **LibreLane** on the **GlobalFoundries 180nm MCU** PDK
(`gf180mcuD`) with the 5V-tolerant standard cell library (`gf180mcu_fd_sc_mcu7t5v0`)
characterized at 3.3V corners.

### Running the flow:

```bash
# Single run with default config
librelane config.yaml

# Run all experiments
bash scripts/run_all_experiments.sh
```

---

## Integration Notes

- **Bottom-plate sampling**: `samp_top` opens BEFORE `samp_bot` to kill
  signal-dependent charge injection.
- **Differential DAC**: `dac_n = ~dac_p` (bitwise complement).
- **Comparator timing**: `cmp_rst` precharges the comparator; `cmp_clk`
  strobes it. Both are controlled with programmable cycle counts.
- **`comp_out` is sampled synchronously** — the analog comparator output must be
  metastability-hardened and allowed to settle within the `CMP_CYC` window.
- **`start`** is only sampled in `IDLE`; drive it as a single-cycle pulse unless
  continuous conversion is intended.
- **3.3V operation**: The timing is signed off at 3.3V corners. If integrated
  onto a 5V digital rail, level-shifting is required.
