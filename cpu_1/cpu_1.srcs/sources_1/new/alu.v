`timescale 1ns / 1ps
`include "ALUparams.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/03 15:08:06
// Design Name: 
// Module Name: alu
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


module alu(
    input [31:0] a,           // ��һ��������
    input [31:0] b,           // �ڶ���������
    input [1:0] alu_op,       // �����Ƶ�Ԫ�����Ĳ�����
    input [2:0] funct3,       // ָ���funct3�ֶ�
    input [6:0] funct7,       // ָ���funct7�ֶ�
    input [6:0] opcode,       // ָ���opcode�ֶ�
    output reg [31:0] result, // ALU���
    output zero               // ���־
);
    // ALU�����ź�
    wire [3:0] ctrl_output;
    
    // ʵ����ALU���Ƶ�Ԫ
    alu_control alu_ctrl(
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),
        .ctrl_output(ctrl_output)
    );
    
    // ���־
    assign zero = (result == 32'b0) ? 1'b1 : 1'b0;
    
    // ALU����
    always @(*) begin
        case(ctrl_output)
            `ADD:  result = a + b;
            `SUB:  result = a - b;
            `SLL:  result = a << b[4:0];
            `SRL:  result = a >> b[4:0];
            `SRA:  result = $signed(a) >>> b[4:0];
            `SLT:  result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            `SLTU: result = (a < b) ? 32'b1 : 32'b0;
            `XOR:  result = a ^ b;
            `OR:   result = a | b;
            `AND:  result = a & b;
            default: result = 32'b0;
        endcase
    end
endmodule
