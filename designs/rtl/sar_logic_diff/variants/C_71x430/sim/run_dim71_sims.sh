#!/bin/bash
PDK_V=/foss/pdks/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog
cd /foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff
O=sim_outputs/dim71; mkdir -p $O
NL=macro_deliverables/nl/sar_logic_diff.nl.v
echo "== RTL"; iverilog -g2012 -s tb_deep -o $O/rtl.vvp src/sar_logic_diff.v tb/tb_diff.v && vvp $O/rtl.vvp > $O/rtl.log; tail -n 4 $O/rtl.log
echo "== Functional GLS"; iverilog -g2012 -DFUNCTIONAL -s tb_deep -o $O/func.vvp $PDK_V/primitives.v tb/gf180_patched.v $NL tb/tb_diff.v && vvp $O/func.vvp > $O/func.log; tail -n 4 $O/func.log
for C in nom_tt_025C_3v30 nom_ff_n40C_3v60 nom_ss_125C_3v00; do
  echo "== SDF GLS $C"
  SDF=macro_deliverables/sdf/$C/sar_logic_diff__$C.sdf
  cat > $O/wrap_$C.v <<EOT
module tb_sdf_wrapper;
  tb_deep tb();
  initial \$sdf_annotate("$SDF", tb.dut, , "$O/sdf_$C.log", "MAXIMUM");
endmodule
EOT
  iverilog -g2012 -gspecify -ginterconnect -s tb_sdf_wrapper -o $O/sdf_$C.vvp $PDK_V/primitives.v tb/gf180_patched.v $NL tb/tb_diff.v $O/wrap_$C.v && vvp $O/sdf_$C.vvp > $O/sdf_$C.out; tail -n 4 $O/sdf_$C.out
done
