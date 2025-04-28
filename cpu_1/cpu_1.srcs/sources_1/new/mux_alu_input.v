`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ALU输入多路复用器模块
// 用于选择ALU的第二个输入是寄存器数据还是立即数
//////////////////////////////////////////////////////////////////////////////////

module mux_alu_input(
    input wire [31:0] reg_data,    // 寄存器数据输入
    input wire [31:0] imm_data,    // 立即数输入
    input wire sel,                // 选择信号
    output wire [31:0] alu_input   // ALU输入输出
);
    // 根据选择信号选择输出
    assign alu_input = sel ? imm_data : reg_data;
endmodule 