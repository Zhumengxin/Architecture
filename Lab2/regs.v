`timescale 1ns / 1ps
`include "define.vh"
module Regs(
	input clk, rst, L_S,
	// debug
	`ifdef DEBUG
	input wire [4:0] debug_addr,  // debug address
	output wire [31:0] debug_data,  // debug data
	`endif
	input [4:0] R_addr_A, R_addr_B, Wt_addr,
	input [31:0] Wt_data,
	output [31:0] rdata_A, rdata_B );

	reg [31:0] register [1:31];
	integer i;

	assign rdata_A = (R_addr_A == 0)? 0: register[R_addr_A];
	assign rdata_B = (R_addr_B == 0)? 0: register[R_addr_B];

	always @(posedge clk, posedge rst) begin
		if(rst == 1) for(i = 1; i < 32; i = i + 1) register[i] <= 0;
		else if(Wt_addr != 0 && L_S == 1) register[Wt_addr] <= Wt_data;
	end
	
	// debug
	`ifdef DEBUG
		assign debug_data = (debug_addr == 0) ? 0 : register[debug_addr];
	`endif

endmodule
