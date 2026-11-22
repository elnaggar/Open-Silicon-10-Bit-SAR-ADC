#!/bin/bash
# Usage (inside container): run_sims_variant.sh <variant_dir> <run_tag>
# Runs RTL, zero-delay GLS and SDF GLS (tt/ff/ss) with tb/tb_diff.v (19 ns clock). Logs -> variants/<variant_dir>/sim/
PDK_V=/foss/pdks/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog
B=/foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff
V=$1; T=$2; R=$B/variants/$V/runs/$T/final; O=$B/variants/$V/sim; mkdir -p $O; cd $B
NL=$R/nl/sar_logic_diff.nl.v
iverilog -g2012 -s tb_deep -o $O/rtl.vvp src/sar_logic_diff.v tb/tb_diff.v 2>/dev/null && vvp $O/rtl.vvp > $O/rtl.log
iverilog -g2012 -DFUNCTIONAL -s tb_deep -o $O/func.vvp $PDK_V/primitives.v tb/gf180_patched.v $NL tb/tb_diff.v 2>/dev/null && vvp $O/func.vvp > $O/func.log
for C in nom_tt_025C_3v30 nom_ff_n40C_3v60 nom_ss_125C_3v00; do
  printf 'module tb_sdf_wrapper;\n  tb_deep tb();\n  initial $sdf_annotate("%s", tb.dut, , "%s", "MAXIMUM");\nendmodule\n' "$R/sdf/$C/sar_logic_diff__$C.sdf" "$O/sdf_$C.log" > $O/wrap_$C.v
  iverilog -g2012 -gspecify -ginterconnect -s tb_sdf_wrapper -o $O/sdf_$C.vvp $PDK_V/primitives.v tb/gf180_patched.v $NL tb/tb_diff.v $O/wrap_$C.v 2>/dev/null && timeout 400 vvp $O/sdf_$C.vvp > $O/sdf_$C.out
done
rm -f $O/*.vvp
for f in rtl.log func.log sdf_*.out; do echo "$V $f: $(grep -E 'DEEP VERIFY' $O/$f | tr -s ' ')"; done
