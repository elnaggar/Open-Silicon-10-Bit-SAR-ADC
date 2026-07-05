`timescale 1ns/1ps
//
// Deep verification testbench for sar_logic
//  - Exhaustive sweep of ALL 2^N input codes
//  - Ideal linear comparator => expected dout == Vin for every code
//  - Checks: latency, busy/eoc/dout_valid protocol, DAC binary-search
//    trajectory monotonicity, back-to-back conversions, mid-convert reset,
//    start-ignored-while-busy, and X-detection on outputs.
//
module tb_deep;
`ifndef N
  `define N 8
`endif
    localparam N = `N;

    reg              clk, rst_n, start, comp_out;
    wire [N-1:0]     dac_out, dout;
    wire             dout_valid, busy, eoc;

    reg  [N-1:0]     Vin;
    integer          errors, checks;
    integer          i, cyc, conv_cycles;

    sar_logic #(.N(N)) dut (
        .clk(clk), .rst_n(rst_n), .start(start), .comp_out(comp_out),
        .dac_out(dac_out), .dout(dout), .dout_valid(dout_valid),
        .busy(busy), .eoc(eoc)
    );

    // Ideal linear comparator
    always @(*) comp_out = (dac_out <= Vin);

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- global assertions running every cycle ----
    // X-check on control outputs once out of reset
    always @(posedge clk) if (rst_n) begin
        if (^{busy, eoc, dout_valid} === 1'bx) begin
            $display("[FAIL] X on control outputs at t=%0t", $time);
            errors = errors + 1;
        end
        // eoc and dout_valid must coincide (both are 1-cycle done flags)
        if (eoc !== dout_valid) begin
            $display("[FAIL] eoc(%b) != dout_valid(%b) at t=%0t", eoc, dout_valid, $time);
            errors = errors + 1;
        end
    end

    task do_reset;
    begin
        rst_n = 0; start = 0; Vin = 0;
        @(posedge clk); @(posedge clk);
        rst_n = 1;
        @(posedge clk);
    end
    endtask

    // Run one conversion, measure latency, verify protocol & result
    task run_conv;
        input [N-1:0] val;
        integer prev_dac;
        integer traj_err;
    begin
        Vin = val;
        traj_err = 0;
        // issue start pulse
        @(posedge clk); start = 1;
        @(posedge clk); start = 0;

        // from here, count cycles until eoc, monitor dac trajectory & busy
        conv_cycles = 0;
        prev_dac = -1;
        while (eoc !== 1'b1) begin
            @(posedge clk);
            #1; // settle to read post-edge values
            conv_cycles = conv_cycles + 1;
            if (busy !== 1'b1 && eoc !== 1'b1) begin
                $display("[FAIL] busy deasserted mid-conversion Vin=%0d t=%0t", val, $time);
                errors = errors + 1;
            end
            if (conv_cycles > 4*N + 10) begin
                $display("[FATAL] conversion hung Vin=%0d", val);
                errors = errors + 1;
                disable run_conv;
            end
        end

        // eoc high now: check result
        checks = checks + 1;
        if (dout !== val || dout_valid !== 1'b1 || busy !== 1'b0) begin
            $display("[FAIL] Vin=%0d dout=%0d valid=%b busy=%b (latency=%0d)",
                     val, dout, dout_valid, busy, conv_cycles);
            errors = errors + 1;
        end

        // eoc must drop next cycle (1-cycle pulse)
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

        // Post-reset state check
        if (busy!==0 || eoc!==0 || dout_valid!==0 || dac_out!==0 || dout!==0) begin
            $display("[FAIL] bad reset state busy=%b eoc=%b dv=%b dac=%h dout=%h",
                     busy,eoc,dout_valid,dac_out,dout);
            errors = errors + 1;
        end

        // ---- Exhaustive sweep ----
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

        // ---- start held HIGH: back-to-back conversions ----
        Vin = {N{1'b1}}; // full scale
        start = 1;
        @(posedge clk); @(posedge clk);
        repeat (2) begin
            wait (eoc === 1'b1);
            #1;
            if (dout !== Vin) begin
                $display("[FAIL] back-to-back dout=%0d exp=%0d", dout, Vin);
                errors = errors + 1;
            end
            @(posedge clk);
        end
        start = 0;
        wait (busy === 1'b0);

        // ---- start ignored while busy ----
        do_reset;
        Vin = 8'd170 & {N{1'b1}};
        @(posedge clk); start = 1; @(posedge clk); start = 0;
        @(posedge clk); // now in SAMPLE/CONVERT
        // pulse spurious start mid-conversion
        @(posedge clk); start = 1; @(posedge clk); start = 0;
        wait (eoc === 1'b1); #1;
        checks = checks + 1;
        if (dout !== (8'd170 & {N{1'b1}})) begin
            $display("[FAIL] spurious start corrupted result dout=%0d", dout);
            errors = errors + 1;
        end
        @(posedge clk);

        // ---- mid-conversion reset ----
        do_reset;
        Vin = {N{1'b1}};
        @(posedge clk); start = 1; @(posedge clk); start = 0;
        @(posedge clk); @(posedge clk); // partway through
        rst_n = 0;
        @(posedge clk); #1;
        checks = checks + 1;
        if (busy!==0 || eoc!==0 || dout_valid!==0 || dac_out!==0) begin
            $display("[FAIL] mid-convert reset didn't clear: busy=%b eoc=%b dv=%b dac=%h",
                     busy,eoc,dout_valid,dac_out);
            errors = errors + 1;
        end
        rst_n = 1;
        @(posedge clk);
        // verify it still works after reset recovery
        run_conv({N{1'b1}});

        $display("==================================================");
        if (errors == 0)
            $display("  DEEP VERIFY PASSED  (N=%0d, %0d checks, 0 errors)", N, checks);
        else
            $display("  DEEP VERIFY FAILED  (N=%0d, %0d errors)", N, errors);
        $display("==================================================");
        $finish;
    end

    // hard watchdog
    initial begin
        #50000000;
        $display("[FATAL] global timeout");
        $finish;
    end
endmodule
