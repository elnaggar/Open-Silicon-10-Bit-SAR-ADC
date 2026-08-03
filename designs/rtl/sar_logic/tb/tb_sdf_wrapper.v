module tb_sdf_wrapper;
  tb_deep tb();
  initial begin
    $sdf_annotate(
      "runs/RUN_2026-08-03_14-41-15/final/sdf/nom_tt_025C_3v30/sar_logic__nom_tt_025C_3v30.sdf",
      tb.dut,
      ,
      "sdf_annotate.log",
      "MAXIMUM"
    );
  end
endmodule
