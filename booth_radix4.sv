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
  output logic [8:0] product
);

reg [4:0] M_ext;
reg [4:0] M_neg;
reg [4:0] M_2;
reg [4:0] M_neg2;
reg [9:0] partial_product;
reg [1:0] count;

logic [4:0] addend;

assign M_ext  = {M[3], M[3:0]};
assign M_neg  = -M_ext;
assign M_2    = M_ext << 1;
assign M_neg2 = M_neg << 1;

// Partial product multiplier selection
always_comb begin
  case (partial_product[2:0])
    3'b000         : addend = 5'b0;
    3'b001, 3'b010 : addend = M_ext;
    3'b011         : addend = M_2;
    3'b100         : addend = M_neg2;
    3'b101, 3'b110 : addend = M_neg;
    3'b111         : addend = 5'b0;
    default        : addend = 5'bx;
  endcase
end

always_ff @(posedge clk, negedge resetn) begin
  if (resetn == 0) begin
    partial_product <= 10'b0;
    product <= 9'b0;
    count <= 2'b0;
    valid <= 0;
  end else begin
    if (count == 0) begin
      partial_product <= {{5{A[3]}}, A[3:0], 1'b0};
      count <= count + 1;
    end
    else begin
      if (count <= 2) begin
        partial_product <= ({(partial_product[9:5] + addend), partial_product[4:0]} >>> 2);
        count <= count + 1;
      end
      else
        valid <= 1;
        product <= partial_product[9:1];
    end
  end
end

endmodule : booth_radix4
