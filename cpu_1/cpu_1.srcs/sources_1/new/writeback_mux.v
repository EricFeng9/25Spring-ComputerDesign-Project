`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 20:05:46
// Design Name: 
// Module Name: writeback_mux
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


// 写回多路复用器模块
module writeback_mux (
    input wire [31:0] alu_result,  // ALU结果
    input wire [31:0] mem_data,    // 存储器数据
    input wire [0:0] mem_to_reg,      // 寄存器写入源选择
    output reg [31:0] write_data   // 写回数据
);
    always @(*) begin
       if(mem_to_reg == 1'b0) begin
           write_data = alu_result;
       end
       else begin
           write_data = mem_data;
       end
   end
endmodule
