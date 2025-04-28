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


// д�ض�·������ģ��
module writeback_mux (
    input wire [31:0] alu_result,  // ALU���
    input wire [31:0] mem_data,    // �洢������
    input wire [0:0] mem_to_reg,      // �Ĵ���д��Դѡ��
    output reg [31:0] write_data   // д������
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
