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
    input [1:0] alu_op,        // 来自控制单元的简化操作码
    input [2:0] funct3,        // 指令的funct3字段
    input [6:0] funct7,        // 指令的funct7字段
    input [6:0] opcode,        // 指令的opcode字段
    output reg [3:0] ctrl_output // ALU控制输出
);
    always @(*) begin
        // 默认值为ADD
        ctrl_output = `ADD;
        
        case(alu_op)
            2'b00: begin
                // Load/Store/AUIPC指令使用ADD
                ctrl_output = `ADD;
            end
            
            2'b01: begin
                // Branch指令使用SUB进行比较
                ctrl_output = `SUB;
            end
            
            2'b10: begin
                // R型和I型算术逻辑指令
                if (opcode == 7'b0110011) begin  // R型指令
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
                end else if (opcode == 7'b0010011) begin  // I型指令
                    case(funct3)
                        3'b000: ctrl_output = `ADD;  // ADDI (始终是ADD)
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
                    ctrl_output = `ADD;  // 默认使用ADD
                end
            end
            
            2'b11: begin
                // JAL/JALR 或 LUI/AUIPC
                ctrl_output = `ADD;  // 默认操作
            end
            
            default: ctrl_output = `ILLEGAL;
        endcase
    end
endmodule
