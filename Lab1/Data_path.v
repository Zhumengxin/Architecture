`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:02:34 03/25/2016 
// Design Name: 
// Module Name:    Data_path 
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
module Data_path(
		input wire clk,
		// debug control
		input wire cpu_rst,  // cpu reset signal
		input wire cpu_en,  // cpu enable signal
		// debug
		`ifdef DEBUG
		input wire [5:0] debug_addr,  // debug address
		output wire [31:0] debug_data,  // debug data
		`endif
		input  RegDst,
		input  ALUSrc_B,
		input  ALUSrc_A,
		input  Jal,
		input  RegWrite,
		input  [1:0] DatatoReg,
		input  [1:0] Branch,
		input  [2:0] ALU_Control,
		input [31:0] inst_data,
		input [31:0] Data_in,
		output[31:0] ALU_out,
		output[31:0] Data_out,
		output[31:0] PC_out,
		output zero,
		output overflow 
		
    );
	wire[31:0] pc_4;
	wire[31:0] Imm_32;
	wire[31:0] branch_pc;
	wire[31:0] wt_addr_1;
	wire[31:0] wt_addr_2;
	wire[31:0] wt_data;
	wire[31:0] ALU_A;
	wire[31:0] ALU_B;
	wire[31:0] pc_next;
	wire[31:0] ALU_out_DUMMY;
	wire[31:0] Data_out_DUMMY;
	wire[31:0] PC_out_DUMMY;
	
	assign ALU_out[31:0] = ALU_out_DUMMY[31:0];
	assign Data_out[31:0] = Data_out_DUMMY[31:0];
	assign PC_out[31:0] = PC_out_DUMMY[31:0];
	
	
	// data signals
	wire [31:0] inst_addr_next;
	wire [4:0] addr_rs, addr_rt, addr_rd;
	wire [31:0] data_rs, data_rt, data_imm;
	wire [31:0] alu_out;
	wire rs_rt_equal;
	reg [4:0] regw_addr;
	reg [31:0] regw_data;
	//*/
	// debug
	`ifdef DEBUG
	wire [31:0] debug_data_reg;
	reg [31:0] debug_data_signal;
	
	always @(posedge clk) begin
		case (debug_addr[4:0])
			0: debug_data_signal <= PC_out;
			1: debug_data_signal <= inst_data;
			2: debug_data_signal <= 0;
			3: debug_data_signal <= 0;
			4: debug_data_signal <= 0;
			5: debug_data_signal <= {Imm_32[29:0], 2'b00};
			6: debug_data_signal <= {26'b0,inst_data[10:6]};
			7: debug_data_signal <= 0;
			8: debug_data_signal <= {27'b0, addr_rs};
			9: debug_data_signal <= data_rs;
			10: debug_data_signal <= {27'b0, addr_rt};
			11: debug_data_signal <= data_rt;
			12: debug_data_signal <= Imm_32;//data_imm;
			13: debug_data_signal <= ALU_A;
			14: debug_data_signal <= ALU_B;
			15: debug_data_signal <= ALU_out_DUMMY;
			16: debug_data_signal <= 0;
			17: debug_data_signal <= 0;
			18: debug_data_signal <= {19'b0, 1, 7'b0,1, 3'b0,0};//mem_wen};
			19: debug_data_signal <= ALU_out_DUMMY;
			20: debug_data_signal <= Data_in;
			21: debug_data_signal <= Data_out_DUMMY;
			22: debug_data_signal <= {27'b0, wt_addr_2[4:0]};
			23: debug_data_signal <= wt_data;
			24: debug_data_signal <= {20'b0,RegDst, ALUSrc_B, DatatoReg, RegWrite, Branch, Jal, ALU_Control,ALUSrc_A};
			default: debug_data_signal <= 32'hFFFF_FFFF;
		endcase
	end
	
	assign
		debug_data = debug_addr[5] ? debug_data_signal : debug_data_reg;
	`endif
	
	
	assign
		addr_rs = inst_data[25:21],
		addr_rt = inst_data[20:16],
		addr_rd = inst_data[15:11],
		data_rt = Data_out_DUMMY[31:0];
		
	
	
	add_32  ALU_Branch (.a(pc_4[31:0]), 
							 .b({Imm_32[29:0], 2'b00}), 
							 .c(branch_pc[31:0]));
	
	add_32  ALU_PC_4 (.a(PC_out_DUMMY[31:0]), 
						  .b(32'b00000000_00000000_00000000_00000100), 
						  .c(pc_4[31:0]));
	
	Ext_32  Ext32 (.imm_16(inst_data[15:0]), 
					  .Imm_32(Imm_32[31:0]));
	
	mux2to1_5  mux1 (.a(5'b11111), 
						 .b(inst_data[20:16]), 
						 .sel(Jal), 
						 .o(wt_addr_1[4:0]));
	
	mux2to1_5  mux2 (.a(inst_data[15:11]), 
						 .b(wt_addr_1[4:0]), 
						 .sel(RegDst), 
						 .o(wt_addr_2[4:0]));
	
	mux4to1_32  mux3 (.a(ALU_out_DUMMY[31:0]), 
						  .b(Data_in[31:0]), 
						  .c({inst_data[15:0], 16'b00000000_00000000}), 
						  .d(pc_4[31:0]), 
						  .sel(DatatoReg[1:0]), 
						  .o(wt_data[31:0]));
	
	mux2to1_32  mux4 (.a(Imm_32[31:0]), 
						  .b(Data_out_DUMMY[31:0]), 
						  .sel(ALUSrc_B), 
						  .o(ALU_B[31:0]));
	
	mux4to1_32  mux5 (.a(pc_4[31:0]), 
						  .b(branch_pc[31:0]), 
						  .c({pc_4[31:28], inst_data[25:0], 2'b00}), 
						  .d(ALU_A[31:0]), 
						  .sel(Branch[1:0]), 
						  .o(pc_next[31:0]));
	
	mux2to1_32  mux6 (.b(data_rs[31:0]),
							.a({26'b0,Imm_32[10:6]}),  
						  .sel(ALUSrc_A), 
						  .o(ALU_A[31:0]));
	
	ALU  U1 (.A(ALU_A[31:0]), 
				.ALU_operation(ALU_Control[2:0]), 
				.B(ALU_B[31:0]), 
				.overflow(), 
				.res(ALU_out_DUMMY[31:0]), 
				.zero(zero));
	
	Regs  U2 (.clk(clk), 
				.L_S(RegWrite &cpu_en & ~cpu_rst), 
				.rst(cpu_rst), 
				`ifdef DEBUG
				.debug_addr(debug_addr[5:0]),
				.debug_data(debug_data_reg),
				`endif
				.R_addr_A(addr_rs), 
				.R_addr_B(addr_rt), 
				.Wt_addr(wt_addr_2[4:0]), 
				.Wt_data(wt_data[31:0]), 
				.rdata_A(data_rs), 
				.rdata_B(Data_out_DUMMY[31:0]));
	
	Decode_pc_Int  U3 (.clk(clk),
				.cpu_en(cpu_en),
				.rst(cpu_rst),
				.INT(1'b0), 
				.pc_next(pc_next[31:0]), 
				.RFE(1'b0), 
				.pc(PC_out_DUMMY[31:0]));
	 
	

endmodule
