// Copyright (c) 2023 Taitapa Technologies Ltd
// Author: Benjamin Mordaunt
//
// Description:
//  Simple radix-4 (2bpc) Booth multiplier.

module booth_radix4 (
  input logic [3:0] M,
  input logic [3:0] A,
  input logic clk,
  input logic resetn,
  output logic valid,
  output logic [7:0] product
);

reg [3:0] M_neg;
reg [3:0] M_2;
reg [3:0] M_neg2;
reg [8:0] partial_product;
reg [1:0] count;

logic [8:0] addend;
logic [8:0] pp_se_lsr1;
logic [8:0] pp_se_lsr1_add;

assign M_neg  = -M;
assign M_2    = M << 1;
assign M_neg2 = M_neg << 1;
assign pp_se_lsr1 = {partial_product[8], partial_product[8:1]};
assign pp_se_lsr1_add = pp_se_lsr1 + addend;

// Partial product multiplier selection
always_comb begin
  case (partial_product[2:0])
    3'b000         : addend = 9'b0;
    3'b001, 3'b010 : addend = {M[3], M, 4'b0};
    3'b011         : addend = {M_2[3], M_2, 4'b0};
    3'b100         : addend = {M_neg2[3], M_neg2, 4'b0};
    3'b101, 3'b110 : addend = {M_neg[3], M_neg, 4'b0};
    3'b111         : addend = 9'b0;
    default        : addend = 9'bx;
  endcase
end

always_ff @(posedge clk, negedge resetn) begin
  if (resetn == 0) begin
    partial_product <= 9'b0;
    product <= 8'b0;
    count <= 2'b0;
    valid <= 0;
  end else begin
    if (count == 0) begin
      partial_product <= {4'b0, A[3:0], 1'b0};
      count <= count + 1;
    end
    else begin
      if (count <= 2) begin
        partial_product <= {pp_se_lsr1_add[8], pp_se_lsr1_add[8:1]};
        count <= count + 1;
      end
      else
        valid <= 1;
        product <= partial_product[8:1];
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
