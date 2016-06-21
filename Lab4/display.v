`include "define.vh"


/**
 * Display using character LCD.
 * Author: Zhu Mengxin   mxinzhu@foxmail.com
 */
module display (
	input wire clk,
	input wire rst,
	input wire [7:0] addr,
	input wire [127:0] data,
	// character LCD interfaces
	output wire lcd_e,
	output wire lcd_rs,
	output wire lcd_rw,
	output wire [3:0] lcd_dat
	);
	
	reg [255:0] strdata ;//= "* Hello World! ** Hello World! *";
	reg [63:0] data_value;
	reg [63:0] reg_value;
	function [7:0] num2str;
		input [3:0] number;
		begin
			if (number < 10)
				num2str = "0" + number;
			else
				num2str = "A" - 10 + number;
		end
	endfunction
	
	genvar i;
	generate for (i=0; i<8; i=i+1) begin: NUM2STR
		always @(posedge clk) begin
			//strdata[8*i+199-:8] <= num2str(data[4*i+99-:4]);
			reg_value[8*i+7-:8] <= num2str(data[4*i+59-:4]);
			data_value[8*i+7-:8] <= num2str(data[4*i+3-:4]);
		end
	end
	endgenerate
	
	always @(posedge clk) begin
		//strdata[71:64] <= " ";
		case (addr[7:5])
			3'b000: begin
				strdata[127:72] <= {"REGS-", num2str(addr[5:4]), num2str(addr[3:0])};
				strdata[71:0] <= data_value;
				end
			3'b001:begin
				strdata[255:136] <= {"F",num2str(data[127:124]),num2str(data[123:120]),"D",num2str(data[119:116]),num2str(data[115:112]),"E",num2str(data[111:108]),num2str(data[107:104]),"M",num2str(data[103:100]),num2str(data[99:96]),"W",num2str(data[95:92]),num2str(data[91:88])};
				
				case (addr[4:0])
				// datapath debug signals, MUST be compatible with 'debug_data_signal' in 'datapath.v'
				0: strdata[127:72] <= "IF-ADDR";
				1: strdata[127:72] <= "IF-INST";
				2: strdata[127:72] <= "ID-ADDR";
				3: strdata[127:72] <= "ID-INST";
				4: strdata[127:72] <= "EX-ADDR";
				5: strdata[127:72] <= "EX-INST";
				6: strdata[127:72] <= "MM-ADDR";
				7: strdata[127:72] <= "MM-INST";
				8: strdata[127:72] <= "RS-ADDR";
				9: strdata[127:72] <= "RS-DATA";
				10: strdata[127:72] <= "RT-ADDR";
				11: strdata[127:72] <= "RT-DATA";
				12: strdata[127:72] <= "IMMEDAT";
				13: strdata[127:72] <= "ALU-AIN";
				14: strdata[127:72] <= "ALU-BIN";
				15: strdata[127:72] <= "ALU-OUT";
				16: strdata[127:72] <= "-------";
				17: strdata[127:72] <= "FORWARD";
				18: strdata[127:72] <= "MEMOPER";
				19: strdata[127:72] <= "MEMADDR";
				20: strdata[127:72] <= "MEMDATR";
				21: strdata[127:72] <= "MEMDATW";
				22: strdata[127:72] <= "WB-ADDR";
				23: strdata[127:72] <= "WB-DATA";
				24: strdata[127:72] <= "ID-SIGN";
				25: strdata[127:72] <= "EXESIGN";
				26: strdata[127:72] <= "MEMSIGN";
				27: strdata[127:72] <= "WB-MEM-";
				28: strdata[127:72] <= "-STALL-";
				29: strdata[127:72] <= "SIGN-BR";
				30: strdata[127:72] <= "ADDR-BR";
				31: strdata[127:72] <= "PC--OUT";
				default: strdata[127:72] <= "RESERVE";
			endcase
				strdata[71:0] <= data_value;
			end
			3'b010: strdata[127:72] <= {"CP0S-", num2str(addr[5:4]), num2str(addr[3:0])};
			3'b011: 
			begin
				strdata[255:136] <= {"F",num2str(data[127:124]),num2str(data[123:120]),"D",num2str(data[119:116]),num2str(data[115:112]),"E",num2str(data[111:108]),num2str(data[107:104]),"M",num2str(data[103:100]),num2str(data[99:96]),"W",num2str(data[95:92]),num2str(data[91:88])};
				strdata[127:72] <= {"REGS-", num2str(addr[5:4]-2), num2str(addr[3:0])};
				strdata[71:0] <= reg_value;
			end
			default:strdata[127:0] <=0;
		endcase
		
	end
	
	reg refresh = 0;
	reg [7:0] addr_buf;
	reg [127:0] data_buf;
	
	always @(posedge clk) begin
		addr_buf <= addr;
		data_buf <= data;
		refresh <= (addr_buf != addr) || (data_buf != data);
	end
	
	displcd DISPLCD (
		.CCLK(clk),
		.reset(rst | refresh),
		.strdata(strdata),
		.rslcd(lcd_rs),
		.rwlcd(lcd_rw),
		.elcd(lcd_e),
		.lcdd(lcd_dat)
		);
	
endmodule
