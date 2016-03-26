`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:10:34 02/25/2014 
// Design Name: 
// Module Name:    Decode_Int 
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
module Decode_pc_Int(input wire clk,
						   input wire res,
							input wire cpu_en,
							input wire rst,
							input wire INT,
							input wire RFE,
							input wire[31:0] pc_next,
							output reg [31:0] pc
						);
	always @(posedge clk) begin
		if (rst) begin
			pc <= 0;
		end
		else if (cpu_en) begin	
			pc<= pc_next;
		end
	end
						
endmodule
