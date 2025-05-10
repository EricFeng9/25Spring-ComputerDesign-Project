`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// PC��·������ģ��
// ����ѡ����һ��PCֵ
//////////////////////////////////////////////////////////////////////////////////

module mux_pc(
    input wire [31:0] pc_plus4,        // PC+4
    input wire [31:0] branch_target,   // ��֧/��תĿ���ַ
    input wire branch_taken,           // ��֧��������
    input wire jump,                   // ��תָ��
    output wire [31:0] pc_next         // ��һ��PCֵ
);
    // �ж��Ƿ���Ҫ��ת���֧
    wire do_branch_jump = (branch_taken || jump);
    
    // ѡ����һ��PCֵ
    assign pc_next = do_branch_jump ? branch_target : pc_plus4;
endmodule 