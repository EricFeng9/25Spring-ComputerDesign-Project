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
    input wire [31:0] data1,    // ��������1
    input wire [31:0] data0,    // ��������0
    input wire sel,             // ѡ���ź�
    output wire [31:0] alu_input // �������
);
    // ����ѡ���ź�ѡ�����
    assign alu_input = sel ? data1 : data0;
endmodule
