`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:11:14 03/25/2016 
// Design Name: 
// Module Name:    SCPU_control 
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
`include "define.vh"
module SCPU_control(
	input wire clk,  // main clock
	input wire rst,  // synchronous reset
	// debug
	`ifdef DEBUG
	input wire debug_en,  // debug enable
	input wire debug_step,  // debug step clock
	`endif
	input[5:0] OPcode,
	input[5:0] Fun,
	input zero,
	output reg RegDst,
	output reg ALUSrc_B,
	output reg ALUSrc_A,
	output reg Jal,
	output reg RegWrite,
	output     mem_w,
	output reg[1:0] DatatoReg,
	output reg[1:0] Branch,
	output reg[2:0] ALU_Control,
	// debug control
	output reg cpu_rst,  // cpu reset signal
	output reg cpu_en  // cpu enable signal
    );
   
	reg MemWrite, MemRead;
	
	`define CPU_ctrl_signals {RegDst, ALUSrc_B, DatatoReg, RegWrite, MemRead, MemWrite, Branch, Jal, ALU_Control,ALUSrc_A}
	
	assign mem_w = MemWrite && (~MemRead) && cpu_en;
	
	always @ (Fun or OPcode or zero) begin
		case(OPcode)
			6'b100011: begin `CPU_ctrl_signals <= 14'b0_1_01_1_1_0_00_0_010_0; end // load
			6'b101011: begin `CPU_ctrl_signals <= 14'bx_1_xx_0_0_1_00_0_010_0; end // store
			6'b000100: begin `CPU_ctrl_signals <= {8'bx_0_xx_0_0_0_0, ~zero, 5'b0_110_0}; end // beq
			6'b000010: begin `CPU_ctrl_signals <= 14'bx_x_xx_0_0_0_10_0_xxx_0; end // jump
			6'h24: begin `CPU_ctrl_signals <= 14'b0_1_00_1_0_0_00_0_111_0; end // slti
			6'h08: begin `CPU_ctrl_signals <= 14'b0_1_00_1_0_0_00_0_010_0; end // addi
			6'h0C: begin `CPU_ctrl_signals <= 14'b0_1_00_1_0_0_00_0_000_0; end // andi
			6'h0D: begin `CPU_ctrl_signals <= 14'b0_1_00_1_0_0_00_0_001_0; end // ori
			6'h0E: begin `CPU_ctrl_signals <= 14'b0_1_00_1_0_0_00_0_011_0; end // xori
			6'h0F: begin `CPU_ctrl_signals <= 14'b0_x_10_1_0_0_00_0_xxx_0; end // lui
			6'h03: begin `CPU_ctrl_signals <= 14'b0_x_11_1_0_0_10_1_xxx_0; end // Jal
			6'h05: begin `CPU_ctrl_signals <= {8'bx_0_xx_0_0_0_0, zero, 5'b0_110_0}; end // bne
			6'b000000: begin case(Fun)
				6'b100000: begin `CPU_ctrl_signals <= 14'b1_0_00_1_0_0_00_0_010_0; end // add
				6'b100010: begin `CPU_ctrl_signals <= 14'b1_0_00_1_0_0_00_0_110_0; end // sub
				6'b100100: begin `CPU_ctrl_signals <= 14'b1_0_00_1_0_0_00_0_000_0; end // and
				6'b100101: begin `CPU_ctrl_signals <= 14'b1_0_00_1_0_0_00_0_001_0; end // or
				6'b101010: begin `CPU_ctrl_signals <= 14'b1_0_00_1_0_0_00_0_111_0; end // slt
				6'b100111: begin `CPU_ctrl_signals <= 14'b1_0_00_1_0_0_00_0_100_0; end // nor
				6'b000010: begin `CPU_ctrl_signals <= 14'b1_0_00_1_0_0_00_0_101_1; end // srl
				6'b010110: begin `CPU_ctrl_signals <= 14'b1_0_00_1_0_0_00_0_011_0; end // xor
				6'h8: begin `CPU_ctrl_signals <= 14'bx_x_xx_0_0_0_11_0_xxx_0; end // jr
				6'h9: begin `CPU_ctrl_signals <= 14'b0_1_11_1_0_0_11_0_xxx_0; end // Jalr
				default: begin `CPU_ctrl_signals <= 14'b0; end
			endcase end
			default: begin `CPU_ctrl_signals <= 14'b0; end
		endcase
	end
	
	
	// debug control
	`ifdef DEBUG
	reg debug_step_prev;
	
	always @(posedge clk) begin
		debug_step_prev <= debug_step;
	end
	`endif
	
	always @(*) begin
		cpu_rst = 0;
		cpu_en = 1;
		if (rst) begin
			cpu_rst = 1;
		end
		`ifdef DEBUG
		// suspend and step execution
		else if ((debug_en) && ~(~debug_step_prev && debug_step)) begin
			cpu_en = 0;
		end
		`endif
	end


endmodule
