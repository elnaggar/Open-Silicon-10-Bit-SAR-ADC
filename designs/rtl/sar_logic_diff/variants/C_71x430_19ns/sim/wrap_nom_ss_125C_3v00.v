module tb_sdf_wrapper;
  tb_deep tb();
  initial $sdf_annotate("/foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff/variants/C_71x430_19ns/runs/r2/final/sdf/nom_ss_125C_3v00/sar_logic_diff__nom_ss_125C_3v00.sdf", tb.dut, , "/foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff/variants/C_71x430_19ns/sim/sdf_nom_ss_125C_3v00.log", "MAXIMUM");
endmodule
