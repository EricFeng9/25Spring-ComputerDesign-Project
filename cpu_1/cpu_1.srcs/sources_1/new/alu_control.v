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
input [2:0]funct3,
input inst_30,
input [1:0]alu_op,
output reg [3:0]ctrl_output
    );
    always @(*)begin
        casez ({alu_op, inst_30, funct3})
        6'b00????: ctrl_output = `ADD;       
        6'b01????: ctrl_output = `SUB;    
    
        6'b100000: ctrl_output = `ADD;      
        6'b101000: ctrl_output = `SUB;       
        6'b100001: ctrl_output = `SLL;
        6'b100010: ctrl_output = `SLT;
        6'b100011: ctrl_output = `SLTU;
        6'b100100: ctrl_output = `XOR;
        6'b100101: ctrl_output = `SRL;
        6'b101101: ctrl_output = `SRA;
        6'b100110: ctrl_output = `OR;
        6'b100111: ctrl_output = `AND;
        default:   ctrl_output = `ILLEGAL;
    endcase

    end
endmodule
