`timescale 1ns / 1ps

module srl32 (
	input [31:0] A,
	input [4:0] B,
	//output [31:0] temp,
	output  [31:0] res );
	reg [31:0] temp;
	always @ (A or B) begin
				temp = B[0] ? {1'b0, A[31:1]} : A;
             temp = B[1] ? {2'b0, temp[31:2]} : temp;
             temp = B[2] ? {4'b0, temp[31:4]} : temp;
             temp = B[3] ? {8'b0, temp[31:8]} : temp;
             temp = B[4] ? {16'b0, temp[31:16]} : temp;
	end
	//assign res = B[6] ? A >> 1 : A;
	assign res[31:0]=temp[31:0];
	
	
endmodule
