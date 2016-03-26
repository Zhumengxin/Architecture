`timescale 1ns / 1ps

module mux2to1_5 (
	input [4:0] a,
	input [4:0] b,
	input sel,
	output [4:0] o );
	
	assign o = sel ? a : b;

endmodule
