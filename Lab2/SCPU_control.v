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
	output reg ALUSrc_B,
	output reg ALUSrc_A,
	output reg Jal,
	output reg RegDst,
	output reg RegWrite,
	output reg[1:0] DatatoReg,
	output reg Memread,
	output reg Memwrite,
	output reg[1:0] Branch,
	output reg[2:0] ALU_Control,
	output reg rs_lock,
	output reg rt_lock,
	input  wire reg_stall,  // stall signal when LW instruction followed by an related R instruction
	output reg if_rst,  // stage reset signal
	output reg if_en,  // stage enable signal
	
	output reg id_rst,
	output reg id_en,

	output reg exe_rst,
	output reg exe_en,

	output reg mem_rst,
	output reg mem_en,

	output reg wb_rst,
	output reg wb_en
	
    );
	`define CPU_ctrl_signals {RegDst, ALUSrc_B, DatatoReg, RegWrite, Memread, Memwrite, Branch, Jal, ALU_Control,ALUSrc_A,rs_lock,rt_lock}
	
	//assign mem_w = MemWrite && (~MemRead);
	
	always @ (Fun or OPcode or zero) begin
		case(OPcode)
			6'b100011: begin `CPU_ctrl_signals <= 16'b0_1_01_1_1_0_00_0_010_0_11; end // load
			6'b101011: begin `CPU_ctrl_signals <= 16'bx_1_xx_0_0_1_00_0_010_0_11; end // store
			6'b000100: begin `CPU_ctrl_signals <= {8'bx_0_xx_0_0_0_0, ~zero, 5'b0_110_0,10}; end // beq   //not sure for lock
			6'b000010: begin `CPU_ctrl_signals <= 16'bx_x_xx_0_0_0_10_1_xxx_0_00; end // jump    //not sure
			6'h24: begin `CPU_ctrl_signals <= 16'b0_1_00_1_0_0_00_0_111_0_11; end // slti
			6'h08: begin `CPU_ctrl_signals <= 16'b0_1_00_1_0_0_00_0_010_0_11; end // addi
			6'h0C: begin `CPU_ctrl_signals <= 16'b0_1_00_1_0_0_00_0_000_0_11; end // andi
			6'h0D: begin `CPU_ctrl_signals <= 16'b0_1_00_1_0_0_00_0_001_0_11; end // ori
			6'h0E: begin `CPU_ctrl_signals <= 16'b0_1_00_1_0_0_00_0_011_0_11; end // xori
			6'h0F: begin `CPU_ctrl_signals <= 16'b0_x_10_1_0_0_00_0_xxx_0_11; end // lui
			6'h03: begin `CPU_ctrl_signals <= 16'b0_x_11_1_0_0_10_1_xxx_0_11; end // Jal
			6'h05: begin `CPU_ctrl_signals <= {8'bx_0_xx_0_0_0_0, zero, 5'b0_110_0,11}; end // bne
			6'b000000: begin case(Fun)
				6'b100000: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_010_0_11; end // add
				6'b100010: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_110_0_11; end // sub
				6'b100100: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_000_0_11; end // and
				6'b100101: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_001_0_11; end // or
				6'b101010: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_111_0_11; end // slt
				6'b100111: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_100_0_11; end // nor
				6'b000010: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_101_1_11; end // srl
				6'b010110: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_011_0_11; end // xor
				6'h8: begin `CPU_ctrl_signals <= 16'bx_x_xx_0_0_0_11_1_xxx_0_10; end // jr
				6'h9: begin `CPU_ctrl_signals <= 16'b0_1_11_1_0_0_11_1_xxx_0_10; end // Jalr
				default: begin `CPU_ctrl_signals <= 16'b0; end
			endcase end
			default: begin `CPU_ctrl_signals <= 16'b0; end
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
		if_rst=0;
		if_en=1;
		id_rst=0;
		id_en=1;
		exe_rst=0;
		exe_en=1;
		mem_rst=0;
		mem_en=1;
		wb_rst=0;
		wb_en=1;
		if (rst) begin
			if_rst=1;
			id_rst=1;
			exe_rst=1;
			mem_rst=1;
			wb_rst=1;
		end
		`ifdef DEBUG
		// suspend and step execution
		else if ((debug_en) && ~(~debug_step_prev && debug_step)) begin
			if_en=0;
			id_en=0;
			exe_en=0;
			mem_en=0;
			wb_en=0;
		end
		`endif
		else if (reg_stall) begin
		    // if_en=0;
			 // id_en=0;
			  //xe_rst=1;
	   end
	end


endmodule
