`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:07:10 05/12/2016 
// Design Name: 
// Module Name:    mux4to1_2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mux4to1_2(
input [1:0] sel,
	input [1:0] a,
	input [1:0] b,
	input [1:0] c,
	input [1:0] d,
	output reg[1:0] o );
	
	always @* begin
		case(sel)
			'b00: o = a;
			'b01: o = b;
			'b10: o = c;
			'b11: o = d;
		endcase
	end

endmodule

