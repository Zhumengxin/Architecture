`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:48:29 05/29/2016
// Design Name:   mips_top
// Module Name:   Y:/Documents/ARCH/Lab3/mips_test.v
// Project Name:  Lab3
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

module mips_test;

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
	reg[31:0] count,count1;
	reg ir_in;
	reg [31:0] a,b;
	wire equal;
	
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
   //parameter count=0;
	initial begin
		// Initialize Inputs
		CCLK = 0;
		SW = 1011;
		BTNN = 0;
		BTNE = 0;
		BTNS = 0;
		BTNW = 0;
		ROTA = 0;
		ROTB = 0;
		ROTCTR = 0;
		count=0;
		count1=0;
		ir_in=0;
		a = 0;
		b = 0;
		// Wait 100 ns for global reset to finish
		#100;
      //count=1;
		
		// Add stimulus here
		

	end
	
	//assign equal = (a==b)?1:0;
	always begin
			CCLK = ~CCLK;
			count = count + 1;
			//count1 = count;
			BTNS =0;
			//BTNW=0;
			if(count == 32'h40) begin
				BTNS=1;
				count = 0;
				count1 = count1 + 1;
				if(count1 == 32'hB)begin
					BTNW=1;
					
				end
				if(count1 == 32'hC)begin
					BTNW=0;
				end
				if(count1 == 32'h21)begin
					//BTNW=1;
					count1=0;
				end
				
				//count1 =0;
			end
			#10;
		end
      
endmodule

