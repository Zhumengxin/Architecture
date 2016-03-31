////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2010 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 12.4
//  \   \         Application : sch2hdl
//  /   /         Filename : ALU.vf
// /___/   /\     Timestamp : 04/10/2015 12:33:02
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\12.4\ISE_DS\ISE\bin\nt\unwrapped\sch2hdl.exe -sympath F:/lab3_4_10/ipcore_dir -intstyle ise -family spartan3 -verilog ALU.vf -w F:/lab3_4_10/ALU.sch
//Design Name: ALU
//Device: spartan3
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale 1ns / 1ps

module ALU(A, 
           ALU_operation, 
           B, 
           overflow, 
           res, 
           zero);

    input wire [31:0] A;
    input [2:0] ALU_operation;
    input wire [31:0] B;
   output overflow;
   output  [31:0] res;
   output zero;
   
   wire N0;
   wire [32:0] S;
   wire [31:0] XLXN_1;
   wire [31:0] XLXN_7;
   wire [31:0] XLXN_8;
   wire [31:0] XLXN_9;
   wire [31:0] XLXN_36;
   wire [31:0] XLXN_48;
   wire [31:0] XLXN_88;
   wire [31:0] res_DUMMY;
   
   assign res[31:0] = res_DUMMY[31:0];
   and32  XLXI_6 (.A(A[31:0]), 
                 .B(B[31:0]), 
                 .res(XLXN_1[31:0]));
   or32  XLXI_7 (.A(A[31:0]), 
                .B(B[31:0]), 
                .res(XLXN_88[31:0]));
   ADC32  XLXI_8 (.A(A[31:0]), 
                 .B(XLXN_36[31:0]), 
                 .C0(ALU_operation[2]), 
                 .S(S[32:0]));
   xor32  XLXI_10 (.A(A[31:0]), 
                  .B(B[31:0]), 
                  .res(XLXN_7[31:0]));
   nor32  XLXI_11 (.A(A[31:0]), 
                  .B(B[31:0]), 
                  .res(XLXN_8[31:0]));
   srl32  XLXI_12 (.A(B[31:0]), 
                  .B(A[4:0]), 
                  .res(XLXN_9[31:0]));
   xor32  XLXI_13 (.A(XLXN_48[31:0]), 
                  .B(B[31:0]), 
                  .res(XLXN_36[31:0]));
   mux8to1_32  XLXI_14 (.sel(ALU_operation[2:0]), 
                       .x0(XLXN_1[31:0]), 
                       .x1(XLXN_88[31:0]), 
                       .x2(S[31:0]), 
                       .x3(XLXN_7[31:0]), 
                       .x4(XLXN_8[31:0]), 
                       .x5(XLXN_9[31:0]), 
                       .x6(S[31:0]), 
                       .x7({N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, 
         N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, N0, 
         N0, S[32]}), 
                       .o(res_DUMMY[31:0]));
   or_bit_32  XLXI_15 (.A(res_DUMMY[31:0]), 
                      .o(zero));
   GND  XLXI_22 (.G(N0));
   SignalExt_32  XLXI_23 (.S(ALU_operation[2]), 
                         .So(XLXN_48[31:0]));
endmodule
