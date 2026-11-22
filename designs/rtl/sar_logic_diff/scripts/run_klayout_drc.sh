#!/bin/bash
# Usage (host): scripts/run_klayout_drc.sh <variant_dir> [klayout_variant A-F] [nodensity]
# Runs the official gf180mcu KLayout DRC deck (flat) on macro_deliverables/<variant>/klayout_gds in the container.
# Default includes density rules; pass "nodensity" for geometry-only. Output: <variant>/drc_klayout_<K>[_nodensity]/
V=$1; K=${2:-D}; MODE=${3:-density}
if [ "$MODE" = nodensity ]; then DIR=drc_klayout_${K}_nodensity; DEN=""; else DIR=drc_klayout_$K; DEN="--density"; fi
docker exec iic-osic-tools_chipathon_xserver_uid_1000 bash -lc "
B=/foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff/macro_deliverables/$V
mkdir -p \$B/$DIR && cd \$B/$DIR
python3 /foss/pdks/gf180mcuD/libs.tech/klayout/tech/drc/run_drc.py --path=\$B/klayout_gds/sar_logic_diff.klayout.gds --variant=$K --topcell=sar_logic_diff --mp=2 --run_dir=. $DEN > drc_run.log 2>&1; echo done >> drc_run.log"
