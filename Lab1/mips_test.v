`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   02:56:26 03/26/2016
// Design Name:   mips
// Module Name:   Y:/Documents/ARCH/Lab1/mips_test.v
// Project Name:  Lab1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mips
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mips_test;

	// Inputs
	reg debug_en;
	reg debug_step;
	reg debug_addr;
	reg clk;
	reg rst;
	reg interrupter;

	// Outputs
	wire debug_data;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.debug_en(debug_en), 
		.debug_step(debug_step), 
		.debug_addr(debug_addr), 
		.debug_data(debug_data), 
		.clk(clk), 
		.rst(rst), 
		.interrupter(interrupter)
	);

	initial begin
		// Initialize Inputs
		debug_en = 0;
		debug_step = 0;
		debug_addr = 0;
		clk = 0;
		rst = 0;
		interrupter = 0;
		#100 rst = 1;
		#100 rst = 0;
		debug_en=1;
		// Wait 100 ns for global reset to finish
		#100;
      debug_step=1;
		debug_step=0;
		
		// Add stimulus here

	end
      initial forever #10 clk = ~clk;
endmodule

