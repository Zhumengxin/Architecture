`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:42:04 05/25/2016 
// Design Name: 
// Module Name:    CP0
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
module cp0(
	input wire clk, // main clock
	// debug
	`ifdef DEBUG
	input wire [4:0] debug_addr, // debug address
	output reg [31:0] debug_data, // debug data
	`endif
	// operations (read in ID stage and write in EXE stage)
	input wire [1:0] oper, // CP0 operation type
	input wire [4:0] addr_r, // read address
	output reg [31:0] data_r, // read data
	input wire [4:0] addr_w, // write address
	input wire [31:0] data_w, // write data
	// control signal
	input wire rst, // synchronous reset
	output reg ir_en, // interrupt enable
	input wire ir_in, // external interrupt input
	input wire int_cause,
	output wire return_en,
	output reg [31:0] EPCR,
	input wire [2:0]int_stall,
	input wire [31:0] ret_addr, // target instruction address to store when interrupt occurred
	output wire jump_en, // force jump enable signal when interrupt authorised or ERET occurred
	output reg [31:0] jump_addr // target instruction address to jump to
	);
	//`include "mips_define.vh"
	// interrupt determination
	wire ir;
	reg ir_wait = 0, ir_valid = 1;
	reg ret_flag;
	reg eret = 0;
	reg cause = 0;
	reg [31:0] EHBR;
	//reg [31:0] EPCR;
	reg [31:0] CAUSE;
	initial begin
		EHBR = 0;
		EPCR = 0;
		CAUSE = 0;
		jump_addr = 0;
		ir_en <= 1;
	end

	always @(posedge clk) begin
		if (jump_en && (int_stall == 0 || int_stall == 3) && ir_en == 1 )
			ir_en =0;//ir_en + 1;
		else if(int_stall == 3)
			ir_en = 1;
		else;
	end


	always @(posedge clk) begin
		cause <= int_cause;
		if (rst)
			ir_wait <= 0;
		else if (ir_in)
			ir_wait <= 1;
		else if (eret)
			ir_wait <= 0;
	end
	always @(posedge clk) begin
		if (rst)
			ir_valid <= 1;
		else if (eret)
			ir_valid <= 1;
		else if (ir)
			ir_valid <= 0; // prevent exception reenter
	end
	//assign ir = ir_en & ir_wait & ir_valid;
	assign ir = ir_en & ir_wait;
	assign jump_en = ir;//||eret ;//|| ret_flag; 
	assign return_en  = eret;
	/*always @(posedge clk) begin
		jump_en <= 0;
		if (ir||eret)
			jump_en <= 1;	
	end*/
	
	
	always @(*) begin
		eret <= 0;
		//jump_addr <= 0;
		if(ir)begin
			jump_addr <= EHBR;
		end
		else begin
			case(oper)
				2'b01: begin	//MFC0
					case(addr_r)
						5'h2: data_r <= EPCR;
						5'h3: data_r <= EHBR;
						default: data_r <= 0;
					endcase
				end				
				/*EXE_CP_STORE: begin	//MTC0
					case(addr_w)
						CP0_EPCR: EPCR <= data_w;
						CP0_EHBR: EHBR <= data_w;
						default: ;
					endcase
				end*/
				2'b11: begin	//ERET
					eret <= 1;
					jump_addr <= EPCR;
				end
				default:;
			endcase
		end
	end
	
	always @(posedge clk) begin
		
		if(ir && (int_stall == 0 || int_stall == 3))begin
			EPCR <= ret_addr;
			CAUSE <= cause;
			//add one register: CAUSE

		end
		else begin
			case(oper)
				2'b10: begin	//MTC0
					case(addr_w)
						2: EPCR <= data_w;
						3: EHBR <= data_w;
						default: ;
					endcase
				end
			endcase
		end
	end


endmodule
