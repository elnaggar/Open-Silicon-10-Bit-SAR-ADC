module sar_logic #(
    parameter N = 10
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    output reg          eoc,
    output reg          busy,
    input  wire         comp_out,
    output reg [N-1:0]  dac_out,
    output reg [N-1:0]  dout,
    output reg          dout_valid
);

localparam IDLE    = 2'd0;
localparam SAMPLE  = 2'd1;
localparam CONVERT = 2'd2;
localparam DONE    = 2'd3;

localparam IDX_W = $clog2(N);
localparam [31:0]      MSB_FULL = N - 1;
localparam [IDX_W-1:0] MSB_IDX  = MSB_FULL[IDX_W-1:0];   // index of the most-significant bit

reg [1:0]          state;
reg [IDX_W-1:0]    bit_idx;
reg [N-1:0]        sar_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state      <= IDLE;
        dac_out    <= {N{1'b0}};
        dout       <= {N{1'b0}};
        dout_valid <= 1'b0;
        busy       <= 1'b0;
        eoc        <= 1'b0;
        bit_idx    <= MSB_IDX;
        sar_reg    <= {N{1'b0}};
    end
    else begin
        dout_valid <= 1'b0;
        eoc        <= 1'b0;

        case (state)

            IDLE: begin
                busy <= 1'b0;
                if (start) begin
                    state   <= SAMPLE;
                    busy    <= 1'b1;
                    bit_idx <= MSB_IDX;
                    sar_reg <= {N{1'b0}};
                end
            end

            SAMPLE: begin
                state   <= CONVERT;
                dac_out <= ({{N-1{1'b0}}, 1'b1} << (N-1));
            end

            CONVERT: begin
                // Capture comparator result for current bit
                if (comp_out)
                    sar_reg <= sar_reg | ({{N-1{1'b0}}, 1'b1} << bit_idx);

                if (bit_idx == 0) begin
                    state   <= DONE;
                    // update dac_out on the final bit too
                    dac_out <= sar_reg | ({{N-1{1'b0}}, comp_out} << bit_idx);
                end
                else begin
                    bit_idx <= bit_idx - 1'b1;
                    dac_out <= (sar_reg | ({{N-1{1'b0}}, comp_out} << bit_idx))
                             | ({{N-1{1'b0}}, 1'b1} << (bit_idx - 1'b1));
                end
            end

            DONE: begin
                dout       <= sar_reg;
                dout_valid <= 1'b1;
                eoc        <= 1'b1;
                busy       <= 1'b0;
                state      <= IDLE;
            end

        endcase
    end
end

endmodule
