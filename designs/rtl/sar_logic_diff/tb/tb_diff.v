`timescale 1ns/1ps
//
// Deep verification testbench for sar_logic_diff
//
module tb_deep;
`ifndef N
  `define N 10
`endif
    localparam N = `N;

    reg              clk, rst_n, start, comp_out;
    wire [N-1:0]     dac_p, dac_n, dout;
    wire             dout_valid, busy, eoc;
    wire             samp_top, samp_bot, cmp_rst, cmp_clk;

    reg  [N-1:0]     Vin;
    integer          errors, checks;
    integer          i, cyc, conv_cycles;

    sar_logic_diff dut (
        .clk(clk), .rst_n(rst_n), .start(start), .comp_out(comp_out),
        .samp_top(samp_top), .samp_bot(samp_bot), .cmp_rst(cmp_rst), .cmp_clk(cmp_clk),
        .dac_p(dac_p), .dac_n(dac_n), .dout(dout), .dout_valid(dout_valid),
        .busy(busy), .eoc(eoc)
    );

    // Ideal linear comparator
    always @(*) comp_out = (dac_p <= Vin);

    // Clock (19.0ns period -> ~52.6 MHz -> ~1.01 MS/s for 52 cycles/conv)
    initial clk = 0;
    always #9.5 clk = ~clk;

    // ---- global assertions running every cycle ----
    always @(posedge clk) if (rst_n) begin
        if (^{busy, eoc, dout_valid, samp_top, samp_bot, cmp_rst, cmp_clk} === 1'bx) begin
            $display("[FAIL] X on control outputs at t=%0t", $time);
            errors = errors + 1;
        end
        if (eoc !== dout_valid) begin
            $display("[FAIL] eoc(%b) != dout_valid(%b) at t=%0t", eoc, dout_valid, $time);
            errors = errors + 1;
        end
        if ((dac_p ^ dac_n) !== {N{1'b1}}) begin
            $display("[FAIL] dac_p and dac_n are not complementary! p=%b n=%b t=%0t", dac_p, dac_n, $time);
            errors = errors + 1;
        end
    end

    task do_reset;
    begin
        rst_n = 1; start = 0; Vin = 0;
        #1;
        rst_n = 0;
        @(posedge clk); @(posedge clk); @(negedge clk);
        rst_n = 1;
        @(posedge clk);
    end
    endtask

    task run_conv;
        input [N-1:0] val;
    begin
        @(negedge clk);
        Vin = val;
        start = 1;
        @(negedge clk);
        start = 0;

        conv_cycles = 0;
        while (eoc !== 1'b1) begin
            @(posedge clk);
            #1; // settle to read post-edge values
            conv_cycles = conv_cycles + 1;
            if (busy !== 1'b1 && eoc !== 1'b1) begin
                $display("[FAIL] busy deasserted mid-conversion Vin=%0d t=%0t", val, $time);
                errors = errors + 1;
            end
            if (conv_cycles > 400) begin
                $display("[FATAL] conversion hung Vin=%0d", val);
                errors = errors + 1;
                disable run_conv;
            end
        end

        checks = checks + 1;
        if (dout !== val || dout_valid !== 1'b1 || busy !== 1'b0) begin
            $display("[FAIL] Vin=%0d dout=%0d valid=%b busy=%b (latency=%0d)",
                     val, dout, dout_valid, busy, conv_cycles);
            errors = errors + 1;
        end

        @(posedge clk); #1;
        if (eoc === 1'b1) begin
            $display("[FAIL] eoc stuck high after done Vin=%0d", val);
            errors = errors + 1;
        end
    end
    endtask

    integer lat0;
    initial begin
        errors = 0; checks = 0;
        do_reset;

        if (busy!==0 || eoc!==0 || dout_valid!==0 || dac_p!==0 || dout!==0) begin
            $display("[FAIL] bad reset state busy=%b eoc=%b dv=%b dac=%h dout=%h",
                     busy,eoc,dout_valid,dac_p,dout);
            errors = errors + 1;
        end

        for (i = 0; i < (1<<N); i = i + 1) begin
            run_conv(i[N-1:0]);
            if (i == 0) lat0 = conv_cycles;
            else if (conv_cycles !== lat0) begin
                $display("[FAIL] non-constant latency: Vin=%0d lat=%0d vs %0d",
                         i, conv_cycles, lat0);
                errors = errors + 1;
            end
        end
        $display("[INFO] N=%0d exhaustive done. fixed latency(start->eoc)=%0d cycles, checks=%0d",
                 N, lat0, checks);

        Vin = {N{1'b1}};
        @(negedge clk);
        start = 1;
        @(posedge clk); @(posedge clk); @(negedge clk);
        repeat (2) begin
            wait (eoc === 1'b1);
            @(negedge clk);
            if (dout !== Vin) begin
                $display("[FAIL] back-to-back dout=%0d exp=%0d", dout, Vin);
                errors = errors + 1;
            end
        end
        @(negedge clk);
        start = 0;
        wait (busy === 1'b0);

        do_reset;
        Vin = 10'b10_1010_1010 & {N{1'b1}};
        @(negedge clk); start = 1; @(negedge clk); start = 0;
        @(posedge clk);
        @(negedge clk); start = 1; @(negedge clk); start = 0;
        wait (eoc === 1'b1); @(negedge clk);
        checks = checks + 1;
        if (dout !== (10'b10_1010_1010 & {N{1'b1}})) begin
            $display("[FAIL] spurious start corrupted result dout=%0d", dout);
            errors = errors + 1;
        end
        @(posedge clk);

        do_reset;
        Vin = {N{1'b1}};
        @(negedge clk); start = 1; @(negedge clk); start = 0;
        @(posedge clk); @(negedge clk);
        rst_n = 0;
        @(posedge clk); @(negedge clk);
        checks = checks + 1;
        if (busy!==0 || eoc!==0 || dout_valid!==0 || dac_p!==0) begin
            $display("[FAIL] mid-convert reset didn't clear: busy=%b eoc=%b dv=%b dac=%h",
                     busy,eoc,dout_valid,dac_p);
            errors = errors + 1;
        end
        rst_n = 1;
        @(posedge clk);
        run_conv({N{1'b1}});

        $display("==================================================");
        if (errors == 0) begin
            $display("  DEEP VERIFY PASSED  (N=%0d, %0d checks, 0 errors)", N, checks);
            $display("FUNCTIONAL GLS PASSED");
        end else begin
            $display("  DEEP VERIFY FAILED  (N=%0d, %0d errors)", N, errors);
        end
        $display("==================================================");
        $finish;
    end

    initial begin
        #50000000;
        $display("[FATAL] global timeout");
        $finish;
    end
endmodule
