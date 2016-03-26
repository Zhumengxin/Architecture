`timescale 1ns / 1ps

module mux4to1_32 (
	input [1:0] sel,
	input [31:0] a,
	input [31:0] b,
	input [31:0] c,
	input [31:0] d,
	output reg[31:0] o );
	
	always @* begin
		case(sel)
			'b00: o = a;
			'b01: o = b;
			'b10: o = c;
			'b11: o = d;
		endcase
	end

endmodule
