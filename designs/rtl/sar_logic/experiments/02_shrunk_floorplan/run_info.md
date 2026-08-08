# Shrunk Floorplan

## Constraints
- Max Fanout: 15
- Max Transition: 3.0 ns
- FP_CORE_UTIL: 35
- PL_TARGET_DENSITY_PCT: 45

## Motivation
With the relaxed constraints from the previous run, we saw a massive drop in buffer count, leaving the macro mostly empty (35% standard cell utilization). Bumping the core utilization to 35 shrinks the floorplan bounding box and saves area on the die without sacrificing timing or routability.

## Associated Run
RUN_2026-08-03_14-39-53
