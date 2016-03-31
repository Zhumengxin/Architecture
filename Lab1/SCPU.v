`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:42:04 03/25/2016 
// Design Name: 
// Module Name:    SCPU 
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

module SCPU(// debug
	input wire clk,
	input wire rst,
	`ifdef DEBUG
	input wire debug_en,  // debug enable
	input wire debug_step,  // debug step clock
	input wire [6:0] debug_addr,  // debug address
	output wire [31:0] debug_data,  // debug data
	`endif
	// instruction interfaces
	output wire inst_ren,  // instruction read enable signal
	output wire [31:0] inst_addr,  // address of instruction needed
	input wire [31:0] inst_data,  // instruction fetched
	// memory interfaces
	output wire mem_ren,  // memory read enable signal
	output wire mem_wen,  // memory write enable signal
	output wire [31:0] mem_addr,  // address of memory
	output wire [31:0] mem_dout,  // data writing to memory
	input wire [31:0] mem_din  // data read from memory
    );
	
	 wire mem_w;
	 wire RegDst;
	 wire ALUSrc_B,ALUSrc_A;
	 wire Jal;
	 wire RegWrite;
	 wire [1:0] DatatoReg;
	 wire [1:0] Branch;
	 wire [2:0] ALU_Control;
	 wire zero;
	 
	 assign mem_wen=mem_w;
	 
	 SCPU_control SCPU_control(
		.clk(clk),
		.rst(rst),
		`ifdef DEBUG
		.debug_en(debug_en),
		.debug_step(debug_step),
		`endif
		
		.OPcode(inst_data[31:26]),
	   .Fun(inst_data[5:0]),
		.zero(zero),
		.RegDst(RegDst),
		.ALUSrc_B(ALUSrc_B),
		.ALUSrc_A(ALUSrc_A),
		.Jal(Jal),
		.RegWrite(RegWrite),
		.mem_w(mem_w),
		.DatatoReg(DatatoReg),
		.Branch(Branch),
		.ALU_Control(ALU_Control),
		
		.cpu_rst(cpu_rst),
		.cpu_en(cpu_en)	
	 );
	 
	 Data_path Data_path(
		.clk(clk),
		`ifdef DEBUG
		.debug_addr(debug_addr[5:0]),
		.debug_data(debug_data),
		`endif
		.RegDst(RegDst),
		.ALUSrc_B(ALUSrc_B),
		.ALUSrc_A(ALUSrc_A),
		.Jal(Jal),
		.RegWrite(RegWrite),
		.DatatoReg(DatatoReg),
		.Branch(Branch),
		.ALU_Control(ALU_Control),
		.inst_data(inst_data[31:0]),
		.Data_in(mem_din),
		.ALU_out(mem_addr),
		.Data_out(mem_dout),
		.PC_out(inst_addr),
		.cpu_rst(cpu_rst),
		.cpu_en(cpu_en),
		.zero(zero)
	 );

endmodule
