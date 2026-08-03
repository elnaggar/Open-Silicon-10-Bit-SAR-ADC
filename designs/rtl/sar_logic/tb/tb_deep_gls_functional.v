`timescale 1ns/1ps
//
// FUNCTIONAL gate-level testbench for sar_logic (Icarus + -DFUNCTIONAL).
//
// The gf180mcu cell models wrap their timing (specify) blocks in
// `ifndef FUNCTIONAL`. Icarus cannot compile the edge-sensitive `ifnone`
// paths in those blocks, so we compile with -DFUNCTIONAL (logic only) and
// DROP $sdf_annotate. This verifies the post-layout netlist is LOGICALLY
// correct (synthesis/PnR did not corrupt the logic). Timing is covered
// separately and already signed off by STA.
//
// USAGE:
//   iverilog -g2012 -DFUNCTIONAL -s tb_deep -o gls_sar.vvp \
//       $PDK/primitives.v $PDK/gf180mcu_fd_sc_mcu7t5v0.v \
//       runs/RUN_.../final/nl/sar_logic.nl.v  tb_deep_gls_functional.v
//   vvp gls_sar.vvp
//
//   Quick smoke test: add -DN=4 (16 codes instead of 1024).
//
module tb_deep;
    // Must match the netlist's synthesized width. This netlist is 10-bit.
    // The netlist has NO parameters, so N is a plain TB-side constant here.
    localparam N = 10;

    localparam HALF_PERIOD = 40;   // ns -> 80 ns period (not timing-critical here)
    localparam SETTLE      = 1;    // zero-delay: #1 settles deltas

    reg              clk, rst_n, start, comp_out;
    wire [N-1:0]     dac_out, dout;
    wire             dout_valid, busy, eoc;

    reg  [N-1:0]     Vin;
    integer          errors, checks;
    integer          i, cyc, conv_cycles;

    // <== GLS: no #(.N(...)) -- the netlist has no parameters.
    sar_logic dut (
        .clk(clk), .rst_n(rst_n), .start(start), .comp_out(comp_out),
        .dac_out(dac_out), .dout(dout), .dout_valid(dout_valid),
        .busy(busy), .eoc(eoc)
    );

    // Ideal linear comparator
    always @(*) comp_out = (dac_out <= Vin);

    // Clock
    initial clk = 0;
    always #HALF_PERIOD clk = ~clk;

    // ---- global assertions running every cycle ----
    always @(posedge clk) if (rst_n) begin
        if (^{busy, eoc, dout_valid} === 1'bx) begin
            $display("[FAIL] X on control outputs at t=%0t", $time);
            errors = errors + 1;
        end
        if (eoc !== dout_valid) begin
            $display("[FAIL] eoc(%b) != dout_valid(%b) at t=%0t", eoc, dout_valid, $time);
            errors = errors + 1;
        end
    end

    task do_reset;
    begin
        rst_n = 0; start = 0; Vin = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
    end
    endtask

    task run_conv;
        input [N-1:0] val;
        integer prev_dac;
        integer traj_err;
    begin
        Vin = val;
        traj_err = 0;
        @(posedge clk); start = 1;
        @(posedge clk); start = 0;

        conv_cycles = 0;
        prev_dac = -1;
        while (eoc !== 1'b1) begin
            @(posedge clk);
            #SETTLE;
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

        checks = checks + 1;
        if (dout !== val || dout_valid !== 1'b1 || busy !== 1'b0) begin
            $display("[FAIL] Vin=%0d dout=%0d valid=%b busy=%b (latency=%0d)",
                     val, dout, dout_valid, busy, conv_cycles);
            errors = errors + 1;
        end

        @(posedge clk); #SETTLE;
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

        if (busy!==0 || eoc!==0 || dout_valid!==0 || dac_out!==0 || dout!==0) begin
            $display("[FAIL] bad reset state busy=%b eoc=%b dv=%b dac=%h dout=%h",
                     busy,eoc,dout_valid,dac_out,dout);
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
        start = 1;
        @(posedge clk); @(posedge clk);
        repeat (2) begin
            wait (eoc === 1'b1);
            #SETTLE;
            if (dout !== Vin) begin
                $display("[FAIL] back-to-back dout=%0d exp=%0d", dout, Vin);
                errors = errors + 1;
            end
            @(posedge clk);
        end
        start = 0;
        wait (busy === 1'b0);

        do_reset;
        Vin = 10'b10_1010_1010 & {N{1'b1}};
        @(posedge clk); start = 1; @(posedge clk); start = 0;
        @(posedge clk);
        @(posedge clk); start = 1; @(posedge clk); start = 0;
        wait (eoc === 1'b1); #SETTLE;
        checks = checks + 1;
        if (dout !== (10'b10_1010_1010 & {N{1'b1}})) begin
            $display("[FAIL] spurious start corrupted result dout=%0d", dout);
            errors = errors + 1;
        end
        @(posedge clk);

        do_reset;
        Vin = {N{1'b1}};
        @(posedge clk); start = 1; @(posedge clk); start = 0;
        @(posedge clk); @(posedge clk);
        rst_n = 0;
        @(posedge clk); #SETTLE;
        checks = checks + 1;
        if (busy!==0 || eoc!==0 || dout_valid!==0 || dac_out!==0) begin
            $display("[FAIL] mid-convert reset didn't clear: busy=%b eoc=%b dv=%b dac=%h",
                     busy,eoc,dout_valid,dac_out);
            errors = errors + 1;
        end
        rst_n = 1;
        @(posedge clk);
        run_conv({N{1'b1}});

        $display("==================================================");
        if (errors == 0)
            $display("  FUNCTIONAL GLS PASSED  (N=%0d, %0d checks, 0 errors)", N, checks);
        else
            $display("  FUNCTIONAL GLS FAILED  (N=%0d, %0d errors)", N, errors);
        $display("==================================================");
        $finish;
    end

    initial begin
        #50000000;
        $display("[FATAL] global timeout");
        $finish;
    end
endmodule
