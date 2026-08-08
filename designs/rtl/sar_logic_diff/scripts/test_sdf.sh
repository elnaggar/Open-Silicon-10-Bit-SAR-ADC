#!/bin/bash

cd /foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff

# Update the RUN path after the first successful LibreLane run
RUN="runs/RUN_PLACEHOLDER"
NL="$RUN/final/nl/sar_logic_diff.nl.v"
SDF="$RUN/final/sdf/nom_tt_025C_3v30/sar_logic_diff__nom_tt_025C_3v30.sdf"

cat << EOF > tb/tb_sdf_wrapper.v
module tb_sdf_wrapper;
  tb_deep tb();
  initial begin
    \$sdf_annotate("$SDF", tb.dut, , "sdf.log", "MAXIMUM");
  end
endmodule
EOF

# Compile WITH the original library and WITH -gspecify -ginterconnect
iverilog -g2012 -gspecify -ginterconnect -s tb_sdf_wrapper -o sim_outputs/sim_sdf.vvp \
  /foss/pdks/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/primitives.v \
  tb/gf180_patched.v \
  $NL tb/tb_diff.v tb/tb_sdf_wrapper.v

if [ $? -eq 0 ]; then
  echo "Compile successful. Running vvp..."
  vvp sim_outputs/sim_sdf.vvp > sim_outputs/sim_sdf.log
  cat sim_outputs/sim_sdf.log | grep -A 2 -B 2 "DEEP"
else
  echo "Compile failed."
fi
