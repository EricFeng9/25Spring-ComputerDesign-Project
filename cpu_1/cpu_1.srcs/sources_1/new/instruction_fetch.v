`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 19:17:45
// Design Name: 
// Module Name: IFetch
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


module instruction_fetch(clk, branch_taken, rst, imm32, pc,instruction,pc_next);
    input clk;         
    input branch_taken;      // ��֧�źţ�1Ϊ��Ҫ��֧
    input [0:0]rst;        // ����pcΪ0
    input [31:0] imm32;// 32λ�����������ڼ����֧��ַ
    input [31:0] pc;
    output [31:0] instruction; // ���ڴ��л�ȡ��ָ�����һ������ȡ������instruction��
    output reg [31:0] pc_next;
    always@ (posedge clk) begin
        if (rst == 1'b1) begin               // ������־Ϊ0����ʼ��PC
            pc_next <= 32'h0;            // PC����Ϊ0
        end
        else begin
            if(branch_taken==1'b1) begin       // ���branchΪ1,ִ�з�֧
                pc_next <= pc + imm32;          // PC����Ϊ��ǰPC��������������֧��ַ��
            end
            else begin                     // ˳��ִ��
                pc_next <= pc + 4;              // PC����4��ָ����һ��ָ��
            end
        end
    end
    // ���Ϊ32λ��instruction 
    instruction_mem urom(.clka(clk), .addra(pc_next[15:2]), .douta(instruction));
    
endmodule
