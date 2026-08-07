module tb_sdf_wrapper;
  tb_deep tb();
  initial begin
    $sdf_annotate(
      "runs/RUN_2026-08-07_12-49-21/final/sdf/nom_tt_025C_3v30/sar_logic_diff__nom_tt_025C_3v30.sdf",
      tb.dut,
      ,
      "sdf_annotate.log",
      "MAXIMUM"
    );
  end
endmodule
