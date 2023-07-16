// Copyright (c) 2023 Taitapa Technologies Ltd
// Author: Benjamin Mordaunt
//
// Description:
//  Simple radix-4 (2bpc) Booth multiplier.

parameter TTPA_BOOTH_ARG_WIDTH = 16;
parameter TTPA_BOOTH_ARG_WIDTH_CLOG             = $clog2(TTPA_BOOTH_ARG_WIDTH);
parameter TTPA_BOOTH_ARG_WIDTH_CLOG_SUB_ONE     = TTPA_BOOTH_ARG_WIDTH_CLOG - 1;
parameter TTPA_BOOTH_ARG_WIDTH_PLUS_ONE = TTPA_BOOTH_ARG_WIDTH + 1;
parameter TTPA_BOOTH_ARG_WIDTH_SUB_ONE = TTPA_BOOTH_ARG_WIDTH - 1;
parameter TTPA_BOOTH_ARG_WIDTH_MUL_TWO = TTPA_BOOTH_ARG_WIDTH * 2;
parameter TTPA_BOOTH_ARG_WIDTH_MUL_TWO_SUB_ONE = TTPA_BOOTH_ARG_WIDTH * 2 - 1;
parameter TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_ONE = TTPA_BOOTH_ARG_WIDTH * 2 + 1;
parameter TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_TWO = TTPA_BOOTH_ARG_WIDTH * 2 + 2;

module booth_radix4 (
  input logic [TTPA_BOOTH_ARG_WIDTH_SUB_ONE:0] M,
  input logic [TTPA_BOOTH_ARG_WIDTH_SUB_ONE:0] A,
  input logic clk,
  input logic resetn,
  output logic valid,
  output logic [TTPA_BOOTH_ARG_WIDTH_MUL_TWO_SUB_ONE:0] product
);

reg [TTPA_BOOTH_ARG_WIDTH_PLUS_ONE:0] M_ext;
reg [TTPA_BOOTH_ARG_WIDTH_PLUS_ONE:0] M_neg;
reg [TTPA_BOOTH_ARG_WIDTH_PLUS_ONE:0] M_2;
reg [TTPA_BOOTH_ARG_WIDTH_PLUS_ONE:0] M_neg2;
reg [TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_ONE:0] partial_product;
reg [TTPA_BOOTH_ARG_WIDTH_CLOG_SUB_ONE:0] count;

logic [TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_ONE:0] addend;
logic [TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_ONE:0] pp_se_lsr1;
logic [TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_ONE:0] pp_se_lsr1_add;

assign M_ext = {{2{M[TTPA_BOOTH_ARG_WIDTH_SUB_ONE]}}, M[TTPA_BOOTH_ARG_WIDTH_SUB_ONE:0]};
assign M_neg  = -M_ext;
assign M_2    = M_ext << 1;
assign M_neg2 = M_neg << 1;
assign pp_se_lsr1 = {partial_product[TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_ONE], partial_product[TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_ONE:1]};
assign pp_se_lsr1_add = pp_se_lsr1 + addend;

// Partial product multiplier selection
always_comb begin
  case (partial_product[2:0])
    3'b000         : addend = TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_TWO'('b0);
    3'b001, 3'b010 : addend = {M_ext, TTPA_BOOTH_ARG_WIDTH'('b0)};
    3'b011         : addend = {M_2, TTPA_BOOTH_ARG_WIDTH'('b0)};
    3'b100         : addend = {M_neg2, TTPA_BOOTH_ARG_WIDTH'('b0)};
    3'b101, 3'b110 : addend = {M_neg, TTPA_BOOTH_ARG_WIDTH'('b0)};
    3'b111         : addend = TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_TWO'('b0);
    default        : addend = TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_TWO'(1'bx);
  endcase
end

always_ff @(posedge clk, negedge resetn) begin
  if (resetn == 0) begin
    partial_product <= TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_TWO'('b0);
    product <= TTPA_BOOTH_ARG_WIDTH_MUL_TWO'('b0);
    count <= 'b0;
    valid <= 0;
  end else begin
    if (count == 0) begin
      partial_product <= {TTPA_BOOTH_ARG_WIDTH_PLUS_ONE'('b0), A[TTPA_BOOTH_ARG_WIDTH_SUB_ONE:0], 1'b0};
      count <= count + 1;
    end
    else begin
      if (count <= TTPA_BOOTH_ARG_WIDTH_CLOG'(TTPA_BOOTH_ARG_WIDTH >> 1)) begin
        partial_product <= {pp_se_lsr1_add[TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_ONE], pp_se_lsr1_add[TTPA_BOOTH_ARG_WIDTH_MUL_TWO_PLUS_ONE:1]};
        count <= count + 1;
      end
      else
        valid <= 1;
        product <= partial_product[TTPA_BOOTH_ARG_WIDTH_MUL_TWO:1];
    end
  end
end

`ifdef COCOTB_SIM
initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0, booth_radix4);
end
`endif

endmodule : booth_radix4
