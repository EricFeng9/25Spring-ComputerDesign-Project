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


// �����·������ģ��
module result_mux (
    input wire [31:0] alu_result,  // ALU���
    input wire [31:0] mem_data,    // �洢������
    input wire [31:0] pc_data,     // PCֵ
    input wire [31:0] imm_data,    // ������
    input wire [1:0] result_src,   // ������ѡ��
    output reg [31:0] result       // ������
);
    always @(*) begin
        case (result_src)
            2'b00: result = alu_result;  // ѡ��ALU���
            2'b01: result = mem_data;    // ѡ��洢������
            2'b10: result = pc_data + imm_data; // ѡ��PC+������
            2'b11: result = imm_data;    // ѡ��������
        endcase
    end
endmodule
