`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 结果多路复用器模块
// 用于选择CPU的输出结果
//////////////////////////////////////////////////////////////////////////////////

module mux_result(
    input wire [31:0] alu_result,      // ALU结果
    input wire [31:0] mem_data,        // 存储器数据
    input wire [31:0] pc_data,         // PC相关数据
    input wire [31:0] imm_data,        // 立即数数据
    input wire [1:0] result_src,       // 结果源选择
    output reg [31:0] result           // 最终结果输出
);
    // 根据选择信号选择输出结果
    always @(*) begin
        case (result_src)
            2'b00: result = alu_result;  // 选择ALU结果
            2'b01: result = mem_data;    // 选择存储器数据
            2'b10: result = pc_data;     // 选择PC相关数据
            2'b11: result = imm_data;    // 选择立即数
            default: result = alu_result;
        endcase
    end
endmodule 