`include "define.vh"


/**
 * Top module for MIPS 5-stage pipeline CPU.
 * Author: Zhu Mengxin   mxinzhu@foxmail.com
 */
module mips_top (
	input wire CCLK,
	input wire [3:0] SW,
	input wire BTNN, BTNE, BTNS, BTNW,
	input wire ROTA, ROTB, ROTCTR,
	output wire [7:0] LED,
	output wire LCDE, LCDRS, LCDRW,
	output wire [3:0] LCDDAT
	);
	
	// clock generator
	wire clk_cpu, clk_disp;
	wire locked;
	
	clk_gen CLK_GEN (
		.clk_pad(CCLK),
		.clk_100m(),
		.clk_50m(clk_disp),
		.clk_25m(),
		.clk_10m(clk_cpu),
		.locked(locked)
		);
	
	// anti-jitter
	wire [3:0] switch;
	wire btn_reset, btn_step;
	wire btn_int2;
	wire disp_prev, disp_next;
	wire btn_int;
	
	`ifndef SIMULATING
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_SW0 (.clk(clk_disp), .rst(1'b0), .sig_i(SW[0]), .sig_o(switch[0]));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_SW1 (.clk(clk_disp), .rst(1'b0), .sig_i(SW[1]), .sig_o(switch[1]));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_SW2 (.clk(clk_disp), .rst(1'b0), .sig_i(SW[2]), .sig_o(switch[2]));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_SW3 (.clk(clk_disp), .rst(1'b0), .sig_i(SW[3]), .sig_o(switch[3]));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(2000), .INIT_VALUE(0))
		AJ_ROTA (.clk(clk_disp), .rst(1'b0), .sig_i(ROTA), .sig_o(disp_prev));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(2000), .INIT_VALUE(0))
		AJ_ROTB (.clk(clk_disp), .rst(1'b0), .sig_i(ROTB), .sig_o(disp_next));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_ROTCTR (.clk(clk_disp), .rst(1'b0), .sig_i(ROTCTR), .sig_o());
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_BTNE (.clk(clk_disp), .rst(1'b0), .sig_i(BTNE), .sig_o(btn_int2));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_BTNS (.clk(clk_disp), .rst(1'b0), .sig_i(BTNS), .sig_o(btn_step));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_BTNW (.clk(clk_disp), .rst(1'b0), .sig_i(BTNW), .sig_o(btn_int));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(20000), .INIT_VALUE(1))
		AJ_BTNN (.clk(clk_disp), .rst(1'b0), .sig_i(BTNN), .sig_o(btn_reset));
	`else
	assign
		switch = SW,
		disp_prev = ROTA,
		disp_next = ROTB,
		btn_int2 = BTNE,
		btn_step = BTNS,
		btn_reset = BTNN,
		btn_int = BTNW;
	`endif
	
	// reset
	reg rst_all;
	reg [15:0] rst_count = 16'hFFFF;
	
	always @(posedge clk_cpu) begin
		rst_all <= (rst_count != 0);
		rst_count <= {rst_count[14:0], (btn_reset | (~locked))};
	end
	//int
	reg btn_int_prev,real_int;
	reg int_cause;
	always @(posedge clk_cpu) begin
		btn_int_prev <= (btn_int || btn_int2);
	end
	always @(posedge clk_cpu) begin
		real_int <= 0;
		int_cause <=0;
		//if (~btn_int_prev && (btn_int || btn_int2)) begin
		if ((btn_int || btn_int2)) begin
			real_int <= 1;
			int_cause <= (btn_int)?0:1;
		end
	end
	
	// display
	reg [4:0] disp_addr0, disp_addr1, disp_addr2, disp_addr3;
	wire [127:0] disp_data;
	
	reg disp_prev_buf, disp_next_buf;
	always @(posedge clk_cpu) begin
		disp_prev_buf <= disp_prev;
		disp_next_buf <= disp_next;
	end
	
	always @(posedge clk_cpu) begin
		if (rst_all) begin
			disp_addr0 <= 0;
			disp_addr1 <= 0;
			disp_addr2 <= 0;
			disp_addr3 <= 0;
		end
		else if (~disp_prev_buf && disp_prev && ~disp_next) case (switch[1:0])
			0: disp_addr0 <= disp_addr0 - 1'h1;
			1: disp_addr1 <= disp_addr1 - 1'h1;
			2: disp_addr2 <= disp_addr2 - 1'h1;
			3: disp_addr3 <= disp_addr3 - 1'h1;
		endcase
		else if (~disp_next_buf && disp_next && ~disp_prev) case (switch[1:0])
			0: disp_addr0 <= disp_addr0 + 1'h1;
			1: disp_addr1 <= disp_addr1 + 1'h1;
			2: disp_addr2 <= disp_addr2 + 1'h1;
			3: disp_addr3 <= disp_addr3 + 1'h1;
		endcase
	end
	
	reg [4:0] disp_addr;
	always @(*) begin
		case (switch[1:0])
			0: disp_addr = disp_addr0;
			1: disp_addr = disp_addr1;
			2: disp_addr = disp_addr2;
			3: disp_addr = disp_addr3;
		endcase
	end
	
	display DISPLAY (
		.clk(clk_disp),
		.rst(rst_all),
		.addr({1'b0, switch[1:0], disp_addr[4:0]}),
		.data(disp_data),
		.lcd_e(LCDE),
		.lcd_rs(LCDRS),
		.lcd_rw(LCDRW),
		.lcd_dat(LCDDAT)
		);
	assign LED = {4'b0, switch};
	
	mips MIPS (
		`ifdef DEBUG
		.debug_en(switch[3]),
		.debug_step(btn_step),
		.debug_addr({switch[1:0], disp_addr[4:0]}),
		.debug_data(disp_data),
		`endif
		.clk(clk_cpu),
		.rst(rst_all),
		.int_cause(int_cause),
		.interrupter(real_int)

		);
	
endmodule
