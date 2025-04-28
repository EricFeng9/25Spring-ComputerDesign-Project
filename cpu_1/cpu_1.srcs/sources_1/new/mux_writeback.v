`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 写回多路复用器模块
// 用于选择写入寄存器的数据
//////////////////////////////////////////////////////////////////////////////////

module mux_writeback (
    input wire [31:0] alu_result,  // ALU结果
    input wire [31:0] mem_data,    // 存储器数据
    input wire [31:0] pc_plus4,    // PC+4
    input wire [31:0] imm,         // 立即数
    input wire [1:0] reg_src,      // 寄存器源选择
    output reg [31:0] write_data   // 写回数据
);
    always @(*) begin
        case (reg_src)
            2'b00: write_data = alu_result;  // ALU结果
            2'b01: write_data = mem_data;    // 存储器数据
            2'b10: write_data = pc_plus4;    // PC+4 (用于JAL, JALR)
            2'b11: write_data = imm;         // 立即数 (用于LUI)
            default: write_data = alu_result; // 默认选择ALU结果
        endcase
    end
endmodule 