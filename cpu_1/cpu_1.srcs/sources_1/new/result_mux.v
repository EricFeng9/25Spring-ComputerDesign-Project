`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 20:03:09
// Design Name: 
// Module Name: result_mux
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


// 结果多路复用器模块
module result_mux (
    input wire [31:0] alu_result,  // ALU结果
    input wire [31:0] mem_data,    // 存储器数据
    input wire [31:0] pc_data,     // PC值
    input wire [31:0] imm_data,    // 立即数
    input wire [1:0] result_src,   // 结果输出选择
    output reg [31:0] result       // 输出结果
);
    always @(*) begin
        case (result_src)
            2'b00: result = alu_result;  // 选择ALU结果
            2'b01: result = mem_data;    // 选择存储器数据
            2'b10: result = pc_data + imm_data; // 选择PC+立即数
            2'b11: result = imm_data;    // 选择立即数
        endcase
    end
endmodule
