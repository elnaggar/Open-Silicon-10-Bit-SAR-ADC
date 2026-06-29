`timescale 1ns/1ps

module tb_sar_logic;
    parameter N = 8;

    // Testbench signals
    reg            clk;
    reg            rst_n;
    reg            start;
    reg            comp_out;
    wire [N-1:0]   dac_out;
    wire [N-1:0]   dout;
    wire           dout_valid;
    wire           busy;
    wire           eoc;

    // Internal testbench variables
    reg  [N-1:0]   Vin;
    integer        errors;

    // Instantiate DUT
    sar_logic #(.N(N)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .comp_out(comp_out),
        .dac_out(dac_out),
        .dout(dout),
        .dout_valid(dout_valid),
        .busy(busy),
        .eoc(eoc)
    );

    // Clock generation: 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Mock Comparator: compares DAC output against the analog input (Vin)
    always @(*) begin
        comp_out = (dac_out <= Vin);
    end

    // VCD Dump for GTKWave
    initial begin
        $dumpfile("sar_sim.vcd");
        $dumpvars(0, tb_sar_logic);
    end

    // Watchdog Timer (prevents simulation from hanging if 'eoc' never asserts)
    initial begin
        #5000;
        $display("\n[FATAL ERROR] Simulation Timeout! EOC never asserted.");
        $finish;
    end

    // Reusable task to test a specific voltage value
    task test_voltage;
        input [N-1:0] test_val;
        begin
            Vin = test_val;
            
            // Trigger conversion
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;

            // Wait for End of Conversion
            wait(eoc);
            
            // Check results on the next clock cycle when dout_valid should be high
            @(posedge clk);
            if (dout === Vin && dout_valid === 1'b1) begin
                $display("[PASS] Vin = %3d (0x%h) | ADC out = %3d", Vin, Vin, dout);
            end else begin
                $display("[FAIL] Vin = %3d (0x%h) | Expected = %3d, Got = %3d, Valid = %b", 
                         Vin, Vin, Vin, dout, dout_valid);
                errors = errors + 1;
            end
            
            // Small delay between conversions
            #20;
        end
    endtask

    // Main Stimulus Sequence
    initial begin
        // Initialize
        rst_n = 0;
        start = 0;
        Vin   = 0;
        errors = 0;

        // Apply Reset
        #20;
        rst_n = 1;
        #20;

        $display("========================================");
        $display("   Starting SAR ADC Testbench   ");
        $display("========================================");

        // Test Case 1: Mid-scale
        test_voltage(8'd128);

        // Test Case 2: User's original test
        test_voltage(8'hA5);

        // Test Case 3: Zero scale (Edge Case)
        test_voltage(8'd0);

        // Test Case 4: Full scale (Edge Case)
        test_voltage(8'd255);

        // Test Case 5: Random values
        test_voltage(8'd42);
        test_voltage(8'd199);
        test_voltage(8'd7);

        // Final Report
        $display("========================================");
        if (errors == 0)
            $display("   SIMULATION PASSED! (0 Errors)   ");
        else
            $display("   SIMULATION FAILED! (%0d Errors)   ", errors);
        $display("========================================");
        
        $finish;
    end
endmodule
