module tb_sdf_wrapper;
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
endmodule
