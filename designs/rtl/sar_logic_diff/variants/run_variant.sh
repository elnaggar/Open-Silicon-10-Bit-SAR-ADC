#!/bin/bash
# Usage: variants/run_variant.sh <variant_dir_name> [run_tag]   (run from host; executes in the docker container)
# Edit variants/<name>/config.yaml first (DIE_AREA, CORE_AREA, CLOCK_PERIOD, ...), then run.
V=${1:?variant dir name, e.g. C_71x430}; TAG=${2:-$(date +%m%d_%H%M)}
docker exec iic-osic-tools_chipathon_xserver_uid_1000 bash -lc "cd /foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff/variants/$V && librelane --pdk gf180mcuD --pdk-root /foss/pdks --run-tag $TAG --design-dir . config.yaml"
echo "Results: variants/$V/runs/$TAG/final"
