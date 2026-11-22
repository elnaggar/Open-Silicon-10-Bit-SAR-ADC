module tb_sdf_wrapper;
  tb_deep tb();
  initial $sdf_annotate("/foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff/variants/A_136x154_util45_19ns/runs/r2/final/sdf/nom_tt_025C_3v30/sar_logic_diff__nom_tt_025C_3v30.sdf", tb.dut, , "/foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff/variants/A_136x154_util45_19ns/sim/sdf_nom_tt_025C_3v30.log", "MAXIMUM");
endmodule
