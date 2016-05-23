`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Zhu Mengxin  
// mail: mxinzhu@foxmail.com 
// 
//////////////////////////////////////////////////////////////////////////////////
`include "define.vh"
module Data_path(
		input wire clk,
		input rst,
		// debug
		`ifdef DEBUG
		input wire [5:0] debug_addr,  // debug address
		output wire [31:0] debug_data,  // debug data
		`endif
		input [31:0] inst_data,
		input [31:0] Data_in,
		output[31:0] ALU_out,
		output[31:0] Data_out,
		output reg [31:0] inst_addr,   // out for get data from instruction memory
		
		output reg[31:0]  inst_data_id,  //transfer it to controller
		output reg[31:0]  inst_data_mem,
		output reg[31:0]  inst_data_exe,
		output reg[31:0]  inst_data_wb,
		output zero,
		output reg [1:0] Branch_mem,

		//signal from controller
		input  [2:0] ALU_Control,
		input  ALUSrc_B,
		input  ALUSrc_A,
		input  [1:0] Branch,
		input [1:0] Branch2,
		input  Jal,
		input  RegDst,
		input  RegWrite,
		input  [1:0] DatatoReg,
		input mem_r_control,
		input mem_w_control,
		//input rs_lock,
		//input rt_lock,
		output  mem_r,
		output  mem_w,
		output inst_r,

		input if_rst,
		input if_en,
		input id_rst,
		input id_en,
		input exe_rst,
		input exe_en,
		input mem_rst,
		input mem_en,
		input wb_rst,
		input wb_en,
		
		input wire data_stall,
		input wire branch_stall,	
		output overflow,   //no use temply

		input wire[1:0] ForwardA,
		input wire[1:0] ForwardB

		
    );
	reg[31:0] pc_4_if,pc_4_id,pc_4_exe,pc_4_mem,pc_4_wb;
	wire [31:0] pc_4_if_wire,pc_next;
	wire[31:0] addr_rs_id,addr_rt_id,addr_rd_id;
	wire[15:0] imm_16;
	reg[31:0] inst_addr_id,inst_addr_exe,inst_addr_mem;
	//reg[31:0] inst_data_exe,inst_data_mem,inst_data_wb;
	reg[31:0] Imm_32,Imm_32_exe;
	wire[31:0] Imm_32_id;
	wire[31:0] branch_pc;     //the address finally jump using beq and bne
	reg[31:0] branch_pc_mem;
	reg[4:0]   Reg_addr_mem,Reg_addr_wb;   //reg address that want to be written
	wire[4:0] wt_addr_1, wt_addr_2;
	reg[4:0]  addr_rd_exe,addr_rt_exe;
	reg[31:0] data_rs_exe,data_rt_exe,data_rs_mem,data_rt_mem;
	wire[31:0] data_rs_id,data_rt_id; 
	wire[31:0] Reg_data_wb;   //data want to be written to reg
	//wire  
	wire[31:0] ALU_A;
	wire[31:0] ALU_B;
	//wire[31:0] ;
	reg[31:0] ALU_out_mem,ALU_out_wb;
	wire[31:0] ALU_out_DUMMY;
	//wire[31:0] Data_out_DUMMY;
	wire[31:0] PC_out;
	reg[31:0] Mem_data;
	//all signal,others in parameter table
	reg[2:0] ALU_Control_exe;
	reg ALUSrc_A_exe,ALUSrc_B_exe;
	reg[1:0] Branch_exe,Branch2_exe;
	wire[1:0] finalBranch;
	reg Jal_exe,Jal_mem;
	reg RegDst_exe,RegDst_mem;
	reg RegWrite_exe,RegWrite_mem,RegWrite_wb;
	reg[1:0] DatatoReg_exe,DatatoReg_mem,DatatoReg_wb; 
	reg mem_r_exe,mem_r_mem;
	reg mem_w_exe,mem_w_mem;
	reg inst_ren;

	wire [31:0] data_rs_final,data_rt_final;
	//*/
	// debug
	`ifdef DEBUG
	wire [31:0] debug_data_reg;
	reg [31:0] debug_data_signal;
	
	always @(posedge clk) begin
		case (debug_addr[4:0])
			0: debug_data_signal <= inst_addr;
			1: debug_data_signal <= inst_data;
			2: debug_data_signal <= inst_addr_id;
			3: debug_data_signal <= inst_data_id;
			4: debug_data_signal <= inst_addr_exe;
			5: debug_data_signal <= inst_data_exe;
			6: debug_data_signal <= inst_addr_mem;
			7: debug_data_signal <= inst_data_mem;
			8: debug_data_signal <= {27'b0, addr_rs_id};
			9: debug_data_signal <= data_rs_id;
			10: debug_data_signal <= {27'b0, addr_rt_id};
			11: debug_data_signal <= data_rt_id;
			12: debug_data_signal <= Imm_32_exe;//data_imm;
			13: debug_data_signal <= ALU_A;
			14: debug_data_signal <= ALU_B;
			15: debug_data_signal <= ALU_out_DUMMY;
			16: debug_data_signal <= {27'b0,wt_addr_2[4:0]};
			17: debug_data_signal <= Branch_mem;
			18: debug_data_signal <= Branch2_exe;//mem_wen};
			19: debug_data_signal <= ALU_out;
			20: debug_data_signal <= Data_in;
			21: debug_data_signal <= Data_out;
			22: debug_data_signal <= {27'b0, Reg_addr_wb[4:0]};
			23: debug_data_signal <= Reg_data_wb;
			24: debug_data_signal <= {13'b0,ALU_Control[2:0],  mem_r_control,mem_w_control,ALUSrc_A, ALUSrc_B,    0,Jal,Branch,   RegWrite,RegDst,DatatoReg,0,0,Branch2};
			25: debug_data_signal <= {13'b0,ALU_Control_exe[2:0],  mem_r_exe,mem_w_exe,ALUSrc_A_exe, ALUSrc_B_exe,    0,Jal_exe,Branch_exe,   RegWrite_exe,RegDst_exe,DatatoReg_exe,finalBranch};
			26: debug_data_signal <= {4'b0,  mem_r_mem,mem_w_mem,2'b0,    0,Jal_mem,Branch_mem,   RegWrite_mem,RegDst_mem,DatatoReg_mem,0,0,Branch_mem};
			27: debug_data_signal <= Mem_data;
			28: debug_data_signal <= {20'b0,3'b0,zero,3'b0,data_stall,3'b0,branch_stall};
			29:	debug_data_signal <= finalBranch;
			30:debug_data_signal  <= branch_pc_mem[31:0];
			31: debug_data_signal <= PC_out;
			default: debug_data_signal <= 32'hFFFF_FFFF;
		endcase
	end
	
	assign
		debug_data = debug_addr[5] ? debug_data_signal : debug_data_reg;
	`endif
	

	initial begin
		
	end


	assign inst_r = inst_ren;
	/*
	assign
		addr_rs = inst_data[25:21],
		addr_rt = inst_data[20:16],
		addr_rd = inst_data[15:11],
		//data_rt = Data_out_DUMMY[31:0];
	*/
	//if	
	add_32  ALU_PC_4 (.a(inst_addr[31:0]), 
						  .b(32'b00000000_00000000_00000000_00000100), 
						  .c(pc_4_if_wire[31:0]));
	
	always @(posedge clk) begin
		if (if_rst) begin
			inst_ren <= 0;
			inst_addr <= 0;
		end
		
		//else if (branch_stall)begin
	//		inst_ren <= 0;
	//		inst_addr <= PC_out;
	//	end
		else if (if_en) begin
			inst_ren <= 1;
			//inst_addr <= is_branch_mem ? alu_out_mem[15:0]<<2 : inst_addr_next; //?
		    inst_addr <= PC_out;

		end

	end

	Decode_pc_Int  U3 ( .clk(clk),
						.rst(rst),
						.INT(1'b0), 
						.pc_next(pc_next[31:0]), 
						.RFE(1'b0), 
						.pc(PC_out[31:0]));

	mux4to1_32  ChoosePC (	.a(pc_4_if_wire[31:0]), 
						.b(branch_pc_mem[31:0]), 
						.c({pc_4_mem[31:28], inst_data_mem[25:0], 2'b00}), 
						.d(data_rs_mem[31:0]), 
						.sel(Branch_mem[1:0]), 
						.o(pc_next[31:0]));	

	//id 
	always @(posedge clk) begin
		if (id_rst) begin
				inst_addr_id <= 0;
				inst_data_id <= 0;
				pc_4_id<=0;
			//inst_addr_next_id <= 0;
		end
		else if (id_en) begin
			if(Branch_mem == 2'b00) begin
				inst_addr_id <= inst_addr;
				inst_data_id <= inst_data;
				pc_4_id <= pc_4_if_wire;
			end
			else begin
				inst_addr_id <= 0;
				inst_data_id <= 0;
				pc_4_id<= 0;
			end
			// //inst_addr_next_id <= inst_addr_next;
		end
	end
	assign
		addr_rs_id = inst_data_id[25:21],
		addr_rt_id = inst_data_id[20:16],
		addr_rd_id = inst_data_id[15:11],
		imm_16 = inst_data_id[15:0];
		//data_rt = Data_out_DUMMY[31:0];

	
	Ext_32  Ext32 (.imm_16(inst_data_id[15:0]), 
					  .Imm_32(Imm_32_id[31:0]));

	Regs  U2 (.clk(clk), 
				.L_S(RegWrite_wb),     //need to check again
				.rst(rst), 
				`ifdef DEBUG
				.debug_addr(debug_addr[5:0]),
				.debug_data(debug_data_reg),
				`endif
				.R_addr_A(addr_rs_id), 
				.R_addr_B(addr_rt_id), 
				.Wt_addr(Reg_addr_wb), 
				.Wt_data(Reg_data_wb), 
				.rdata_A(data_rs_id), 
				//.rdata_B(Data_out_DUMMY[31:0])
				.rdata_B(data_rt_id));

	
    //forward
    mux4to1_32  FOWRA (.a(data_rs_id),
						.b(ALU_out_DUMMY),
						.c(ALU_out_mem),
						.d(Data_in),
						.sel(ForwardA),
						.o(data_rs_final)
						);
    mux4to1_32  FOWRB (.a(data_rt_id),
						.b(ALU_out_DUMMY),
						.c(ALU_out_mem),
						.d(Data_in),
						.sel(ForwardB),
						.o(data_rt_final)
						);
  


    //exe stage
    always @(posedge clk) begin
		if (exe_rst) begin
				inst_addr_exe <= 0;
				inst_data_exe <= 0;
				pc_4_exe <= 0;
				Imm_32_exe <= 0;
				//signal latch
				ALU_Control_exe <= 0;
				ALUSrc_A_exe <= 0;
				ALUSrc_B_exe <= 0;
				Branch_exe<= 0;
				Jal_exe<=0;
				RegDst_exe<=0;
				RegWrite_exe<=0;
				DatatoReg_exe<=0;
				addr_rd_exe <= 0;
				data_rt_exe <= 0;
				data_rs_exe<=0;
				
				mem_r_exe <= 0;
				mem_w_exe <= 0;
			
		end
		else if (exe_en) begin
				inst_addr_exe <= inst_addr_id;
				inst_data_exe <= inst_data_id;
				pc_4_exe <= pc_4_id; //?
				Imm_32_exe <= Imm_32_id;
				ALU_Control_exe <= ALU_Control;
				ALUSrc_A_exe <= ALUSrc_A;
				ALUSrc_B_exe <= ALUSrc_B;
				Branch_exe <= Branch;
				Branch2_exe <= Branch2;
				Jal_exe <= Jal;
				RegDst_exe <= RegDst;
				RegWrite_exe <= RegWrite;
				DatatoReg_exe <= DatatoReg;
				addr_rd_exe <= addr_rd_id;
				addr_rt_exe <= addr_rt_id;
				data_rt_exe <= data_rt_final;
				data_rs_exe <= data_rs_final;
				
				mem_r_exe <= mem_r_control;
				mem_w_exe <= mem_w_control;
		end
		//	is_branch_exe <= is_branch_ctrl & (data_rs == data_rt);  // BEQ only
	
	end
	
	
	mux2to1_32  ALU_A_Choose (.b(data_rs_exe[31:0]),
							.a({26'b0,Imm_32_exe[10:6]}),  
						  .sel(ALUSrc_A_exe), 
						  .o(ALU_A[31:0]));


    mux2to1_32  ALU_B_Choose (.a(Imm_32_exe[31:0]), 
						  .b(data_rt_exe[31:0]), 
						  .sel(ALUSrc_B_exe), 
						  .o(ALU_B[31:0]));
    

    ALU  U1 (.A(ALU_A[31:0]), 
				.ALU_operation(ALU_Control_exe[2:0]), 
				.B(ALU_B[31:0]), 
				.overflow(overflow), 
				.res(ALU_out_DUMMY[31:0]), 
				.zero(zero));


	mux2to1_5  RegWriteChoose_1 (.a(5'b11111), 
						 //.b(inst_data[20:16]), 
						 .b(addr_rt_exe),
						 .sel(Jal_exe), 
						 .o(wt_addr_1[4:0]));
	
	mux2to1_5  RegWriteChoose_2 (//.a(inst_data[15:11]), 
						.a(addr_rd_exe),
						 .b(wt_addr_1[4:0]), 
						 .sel(RegDst_exe), 
						 .o(wt_addr_2[4:0]));
	
	

	add_32  ALU_Branch (.a(pc_4_exe[31:0]), 
							 .b({Imm_32_exe[29:0], 2'b00}), 
							 .c(branch_pc[31:0]));
	
	mux4to1_2 ChooseBranch(.a(Branch_exe),
							.b(2'b00),
							.c({Branch_exe[1],~zero}),
							.d({Branch_exe[1],zero}),
							.sel(Branch2_exe),
							.o(finalBranch));
	
	
	//mem stage
	always @(posedge clk) begin
		if (mem_rst) begin
			//mem_valid <= 0;
			inst_addr_mem <= 0;
			inst_data_mem <= 0;
			//regw_addr_mem <= 0;
			pc_4_mem <=0;
			//opa_mem <= 0;
			data_rt_mem <= 0;
			data_rs_mem <=0;
			ALU_out_mem <= 0;
			mem_r_mem <= 0;
			mem_w_mem <= 0;
			//wb_data_src_mem <= 0;
			Branch_mem<= 0;
			//Jal_mem<=0;
			//RegDst_mem<=0;
			RegWrite_mem<=0;
			DatatoReg_mem <= 0;
			Reg_addr_mem <= 0;
			//wb_wen_mem <= 0;
			//is_branch_mem <= 0;
			branch_pc_mem <= 0;
		end
		else if (mem_en) begin
			//mem_valid <= exe_valid;
			inst_addr_mem <= inst_addr_exe;
			inst_data_mem <= inst_data_exe; //?
			//regw_addr_mem <= regw_addr_exe; //?
			pc_4_mem <=pc_4_exe;
			//opa_mem <= opa_exe; //?
			data_rt_mem <= data_rt_exe; //?
			data_rs_mem <= data_rs_exe;
			ALU_out_mem <= ALU_out_DUMMY; //?
			mem_r_mem <= mem_r_exe; //?
			mem_w_mem <= mem_w_exe; //?
			Branch_mem <= finalBranch;
			

			//RegDst_mem <= RegDst_exe;
			RegWrite_mem <= RegWrite_exe;
			DatatoReg_mem <=DatatoReg_exe;
			Reg_addr_mem <= wt_addr_2;
			branch_pc_mem <= branch_pc;
		end
	end
	
	assign 
		ALU_out = ALU_out_mem,
		Data_out = data_rt_mem,
		mem_r = mem_r_mem,
		mem_w = mem_w_mem & mem_en;

	 //wb
	 always @(posedge clk) begin
		if(wb_rst) begin 
			RegWrite_wb <=0;
			
			Reg_addr_wb <=0;
			Mem_data <=0;
			ALU_out_wb <=0;
			pc_4_wb <= 0;
			inst_data_wb <=0;
			DatatoReg_wb <=0;

		end
		else if(wb_en) begin
			Reg_addr_wb <= Reg_addr_mem; 
			Mem_data <= Data_in;
			ALU_out_wb <=ALU_out_mem;
			pc_4_wb <= pc_4_mem;
			inst_data_wb <= inst_data_mem;
			DatatoReg_wb <= DatatoReg_mem;
		end	
		RegWrite_wb <= RegWrite_mem & wb_en;

	end

	mux4to1_32  RegWriteDataChoose (.a(ALU_out_wb[31:0]), 
						  .b(Mem_data[31:0]), 
						  .c({inst_data_wb[15:0], 16'b00000000_00000000}), 
						  .d(pc_4_wb[31:0]), 
						  .sel(DatatoReg_wb[1:0]), 
						  .o(Reg_data_wb[31:0]));

	

endmodule
