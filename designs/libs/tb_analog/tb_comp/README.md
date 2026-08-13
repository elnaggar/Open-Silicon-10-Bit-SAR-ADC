# StrongARM Comparator Simulation Package

This folder contains the Xschem testbench and exported simulation results for the StrongARM comparator used in the 10-bit SAR ADC project.

## Related Cells

- `designs/libs/core_analog/comp/`: StrongARM comparator core.
- `designs/libs/core_analog/inv_x1/`: Small CMOS inverter buffer.
- `designs/libs/core_analog/inv_x3/`: Larger CMOS inverter buffer.
- `designs/libs/core_analog/nand_SR_latch/`: NAND-based SR latch for comparator decision storage.

## Testbenches

- `tb_comp.sch`: Main comparator transient testbench with output buffers and NAND SR latch.
- `../tb_comp_monte/tb_comp_monte.sch`: Monte Carlo mismatch/offset testbench.

## Key Simulation Conditions

- Technology: GF180 3.3 V devices.
- Supply: `VDD = 3.3 V`.
- Nominal common-mode input: `VCM = 1.5 V`.
- ADC target input range: `0 V` to `3.0 V`.
- 10-bit LSB: `3.0 / 1024 = 2.9297 mV`.
- Half LSB input-difference test: `0.5 LSB = 1.4648 mV`.

## Included Result Artifacts

- `plots/`: Generated PNG plots used for review and presentation.

Large raw `.txt` waveform exports are intentionally not committed. They can be regenerated from `tb_comp.sch` using the NGSPICE control block.

## Summary of Current Results

- Comparator resolves `+/-0.5 LSB` correctly at `VCM = 1.5 V`.
- Nominal core decision delay at `0.5 LSB` is about `0.50 ns`.
- Delay improves as input common-mode increases because the NMOS input pair has larger overdrive.
- Comparator core energy is about `0.206 pJ` per comparison in the current transient setup.
- NAND SR latch captures both positive and negative comparator decisions correctly.
- Monte Carlo mismatch indicates the present first-pass StrongARM sizing has a large input-referred offset spread and needs later sizing/calibration improvement for a robust 10-bit ADC.
