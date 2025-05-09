// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Sun May 11 01:45:46 2025
// Host        : Lekge2025 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/Sustech/25Spring_ComputerDesign/Project/25Spring-ComputerDesign-Project/cpu_1/cpu_1.srcs/sources_1/ip/data_ram_dist/data_ram_dist_stub.v
// Design      : data_ram_dist
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_12,Vivado 2017.4" *)
module data_ram_dist(a, d, clk, we, spo)
/* synthesis syn_black_box black_box_pad_pin="a[13:0],d[31:0],clk,we,spo[31:0]" */;
  input [13:0]a;
  input [31:0]d;
  input clk;
  input we;
  output [31:0]spo;
endmodule
