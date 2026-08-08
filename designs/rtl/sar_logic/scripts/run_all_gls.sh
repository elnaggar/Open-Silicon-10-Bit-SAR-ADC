#!/bin/bash

# We will run this inside the container
PDK_V="/foss/pdks/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog"
cd /foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic

echo 'module tb_sdf_wrapper;
  tb_deep tb();
  initial begin
    $sdf_annotate(
      "SDF_FILE_PLACEHOLDER",
      tb.dut,
      ,
      "sdf_annotate.log",
      "MAXIMUM"
    );
  end
endmodule' > tb_sdf_wrapper_template.v

echo "Starting GLS for all runs..."
for RUN in runs/*; do
  if [ -d "$RUN/final/nl" ]; then
    NL="$RUN/final/nl/sar_logic.nl.v"
    SDF="$RUN/final/sdf/nom_tt_025C_3v30/sar_logic__nom_tt_025C_3v30.sdf"
    
    if [ ! -f "$SDF" ]; then
      echo "[SKIP] $RUN - No SDF file found."
      continue
    fi
    
    sed "s|SDF_FILE_PLACEHOLDER|$SDF|g" tb/tb_sdf_wrapper_template.v > tb/tb_sdf_wrapper.v
    
    iverilog -g2012 -gspecify -ginterconnect -s tb_sdf_wrapper -o "sim_outputs/sim_$(basename $RUN).vvp" \
      $PDK_V/primitives.v tb/gf180_patched.v \
      $NL tb/tb_deep_gls_functional.v tb/tb_sdf_wrapper.v
      
    if [ $? -eq 0 ]; then
      vvp "sim_outputs/sim_$(basename $RUN).vvp" > "sim_outputs/gls_$(basename $RUN).log"
      if grep -q "FUNCTIONAL GLS PASSED" "sim_outputs/gls_$(basename $RUN).log"; then
        echo "[PASS] $RUN"
      else
        echo "[FAIL] $RUN - Check sim_outputs/gls_$(basename $RUN).log"
      fi
    else
      echo "[ERROR] $RUN - Compilation failed"
    fi
  fi
done
