`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 20:07:22
// Design Name: 
// Module Name: alu_mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_mux(
    input wire [31:0] data1,    // 输入数据1
    input wire [31:0] data0,    // 输入数据0
    input wire sel,             // 选择信号
    output wire [31:0] alu_input // 输出数据
);
    // 根据选择信号选择输出
    assign alu_input = sel ? data1 : data0;
endmodule
