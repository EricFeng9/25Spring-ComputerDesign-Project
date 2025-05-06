`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 指令获取模块
// 负责PC更新和指令存储器访问，支持UART编程功能
//////////////////////////////////////////////////////////////////////////////////

module instruction_fetch(
    input wire clk,                  // CPU时钟
    input wire rst,                  // 复位信号
    input wire kick_off,             // 工作模式: 1=正常模式, 0=编程模式
    input wire branch_taken,         // 分支条件满足信号
    input wire jump,                 // 跳转指令信号
    input wire [31:0] imm,           // 立即数(用于计算跳转地址)
    
    // UART编程器接口
    input wire upg_clk,              // UART编程时钟
    input wire upg_rst,              // UART编程复位
    input wire upg_wen,              // UART写使能
    input wire [14:0] upg_adr,       // UART地址
    input wire [31:0] upg_dat,       // UART数据
    input wire upg_done,             // UART编程完成
    
    output reg [31:0] pc,            // 程序计数器
    output wire [31:0] instruction   // 当前指令
);
    
    // PC更新逻辑
    wire [31:0] pc_plus4;            // PC+4
    wire [31:0] pc_branch;           // 分支目标地址
    wire [31:0] pc_next;             // 下一个PC值
    
    // 计算备选PC值
    assign pc_plus4 = pc + 4;                // 顺序执行
    assign pc_branch = pc + imm;             // 分支/跳转目标
    
    // 选择下一个PC值
    assign pc_next = (branch_taken || jump) ? pc_branch : pc_plus4;
    
    // 更新PC
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'h0;            // 复位时PC置零
        end 
        else if (kick_off) begin    // 只在正常模式下更新PC
            pc <= pc_next;          // 更新PC为pc_next的值
        end
    end
    
    // 指令存储器实例化
    imemory32 instruction_memory(
        .rom_clk_i(kick_off ? clk : upg_clk),      // 时钟输入（根据模式选择）
        .rom_adr_i(kick_off ? pc[15:2] : upg_adr[13:0]),   // 地址输入（根据模式选择）
        .Instruction_o(instruction),                   // 指令输出
        // UART编程器接口
        .upg_rst_i(upg_rst),                           // UART复位
        .upg_clk_i(upg_clk),                           // UART时钟
        .upg_wen_i(kick_off ? 1'b0 : upg_wen & ~upg_adr[14]),  // UART写使能（针对程序存储器）
        .upg_adr_i(upg_adr[13:0]),                   // UART地址
        .upg_dat_i(upg_dat),                         // UART数据
        .upg_done_i(upg_done)                        // UART完成信号
    );

endmodule
