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
	
	input [31:0] inst,
	input [31:0] if_inst,
	input [31:0] exe_inst,
	input [31:0] mem_inst,
	input [31:0] wb_inst,
	input [1:0] Branch_mem,
	//input zero,
	output reg ALUSrc_B,
	output reg ALUSrc_A,
	output reg Jal,
	output reg RegDst,
	output reg RegWrite,
	output reg[1:0] DatatoReg,
	output reg Memread,
	output reg Memwrite,
	output reg[1:0] Branch,
	output reg[1:0] Branch2,
	output reg[2:0] ALU_Control,
	output reg rs_lock,
	output reg rt_lock,
	
	output reg if_rst,  // stage reset signal
	output reg if_en,  // stage enable signal
	
	output reg id_rst,
	output reg id_en,

	output reg exe_rst,
	output reg exe_en,

	output reg mem_rst,
	output reg mem_en,

	output reg wb_rst,
	output reg wb_en,

	output wire stall,
	output wire branch_stall,
	output wire [1:0] ForwardA,
	output wire [1:0] ForwardB,
	output wire ForwardM
	
    );
	
	`define CPU_ctrl_signals {RegDst, ALUSrc_B, DatatoReg, RegWrite, Memread, Memwrite, Branch, Jal, ALU_Control,ALUSrc_A,Branch2}
	wire i_type_exe,i_type_mem;
	wire [4:0] exe_rs;
	wire [4:0] exe_rt;
	wire [4:0] exe_rd;
	wire [4:0] mem_rt;
	wire [4:0] mem_rd;
	wire [4:0] wb_rd;
	wire [4:0] wb_rt;
	wire [5:0] OPcode;
	wire [5:0] if_OPcode;
	wire [5:0] exe_OPcode;
	wire [5:0] mem_OPcode;
	wire [5:0] wb_OPcode;

	wire [5:0] Fun;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [4:0] if_rs;
	wire [4:0] if_rt;
	wire [4:0] if_rd;



	//assign mem_w = MemWrite && (~MemRead);
	assign OPcode = inst[31:26];
	assign Fun = inst[5:0];
	assign rs[4:0] = inst[25:21];
	assign rt[4:0] = inst[20:16];
	assign rd[4:0] = inst[15:11];


	assign if_OPcode[5:0] =if_inst[31:26];
	assign if_rs[4:0] = if_inst[25:21];
	assign if_rt[4:0] = if_inst[20:16];
	assign if_rd[4:0] = if_inst[15:11];
	//assign if_func[5:0] = if_inst[5:0];
	assign i_type_if = (if_OPcode > 6'h07 && if_OPcode <6'h10)?1:0;	

	assign exe_OPcode[5:0] = exe_inst[31:26];
	assign exe_rs[4:0] = exe_inst[25:21];
	assign exe_rt[4:0] = exe_inst[20:16];
	assign exe_rd[4:0] = exe_inst[15:11];
	assign i_type_exe = (exe_OPcode > 6'h07 && exe_OPcode <6'h10)?1:0;

	assign mem_OPcode[5:0] = mem_inst[31:26];
	assign mem_rt[4:0] = mem_inst[20:16];
	assign mem_rd[4:0] = mem_inst[15:11];
	assign i_type_mem = (mem_OPcode > 6'h07 && mem_OPcode <6'h10)?1:0;

	assign wb_rd[4:0] = wb_inst[15:11];
	assign wb_rt[4:0] = wb_inst[20:16];
	assign wb_OPcode[5:0] = wb_inst[31:26];

	assign id_branch = ((OPcode > 6'h00) &  (OPcode < 6'h08)) || ((OPcode == 6'h0) & (Fun == 6'h08)) || ((OPcode == 6'h0) & (Fun == 6'h09));
	assign exe_branch = ((exe_OPcode > 6'h00) &  (exe_OPcode < 6'h08)) || ((exe_OPcode == 6'h0) & (exe_inst[5:0] == 6'h08)) || ((exe_OPcode == 6'h0) & (exe_inst[5:0] == 6'h09));
	//assign exe_branch = (exe_OPcode == 6'b000100) || (exe_OPcode == 6'b000010) || (exe_OPcode == 6'h03) || (exe_OPcode == 6'h05) || (exe_OPcode == 6'h8) || (exe_OPcode == 6'h9);
	// assign mem_branch = (mem_OPcode == 6'b000100) || (mem_OPcode == 6'b000010) || (mem_OPcode == 6'h03) || (mem_OPcode == 6'h05) || (mem_OPcode == 6'h8) || (mem_OPcode == 6'h9);
	//assign branch_stall = id_branch ||exe_branch ;//|| mem_branch;

	always @ (OPcode or Fun) begin
		case(OPcode)
			6'b100011: begin `CPU_ctrl_signals <= 16'b0_1_01_1_1_0_00_0_010_0_00; end // load
			6'b101011: begin `CPU_ctrl_signals <= 16'bx_1_xx_0_0_1_00_0_010_0_00; end // store
			6'b000100: begin `CPU_ctrl_signals <= 16'bx_0_xx_0_0_0_00_0_110_0_10; end // beq   //not sure for lock
			6'b000010: begin `CPU_ctrl_signals <= 16'bx_x_xx_0_0_0_10_0_xxx_0_00; end // jump    //not sure
			6'h0A: begin `CPU_ctrl_signals <= 16'b0_1_00_1_0_0_00_0_111_0_00; end // slti
			6'h08: begin `CPU_ctrl_signals <= 16'b0_1_00_1_0_0_00_0_010_0_00; end // addi
			6'h0C: begin `CPU_ctrl_signals <= 16'b0_1_00_1_0_0_00_0_000_0_00; end // andi
			6'h0D: begin `CPU_ctrl_signals <= 16'b0_1_00_1_0_0_00_0_001_0_00; end // ori
			6'h0E: begin `CPU_ctrl_signals <= 16'b0_1_00_1_0_0_00_0_011_0_00; end // xori
			6'h0F: begin `CPU_ctrl_signals <= 16'b0_x_10_1_0_0_00_0_xxx_0_00; end // lui
			6'h03: begin `CPU_ctrl_signals <= 16'b0_x_11_1_0_0_10_1_xxx_0_00; end // Jal
			6'h05: begin `CPU_ctrl_signals <= 16'bx_0_xx_0_0_0_0_0_0_110_0_11; end // bne
			6'b000000: begin case(Fun)
				6'b100000: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_010_0_00; end // add
				6'b100010: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_110_0_00; end // sub
				6'b100100: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_000_0_00; end // and
				6'b100101: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_001_0_00; end // or
				6'b101010: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_111_0_00; end // slt
				6'b100111: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_100_0_00; end // nor
				6'b000010: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_101_1_00; end // srl
				6'b010110: begin `CPU_ctrl_signals <= 16'b1_0_00_1_0_0_00_0_011_0_00; end // xor
				6'h08: begin `CPU_ctrl_signals <= 16'bx_x_xx_0_0_0_11_0_xxx_0_00; end // jr
				6'h9: begin `CPU_ctrl_signals <= 16'b0_1_11_1_0_0_11_1_xxx_0_00; end // Jalr
				default: begin `CPU_ctrl_signals <= 16'b0; end
			endcase end
			default: begin `CPU_ctrl_signals <= 16'b0; end
		endcase
	end
	

	//stall detect
	assign AfromEx = ((rs==exe_rd) & (rs != 0) & (exe_OPcode == 6'b000000)) || ((rs==exe_rt) & (rs != 0) & (i_type_exe==1));
	assign BfromEx = ((rt==exe_rd) & (rt != 0) & (exe_OPcode == 6'b000000)) || ((rt==exe_rt) & (rt != 0) & (i_type_exe==1));
	assign AfromMem = ((rs==mem_rd) & (rs!= 0) & (mem_OPcode == 6'b000000)) ||  ((rs==mem_rt) & (rs != 0) & (i_type_mem==1));
	assign BfromMem = ((rt==mem_rd) & (rt!= 0) & (mem_OPcode == 6'b000000)) ||  ((rt==mem_rt) & (rt != 0) & (i_type_mem==1));
	
	assign AfromDM = ((rs==mem_rt) & (rs!=0) & (mem_OPcode == 6'b100011));
	assign BfromDM = ((rt==mem_rt) & (rt!=0) & (mem_OPcode == 6'b100011));
	
	assign AfromExLW = (if_rs==rt) & (if_rs!=0) & (OPcode == 6'b100011);
	assign BfromExLW = (if_rt==rt) & (if_rt!=0) & (OPcode == 6'b100011) & (if_OPcode != 6'b101011 & if_OPcode != 6'b100011) & (i_type_if!=1);
	
	assign MfromLW = (exe_OPcode == 6'b100011) &(rt == exe_rt) & (rt!=0) & (OPcode == 6'b101011);

	assign ForwardA[1:0] = (AfromEx == 1) ? 2'b01:((AfromMem == 1) ? 2'b10:((AfromDM == 1) ? 2'b11:2'b00));
	assign ForwardB[1:0] = (BfromEx == 1) ? 2'b01:((BfromMem == 1) ? 2'b10:((BfromDM == 1) ? 2'b11:2'b00));
	assign ForwardM = (MfromLW == 1)?1:0;
	//assign ForwardC[1:0] = 1; 

	//assign stall = AfromEx || BfromEx || AfromMem || BfromMem || AfromExLW || BfromExLW || AfromMemLW || BfromMemLW;
	assign stall = AfromExLW || BfromExLW;
	// forward judge





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
		else if(Branch_mem != 2'b00) begin
			// if_en=0;
	  //  		if_rst=1;
	   		id_rst=1;
	   		exe_rst=1;
	   		mem_rst=1;
		end
		else if (stall) begin
		     if_en=0;
			 id_rst=1;
			 
	   	end
	    //else if(exe_branch) begin
	     		//if_rst=1;
	    // 		if_en=1;
	     		//id_en=1;

	     //end
	   	
	    // else if(Branch_mem != 2'b00) begin
	    // 		//if_rst = 1;
	    // 		//if_en = 1;
	    // end


	end


endmodule
