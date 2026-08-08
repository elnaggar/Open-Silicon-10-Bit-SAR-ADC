//=============================================================================
// sar_logic_diff.v
//
// SAR controller for a binary-weighted DIFFERENTIAL charge-redistribution CDAC.
//
// Changes vs. the original sar_logic.v:
//   1. Explicit acquisition (track) phase with programmable length.
//   2. Bottom-plate sampling: top-plate switch opens BEFORE the bottom plates
//      leave the input, to kill signal-dependent charge injection.
//   3. Explicit comparator reset / strobe outputs, with programmable
//      settling and regeneration time per bit.
//   4. Differential bottom-plate switch controls (dac_p / dac_n) instead of a
//      bare binary word.
//   5. comp_out is only sampled at one defined instant, after the strobe.
//
// Conventional (non-monotonic) switching. Bottom-plate driver convention:
//     samp_bot = 1              -> bottom plate connects to Vip (P) / Vin (N)
//     samp_bot = 0, dac_x[i]=1  -> bottom plate connects to Vrefp
//     samp_bot = 0, dac_x[i]=0  -> bottom plate connects to Vrefn
// The terminating "dummy" C is tied statically (Vrefn on P, Vrefp on N).
//=============================================================================

module sar_logic_diff #(
    parameter integer N          = 10,  // resolution
    parameter integer ACQ_CYCLES = 8,   // track/acquisition length, in clocks
    parameter integer SETTLE_CYC = 2,   // CDAC settling allowed per bit trial
    parameter integer CMP_CYC    = 1    // comparator regeneration time
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             start,
    input  wire             comp_out,   // comparator decision, 1 = Vdac <= Vin

    // ---- analog front-end control ----
    output reg              samp_top,   // top-plate switch to Vcm  (track)
    output reg              samp_bot,   // bottom plates to the input (track)
    output reg              cmp_rst,    // comparator reset / precharge, active high
    output reg              cmp_clk,    // comparator strobe, active high

    // ---- differential CDAC bottom-plate controls ----
    output wire [N-1:0]     dac_p,
    output wire [N-1:0]     dac_n,

    // ---- digital interface ----
    output reg              busy,
    output reg              eoc,
    output reg              dout_valid,
    output reg  [N-1:0]     dout
);

    localparam [2:0] S_IDLE   = 3'd0,
                     S_TRACK  = 3'd1,
                     S_HOLD_T = 3'd2,
                     S_HOLD_B = 3'd3,
                     S_SETTLE = 3'd4,
                     S_CMP    = 3'd5,
                     S_LATCH  = 3'd6,
                     S_DONE   = 3'd7;

    localparam integer IDX_W = (N <= 1) ? 1 : $clog2(N);
    localparam [31:0]      MSB_FULL = N - 1;
    localparam [IDX_W-1:0] MSB_IDX  = MSB_FULL[IDX_W-1:0];

    localparam integer MAXC  = (ACQ_CYCLES > SETTLE_CYC) ?
                              ((ACQ_CYCLES > CMP_CYC) ? ACQ_CYCLES : CMP_CYC) :
                              ((SETTLE_CYC > CMP_CYC) ? SETTLE_CYC : CMP_CYC);
    localparam integer CNT_W = (MAXC < 2) ? 1 : $clog2(MAXC + 1);

    reg [2:0]       state;
    reg [IDX_W-1:0] bit_idx;
    reg [CNT_W-1:0] cnt;
    reg [N-1:0]     sar_reg;   // decided bits
    reg [N-1:0]     trial;     // code currently driven onto the CDAC

    wire [N-1:0] next_code = sar_reg | ({{(N-1){1'b0}}, comp_out} << bit_idx);

    assign dac_p =  trial;
    assign dac_n = ~trial;     // differential complement

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            bit_idx    <= MSB_IDX;
            cnt        <= {CNT_W{1'b0}};
            sar_reg    <= {N{1'b0}};
            trial      <= {N{1'b0}};
            dout       <= {N{1'b0}};
            dout_valid <= 1'b0;
            eoc        <= 1'b0;
            busy       <= 1'b0;
            samp_top   <= 1'b0;
            samp_bot   <= 1'b0;
            cmp_rst    <= 1'b1;
            cmp_clk    <= 1'b0;
        end
        else begin
            dout_valid <= 1'b0;
            eoc        <= 1'b0;

            case (state)

                // -------------------------------------------------- IDLE
                S_IDLE: begin
                    busy     <= 1'b0;
                    samp_top <= 1'b0;
                    samp_bot <= 1'b0;
                    cmp_rst  <= 1'b1;
                    cmp_clk  <= 1'b0;
                    if (start) begin
                        state    <= S_TRACK;
                        busy     <= 1'b1;
                        bit_idx  <= MSB_IDX;
                        sar_reg  <= {N{1'b0}};
                        cnt      <= {CNT_W{1'b0}};
                        samp_top <= 1'b1;          // close top-plate switch
                        samp_bot <= 1'b1;          // bottom plates track input
                    end
                end

                // ------------------------------------------------- TRACK
                S_TRACK: begin
                    if (cnt == ACQ_CYCLES[CNT_W-1:0] - 1'b1) begin
                        state    <= S_HOLD_T;
                        cnt      <= {CNT_W{1'b0}};
                        samp_top <= 1'b0;          // open top plate FIRST
                    end
                    else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                // ----------------------------- HOLD: release bottom plates
                S_HOLD_T: begin
                    samp_bot <= 1'b0;              // then release bottom plates
                    trial    <= ({{(N-1){1'b0}}, 1'b1} << (N-1));  // MSB trial
                    state    <= S_HOLD_B;
                end

                S_HOLD_B: begin
                    state <= S_SETTLE;
                    cnt   <= {CNT_W{1'b0}};
                end

                // ------------------------------------ per-bit: DAC settling
                S_SETTLE: begin
                    cmp_rst <= 1'b1;
                    cmp_clk <= 1'b0;
                    if (cnt == SETTLE_CYC[CNT_W-1:0] - 1'b1) begin
                        state   <= S_CMP;
                        cnt     <= {CNT_W{1'b0}};
                        cmp_rst <= 1'b0;
                        cmp_clk <= 1'b1;           // release comparator
                    end
                    else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                // ------------------------------ per-bit: comparator decides
                S_CMP: begin
                    if (cnt == CMP_CYC[CNT_W-1:0] - 1'b1) begin
                        state <= S_LATCH;
                        cnt   <= {CNT_W{1'b0}};
                    end
                    else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                // ------------------------------- per-bit: capture decision
                S_LATCH: begin
                    cmp_clk <= 1'b0;
                    cmp_rst <= 1'b1;
                    sar_reg <= next_code;

                    if (bit_idx == {IDX_W{1'b0}}) begin
                        trial <= next_code;        // settle DAC at final code
                        state <= S_DONE;
                    end
                    else begin
                        trial   <= next_code |
                                   ({{(N-1){1'b0}}, 1'b1} << (bit_idx - 1'b1));
                        bit_idx <= bit_idx - 1'b1;
                        state   <= S_SETTLE;
                        cnt     <= {CNT_W{1'b0}};
                    end
                end

                // -------------------------------------------------- DONE
                S_DONE: begin
                    dout       <= sar_reg;
                    dout_valid <= 1'b1;
                    eoc        <= 1'b1;
                    busy       <= 1'b0;
                    state      <= S_IDLE;
                end

                default: state <= S_IDLE;

            endcase
        end
    end

endmodule
