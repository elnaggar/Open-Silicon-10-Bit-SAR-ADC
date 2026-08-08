#!/bin/bash

# We will run this inside the container
PDK_V="/foss/pdks/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog"
cd /foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff

echo "Starting Functional Zero-Delay GLS for all runs..."
for RUN in runs/*; do
  if [ -d "$RUN/final/nl" ]; then
    NL="$RUN/final/nl/sar_logic_diff.nl.v"
    
    # Run the exact same functional GLS you successfully ran before
    iverilog -g2012 -DFUNCTIONAL -s tb_deep -o "sim_outputs/gls_$(basename $RUN).vvp" \
      $PDK_V/primitives.v tb/gf180_patched.v \
      $NL tb/tb_diff.v
      
    if [ $? -eq 0 ]; then
      vvp "sim_outputs/gls_$(basename $RUN).vvp" > "sim_outputs/gls_$(basename $RUN).log"
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
