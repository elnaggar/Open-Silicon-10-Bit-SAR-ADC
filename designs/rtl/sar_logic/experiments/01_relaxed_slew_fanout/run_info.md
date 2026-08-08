# Relaxed Slew and Fanout Run

## Constraints
- Max Fanout: 15
- Max Transition: 3.0 ns

## Motivation
The baseline run with 1.5 ns transition constraint and fanout of 6 was unnecessarily tight for a 12.5 MHz design in gf180mcu, resulting in heavy over-buffering and max slew violations. Relaxing the constraints aims to resolve violations and produce a smaller footprint.

## Associated Run
RUN_2026-08-03_14-38-30
