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
	
	 wire mem_w_controller,mem_r_controller;
	 wire RegDst;
	 wire ALUSrc_B,ALUSrc_A;
	 wire Jal;
	 wire RegWrite;
	 wire [1:0] DatatoReg;
	 wire [1:0] Branch;
	 wire [2:0] ALU_Control;
	 wire zero;
	 //new for lab2
	 wire rs_lock,rt_lock;
	 wire reg_stall;
	 wire if_rst, if_en;
	 wire id_rst, id_en;
	 wire exe_rst, exe_en;
	 wire mem_rst, mem_en;
	 wire wb_rst, wb_en;
	 wire [31:0] inst_data_control;
	 
	 
	 //assign mem_wen=mem_w;
	 
	 SCPU_control SCPU_control(
		.clk(clk),
		.rst(rst),
		`ifdef DEBUG
		.debug_en(debug_en),
		.debug_step(debug_step),
		`endif
		.OPcode(inst_data_control[31:26]),
	    .Fun(inst_data_control[5:0]),
		.zero(zero),
		.RegDst(RegDst),
		.DatatoReg(DatatoReg),
		.ALUSrc_B(ALUSrc_B),
		.ALUSrc_A(ALUSrc_A),
		.Jal(Jal),
		.RegWrite(RegWrite),
		.Memread(mem_r_controller),
		.Memwrite(mem_w_controller),
		.Branch(Branch),
		.ALU_Control(ALU_Control),
		.reg_stall(reg_stall),
		.rs_lock(rs_lock),
		.rt_lock(rt_lock),
		.if_rst(if_rst),
		.if_en(if_en),
		
		.id_rst(id_rst),
		.id_en(id_en),
		
		.exe_rst(exe_rst),
		.exe_en(exe_en),
		
		.mem_rst(mem_rst),
		.mem_en(mem_en),
		
		.wb_rst(wb_rst),
		.wb_en(wb_en)
		
	 );
	 
	 Data_path Data_path(
		.clk(clk),
		`ifdef DEBUG
		.debug_addr(debug_addr[5:0]),
		.debug_data(debug_data),
		`endif
		.inst_data(inst_data[31:0]),
		.inst_data_id(inst_data_control[31:0]),
		.RegDst(RegDst),
		.RegWrite(RegWrite),
		.DatatoReg(DatatoReg),
		.ALUSrc_B(ALUSrc_B),
		.ALUSrc_A(ALUSrc_A),
		.ALU_Control(ALU_Control),
		.Jal(Jal),
		.Branch(Branch),
		.reg_stall(reg_stall),
		.rs_lock(rs_lock),
		.rt_lock(rt_lock),
		.if_rst(if_rst),
		.if_en(if_en),
		.id_rst(id_rst),
		.id_en(id_en),
		.exe_rst(exe_rst),
		.exe_en(exe_en),
		.mem_rst(mem_rst),
		.mem_en(mem_en),
		.wb_rst(wb_rst),
		.wb_en(wb_en),
		
		.mem_r_control(mem_r_controller),
		.mem_w_control(mem_w_controller),
		.mem_r(mem_ren),
		.mem_w(mem_wen),
		
		.Data_in(mem_din),
		.ALU_out(mem_addr),
		.Data_out(mem_dout),
		.inst_addr(inst_addr),
		.zero(zero)
	 );

endmodule
