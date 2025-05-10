`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 指令存储器模块
// 内部实例化 instruction_mem IP核, 并支持UART编程更新指令
//////////////////////////////////////////////////////////////////////////////////

module imemory32(
    input wire clk,             // 系统时钟 (给IP核使用)
    input wire [13:0] rom_adr_i,      // ROM地址输入 (来自PC, CPU正常工作时使用)
    output wire [31:0] instruction_o, // 指令输出
    
    // UART编程接口
    input wire upg_rst_i,             // UART编程模式复位信号 (高有效通常表示CPU模式, 低有效进入UART编程模式)
    input wire upg_clk_i,             // UART编程时钟
    input wire upg_wen_i,             // UART写使能 (用于编程指令存储器)
    input wire [13:0] upg_adr_i,      // UART地址输入 (用于编程)
    input wire [31:0] upg_dat_i,      // UART数据输入 (用于编程)
    input wire upg_done_i             // UART编程完成信号
);
    
    // 模式选择: kickOff=1 表示CPU正常工作模式, kickOff=0 表示UART编程模式
    // 当upg_rst_i为高 (CPU模式), 或 upg_rst_i为低且upg_done_i为高 (编程完成恢复CPU模式) 时, kickOff为1
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    
    // ROM写使能: 仅在UART编程模式下 (kickOff=0) 且UART写使能有效时, 才使能IP核的写操作
    wire rom_we = ~kickOff & upg_wen_i;
    
    // ROM地址选择: CPU模式下使用PC地址, UART编程模式下使用UART提供的地址
    wire [13:0] rom_addr = kickOff ? rom_adr_i : upg_adr_i;
    
    // 实例化指令存储器IP核 (例如 Xilinx 的 Distributed Memory Generator)
    instruction_mem_dist instmem(
        .clk(clk),              // IP核时钟输入
        .we(rom_we),            // IP核写使能输入
        .a(rom_addr),           // IP核地址输入
        .d(upg_dat_i),          // IP核数据输入 (仅在编程时写入)
        .spo(instruction_o)     // IP核数据输出 (单端口RAM的输出)
    );

endmodule 