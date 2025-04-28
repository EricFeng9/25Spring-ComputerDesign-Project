`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 20:08:11
// Design Name: 
// Module Name: alu_input2_mux
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


module alu_input2_mux(
    input wire [31:0] reg_data2,
    input wire [31:0] imm_data,
    input wire [0:0] alu_src,
    output reg [32:0] alu_input
    );
    always @(*) begin
        if(alu_src == 1'b0) begin
            alu_input = reg_data2;
        end
        else begin
            alu_input = imm_data;
        end
    end
    
endmodule
