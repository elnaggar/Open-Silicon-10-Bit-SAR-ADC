#!/bin/bash
# Usage (host): scripts/run_pex.sh
# Magic parasitic extraction (area/fringe/coupling C, ngspice format) for all variants, run inside the container.
# Output: macro_deliverables/<variant>/pex/sar_logic_diff.pex.spice  (SPEF with RC is in <variant>/spef/)
docker exec iic-osic-tools_chipathon_xserver_uid_1000 bash -lc '
BASE=/foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff
RC=/foss/pdks/gf180mcuD/libs.tech/magic/gf180mcuD.magicrc
for V in A_136x154_util45 B_75x430 C_71x430; do
  D=$BASE/macro_deliverables/$V/pex; rm -rf $D; mkdir -p $D; cd $D
  cat > pex.tcl <<EOT
gds read $BASE/macro_deliverables/$V/gds/sar_logic_diff.gds
load sar_logic_diff
select top cell
extract do local
extract do coupling
extract all
ext2spice lvs
ext2spice cthresh 0
ext2spice format ngspice
ext2spice -o sar_logic_diff.pex.spice
quit -noprompt
EOT
  magic -dnull -noconsole -rcfile $RC -T gf180mcuD pex.tcl > magic_pex.log 2>&1
  rm -f *.ext
  echo "$V: $(wc -c < sar_logic_diff.pex.spice 2>&1) bytes"
done' 2>&1 | grep -v "^\[INFO\]"
