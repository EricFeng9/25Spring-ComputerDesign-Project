`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/06 17:31:00
// Design Name: 
// Module Name: immediate_gen
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
// 立即数生成器 - 根据指令类型生成立即数

module immediate_gen(
input [31:0] instruction,
output reg [31:0] imm
    );
    
     always @(*) begin
           case (instruction[6:0])
               7'b0000011, 7'b0010011,7'b1100111: begin // Load, Immediate,Jalr
                   imm = { {20{instruction[31]}}, instruction[31:20] };//高20位填充符号位;
               end
               7'b0100011: begin // Store
                   imm = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
               end
               7'b1100011: begin // Branch
                   imm = { {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0 };
               end
               7'b1101111: begin // Jump
                   imm = { {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0 };
               end
               7'b0110111,7'b0010111:begin //lui,auipc
                   imm = { instruction[31:12],12'b0 };
                end
               default: begin
                   imm = 32'b0;
               end
           endcase
       end


endmodule
