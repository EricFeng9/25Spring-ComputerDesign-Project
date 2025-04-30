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
    input branch_taken;      // 分支信号，1为需要分支
    input [0:0]rst;        // 重置pc为0
    input [31:0] imm32;// 32位立即数，用于计算分支地址
    input [31:0] pc;
    output [31:0] instruction; // 从内存中获取的指令（是上一个周期取出来的instruction）
    output reg [31:0] pc_next;
    always@ (posedge clk) begin
        if (rst == 1'b1) begin               // 如果零标志为0，初始化PC
            pc_next <= 32'h0;            // PC设置为0
        end
        else begin
            if(branch_taken==1'b1) begin       // 如果branch为1,执行分支
                pc_next <= pc + imm32;          // PC更新为当前PC加上立即数（分支地址）
            end
            else begin                     // 顺序执行
                pc_next <= pc + 4;              // PC增加4，指向下一条指令
            end
        end
    end
    // 输出为32位的instruction 
    instruction_mem urom(.clka(clk), .addra(pc_next[15:2]), .douta(instruction));
    
endmodule
