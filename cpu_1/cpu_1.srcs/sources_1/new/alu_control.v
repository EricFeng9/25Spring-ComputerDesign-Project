`timescale 1ns / 1ps
`include "ALUparams.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/03 15:44:54
// Design Name: 
// Module Name: alu_control
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


module alu_control(
    input [1:0] alu_op,        // ���Կ��Ƶ�Ԫ�ļ򻯲�����
    input [2:0] funct3,        // ָ���funct3�ֶ�
    input [6:0] funct7,        // ָ���funct7�ֶ�
    input [6:0] opcode,        // ָ���opcode�ֶ�
    output reg [3:0] ctrl_output // ALU�������
);
    always @(*) begin
        // Ĭ��ֵΪADD
        ctrl_output = `ADD;
        
        case(alu_op)
            2'b00: begin
                // Load/Store/AUIPCָ��ʹ��ADD
                ctrl_output = `ADD;
            end
            
            2'b01: begin
                // Branchָ��ʹ��SUB���бȽ�
                ctrl_output = `SUB;
            end
            
            2'b10: begin
                // R�ͺ�I�������߼�ָ��
                if (opcode == 7'b0110011) begin  // R��ָ��
                    case(funct3)
                        3'b000: ctrl_output = (funct7[5]) ? `SUB : `ADD;  // ADD/SUB
                        3'b001: ctrl_output = `SLL;  // SLL
                        3'b010: ctrl_output = `SLT;  // SLT
                        3'b011: ctrl_output = `SLTU; // SLTU
                        3'b100: ctrl_output = `XOR;  // XOR
                        3'b101: ctrl_output = (funct7[5]) ? `SRA : `SRL;  // SRL/SRA
                        3'b110: ctrl_output = `OR;   // OR
                        3'b111: ctrl_output = `AND;  // AND
                        default: ctrl_output = `ILLEGAL;
                    endcase
                end else if (opcode == 7'b0010011) begin  // I��ָ��
                    case(funct3)
                        3'b000: ctrl_output = `ADD;  // ADDI (ʼ����ADD)
                        3'b001: ctrl_output = `SLL;  // SLLI
                        3'b010: ctrl_output = `SLT;  // SLTI
                        3'b011: ctrl_output = `SLTU; // SLTIU
                        3'b100: ctrl_output = `XOR;  // XORI
                        3'b101: ctrl_output = (funct7[5]) ? `SRA : `SRL;  // SRLI/SRAI
                        3'b110: ctrl_output = `OR;   // ORI
                        3'b111: ctrl_output = `AND;  // ANDI
                        default: ctrl_output = `ILLEGAL;
                    endcase
                end else begin
                    ctrl_output = `ADD;  // Ĭ��ʹ��ADD
                end
            end
            
            2'b11: begin
                // JAL/JALR �� LUI/AUIPC
                ctrl_output = `ADD;  // Ĭ�ϲ���
            end
            
            default: ctrl_output = `ILLEGAL;
        endcase
    end
endmodule
