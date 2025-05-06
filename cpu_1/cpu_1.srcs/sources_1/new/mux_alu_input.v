`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ALU�����·������ģ��
// ����ѡ��ALU�ĵڶ��������ǼĴ������ݻ���������
//////////////////////////////////////////////////////////////////////////////////

module mux_alu_input(
    input wire [31:0] reg_data,    // �Ĵ�����������
    input wire [31:0] imm_data,    // ����������
    input wire sel,                // ѡ���ź�
    output wire [31:0] alu_input   // ALU�������
);
    // ����ѡ���ź�ѡ�����
    assign alu_input = sel ? imm_data : reg_data;
endmodule 