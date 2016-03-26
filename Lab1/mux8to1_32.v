`timescale 1ns / 1ps

module mux8to1_32(
	input [31:0] x0,
	input [31:0] x1,
	input [31:0] x2,
	input [31:0] x3,
	input [31:0] x4,
	input [31:0] x5,
	input [31:0] x6,
	input [31:0] x7,
	input [2:0] sel,
	output reg[31:0] o );
	
	always @* begin
		case(sel)
			'b000: o = x0;
			'b001: o = x1;
			'b010: o = x2;
			'b011: o = x3;
			'b100: o = x4;
			'b101: o = x5;
			'b110: o = x6;
			'b111: o = x7;
		endcase
	end

endmodule
