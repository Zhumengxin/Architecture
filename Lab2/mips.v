`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:59:16 03/21/2016 
// Design Name: 
// Module Name:    mips 
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
module mips( 
      `ifdef DEBUG
		input wire debug_en,
		input wire debug_step,
		input wire [6:0] debug_addr,
		output wire [31:0] debug_data,
	   `endif
		input wire clk,
		input wire rst,
		input wire interrupter
    );
	 
	 wire inst_read_en,mem_data_write_en,mem_data_read_en;
	 
	 wire [31:0] inst_addr;
	 wire [31:0] inst_data;
	 wire [31:0] mem_data_addr;
	 wire [31:0] mem_data_write;
	 wire [31:0] mem_data_read;
	 
	 
	 
	 Inst_ROM Inst_ROM (
		.clka(clk),
		.addra({2'b0, inst_addr[31:2]}),
		.douta(inst_data)
		);
		
	 Data_RAM Data_RAM (
		.clka(clk),
		.wea(mem_data_write_en),
		.addra({2'b0, mem_data_addr[31:2]}),
		//.addr(mem_addr),
		.dina(mem_data_write),
		.douta(mem_data_read)
		);
	 SCPU SCPU(.clk(clk),
		.rst(rst),
		`ifdef DEBUG
		.debug_en(debug_en),
		.debug_step(debug_step),
		.debug_addr(debug_addr),
		.debug_data(debug_data),
		`endif
		.inst_ren(inst_read_en),
		.inst_addr(inst_addr),
		.inst_data(inst_data),
		.mem_ren(mem_data_read_en),
		.mem_wen(mem_data_write_en),
		.mem_addr(mem_data_addr),
		.mem_dout(mem_data_write),
		.mem_din(mem_data_read));
	
	 

endmodule
