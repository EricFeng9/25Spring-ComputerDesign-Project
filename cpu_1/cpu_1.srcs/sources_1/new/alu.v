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
input [31:0]a,
input [31:0]b,
input [1:0]alu_op,
output reg [31:0]result,
output zero,
input [2:0]funct3,
input inst_30

    );
wire [3:0]ctrl_output;
alu_control alu_ctrl(
.funct3(funct3),
.inst_30(inst_30),
.alu_op(alu_op),
.ctrl_output(ctrl_output)
);
assign zero=( result ==32'b0 )?  1'b1 : 1'b0;
always @(*) begin
    case(ctrl_output)
    `ADD:result=a+b;
    `SUB:result=a-b;
    `SLL:result= a << b[4:0];
    `SRL:result= a >> b[4:0];
    `SRA:result=$signed(a) >>> b[4:0];
    `SLT:result=($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
    `SLTU:result=(a < b) ? 32'b1 : 32'b0;
    `XOR:result=a^b;
    `OR:result=a|b;
    `AND:result=a&b;
    default:result=32'b0;
    endcase
end
endmodule
