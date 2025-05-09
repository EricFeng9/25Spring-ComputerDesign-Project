// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Thu May  8 02:49:28 2025
// Host        : Lekge2025 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/Sustech/25Spring_ComputerDesign/Project/25Spring-ComputerDesign-Project/cpu_1/cpu_1.srcs/sources_1/ip/register_block/register_block_stub.v
// Design      : register_block
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2017.4" *)
module register_block(clka, wea, addra, dina, douta, clkb, web, addrb, dinb, 
  doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[4:0],dina[31:0],douta[31:0],clkb,web[0:0],addrb[4:0],dinb[31:0],doutb[31:0]" */;
  input clka;
  input [0:0]wea;
  input [4:0]addra;
  input [31:0]dina;
  output [31:0]douta;
  input clkb;
  input [0:0]web;
  input [4:0]addrb;
  input [31:0]dinb;
  output [31:0]doutb;
endmodule
