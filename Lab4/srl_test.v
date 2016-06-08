`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:18:15 04/01/2016
// Design Name:   srl32
// Module Name:   Y:/Documents/ARCH/Lab1/srl_test.v
// Project Name:  Lab1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: srl32
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module srl_test;

	// Inputs
	reg [31:0] A;
	reg [4:0] B;

	// Outputs
	wire [31:0] res;

	// Instantiate the Unit Under Test (UUT)
	srl32 uut (
		.A(A), 
		.B(B), 
		.res(res)
	);

	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		// Wait 100 ns for global reset to finish
		#100;
      A=32'h9000;
		B=4'b1000;
		// Add stimulus here

	end
      
endmodule

