# SAR Logic — Successive-Approximation Register Controller

Digital control logic for a **Successive-Approximation Register (SAR) ADC**.
This block drives a binary-search algorithm: on each conversion it toggles the
DAC bit-by-bit (MSB→LSB), reads the analog comparator decision each step, and
assembles the final N-bit digital code.

It is the digital heart of the [Open-Silicon 10-Bit SAR ADC](../../../README.md).
The module is fully parameterizable in resolution `N` (default `10`, matching the
target ADC).

---

## Block Diagram

```
                +---------------------------------------------+
      start --->|                                             |---> busy
        clk --->|                 sar_logic                   |---> eoc
      rst_n --->|            (SAR FSM controller)             |---> dout_valid
   comp_out --->|                                             |===> dout[N-1:0]
                |                                             |===> dac_out[N-1:0]
                +---------------------------------------------+
                        ^                          |
                        |  comp_out                | dac_out
                        |                          v
                  +-----------+              +-----------+
                  |Comparator |<-- Vin ------|    DAC    |
                  +-----------+              +-----------+
```

`sar_logic` closes the loop around an external **DAC** and **comparator**:
it outputs a trial code on `dac_out`, the DAC converts it to an analog voltage,
the comparator compares it against the sampled input `Vin`, and returns the
1-bit decision on `comp_out`.

---

## Ports

| Name         | Dir | Width   | Description                                                        |
|--------------|-----|---------|--------------------------------------------------------------------|
| `clk`        | in  | 1       | System clock.                                                      |
| `rst_n`      | in  | 1       | **Asynchronous**, active-low reset.                               |
| `start`      | in  | 1       | Begin a conversion (sampled only in `IDLE`). Single-cycle pulse.  |
| `comp_out`   | in  | 1       | Comparator decision. `1` = DAC voltage ≤ input → keep current bit.|
| `busy`       | out | 1       | High for the entire duration of a conversion.                     |
| `eoc`        | out | 1       | **End Of Conversion** — 1-cycle pulse when the result is ready.   |
| `dout`       | out | `N`     | Converted digital output code.                                    |
| `dout_valid` | out | 1       | 1-cycle pulse, asserted together with `eoc`; qualifies `dout`.    |
| `dac_out`    | out | `N`     | Trial code driven to the external DAC during the search.          |

### Parameters

| Name | Default | Description                          |
|------|---------|--------------------------------------|
| `N`  | `10`    | ADC resolution / DAC word width.     |

---

## Operation

The controller is a 4-state FSM:

```
        start                       bit_idx == 0
  IDLE ────────► SAMPLE ──► CONVERT ─────────────► DONE ──► IDLE
   ▲                          ▲   │                          │
   │                          └───┘  (N iterations,          │
   └───────────────────────────────  MSB → LSB) ─────────────┘
```

| State     | Action                                                                    |
|-----------|---------------------------------------------------------------------------|
| `IDLE`    | Wait for `start`. Clears `sar_reg`, sets `busy` when triggered.            |
| `SAMPLE`  | Drive the MSB trial (`dac_out = 1 << (N-1)`).                              |
| `CONVERT` | For each bit MSB→LSB: keep the bit if `comp_out=1`, arm the next trial bit.|
| `DONE`    | Latch `dout`, pulse `eoc` and `dout_valid`, return to `IDLE`.             |

### Timing

- **Latency:** a conversion takes a **fixed `N + 1` clock cycles** from the
  cycle `start` is sampled to the cycle `eoc` asserts (data-independent).
- `busy` is high for the whole conversion; `eoc` / `dout_valid` are single-cycle
  pulses coincident with valid `dout`.
- Holding `start` high runs **back-to-back** conversions continuously.

```
clk        ┌─┐ ┌─┐ ┌─┐ ┌─┐        ┌─┐ ┌─┐
        ───┘ └─┘ └─┘ └─┘ └─ ... ──┘ └─┘ └──
start    __┌─┐________________________________
busy     ____┌───────────────────────┐________
eoc      __________________________┌─┐________
dout     ═══════════════════════════╪═[code]══
                 └──── N+1 cycles ───┘
```

---

## Simulation

Two testbenches are provided:

- `tb_sar_logic.v` — quick directed smoke test with an ideal comparator model.
- `tb_deep.v` — **exhaustive** self-checking testbench (every input code) that
  also verifies latency, the `busy`/`eoc`/`dout_valid` protocol, async reset,
  back-to-back conversions, spurious-`start` rejection, and X-propagation.

### Icarus Verilog

```bash
# Directed smoke test (default N=10)
iverilog -g2012 -o sar_sim sar_logic.v tb_sar_logic.v
vvp sar_sim

# Exhaustive verification (default N=10; all 1024 codes)
iverilog -g2012 -o deep sar_logic.v tb_deep.v
vvp deep
```

Expected output:

```
[PASS] Vin = 512 (0x200) | ADC out = 512
...
[PASS] Vin = 1023 (0x3ff) | ADC out = 1023
   SIMULATION PASSED! (0 Errors)
```

`tb_deep.v` defaults to `N=10`; override with `-DN=<width>` at elaboration to
verify other resolutions. For `tb_sar_logic.v`, change `parameter N` in the
testbench to simulate a different configuration.

### Lint (Verilator)

The RTL is clean under strict lint:

```bash
verilator --lint-only -Wall sar_logic.v      # 0 warnings, 0 errors
```

---

## Verification Status

The design has been **exhaustively verified** (every input code) for
`N = 2, 3, 4, 6, 8, 10, 12, 16` against an ideal linear comparator, checking:

- Correctness: `dout == Vin` for all codes.
- Deterministic `N + 1` cycle latency.
- `busy` / `eoc` / `dout_valid` handshake protocol.
- Asynchronous reset (including mid-conversion), clean recovery.
- Back-to-back conversions and rejection of spurious `start` while busy.
- No X-propagation; no latches / combinational loops (Verilator structural lint).

---

## Integration Notes

- **`comp_out` is sampled synchronously** — the analog comparator output must be
  metastability-hardened and allowed to settle within one clock period.
- **`start`** is only sampled in `IDLE`; drive it as a single-cycle pulse unless
  continuous conversion is intended.
- **`dout`** holds its last value after `dout_valid` deasserts — downstream logic
  should capture it on the `dout_valid` / `eoc` pulse.
- The comparator convention is `comp_out = (V_dac ≤ V_in)`; equality keeps the bit.

---

## Files

| File              | Description                                  |
|-------------------|----------------------------------------------|
| `sar_logic.v`     | Synthesizable SAR controller RTL.            |
| `tb_sar_logic.v`  | Directed self-checking testbench.            |
| `tb_deep.v`       | Exhaustive self-checking verification bench. |
| `sar_sim.vcd`     | Example waveform dump (view in GTKWave).     |
