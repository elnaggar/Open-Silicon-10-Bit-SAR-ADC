module tb_sdf_wrapper;
  tb_deep tb();
  initial $sdf_annotate("/foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff/variants/A_136x154_util45_19ns/runs/r2/final/sdf/nom_ff_n40C_3v60/sar_logic_diff__nom_ff_n40C_3v60.sdf", tb.dut, , "/foss/designs/Open-Silicon-10-Bit-SAR-ADC/designs/rtl/sar_logic_diff/variants/A_136x154_util45_19ns/sim/sdf_nom_ff_n40C_3v60.log", "MAXIMUM");
endmodule
