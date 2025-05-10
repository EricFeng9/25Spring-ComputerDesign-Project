`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// PC多路复用器模块
// 用于选择下一个PC值
//////////////////////////////////////////////////////////////////////////////////

module mux_pc(
    input wire [31:0] pc_plus4,        // PC+4
    input wire [31:0] branch_target,   // 分支/跳转目标地址
    input wire branch_taken,           // 分支条件满足
    input wire jump,                   // 跳转指令
    output wire [31:0] pc_next         // 下一个PC值
);
    // 判断是否需要跳转或分支
    wire do_branch_jump = (branch_taken || jump);
    
    // 选择下一个PC值
    assign pc_next = do_branch_jump ? branch_target : pc_plus4;
endmodule 