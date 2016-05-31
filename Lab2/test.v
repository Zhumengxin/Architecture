`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:25:38 05/24/2016
// Design Name:   mips_top
// Module Name:   Y:/Documents/ARCH/Lab2/test.v
// Project Name:  Lab2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mips_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test;

	// Inputs
	reg CCLK;
	reg [3:0] SW;
	reg BTNN;
	reg BTNE;
	reg BTNS;
	reg BTNW;
	reg ROTA;
	reg ROTB;
	reg ROTCTR;

	// Outputs
	wire [7:0] LED;
	wire LCDE;
	wire LCDRS;
	wire LCDRW;
	wire [3:0] LCDDAT;

	// Instantiate the Unit Under Test (UUT)
	mips_top uut (
		.CCLK(CCLK), 
		.SW(SW), 
		.BTNN(BTNN), 
		.BTNE(BTNE), 
		.BTNS(BTNS), 
		.BTNW(BTNW), 
		.ROTA(ROTA), 
		.ROTB(ROTB), 
		.ROTCTR(ROTCTR), 
		.LED(LED), 
		.LCDE(LCDE), 
		.LCDRS(LCDRS), 
		.LCDRW(LCDRW), 
		.LCDDAT(LCDDAT)
	);

	initial begin
		// Initialize Inputs
		CCLK = 0;
		SW = 0;
		BTNN = 0;
		BTNE = 0;
		BTNS = 0;
		BTNW = 0;
		ROTA = 0;
		ROTB = 0;
		ROTCTR = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		forever begin
			CCLK = ~CCLK;
			#10;
			
		end
	end
      
endmodule

