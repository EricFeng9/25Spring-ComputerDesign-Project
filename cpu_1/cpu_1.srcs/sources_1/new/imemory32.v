`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 程序存储器包装模块
// 用于包装instruction_mem IP核并添加UART编程接口
//////////////////////////////////////////////////////////////////////////////////

module imemory32(
    input wire rom_clk_i,             // 指令内存时钟
    input wire [13:0] rom_adr_i,      // 指令地址输入（pc输入）
    output wire [31:0] Instruction_o, // 指令输出
    
    // UART编程接口
    input wire upg_rst_i,             // UART编程复位
    input wire upg_clk_i,             // UART编程时钟
    input wire upg_wen_i,             // UART编程写使能
    input wire [13:0] upg_adr_i,      // UART编程地址
    input wire [31:0] upg_dat_i,      // UART编程数据
    input wire upg_done_i             // UART编程完成
);

    // 时钟选择：ROM工作时钟信号
    wire rom_clk = rom_clk_i;
    
    // 工作模式判断：kickOff=1为正常CPU模式，kickOff=0为UART编程模式
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    
    // ROM写使能（只在编程模式下允许写入）
    wire rom_we = ~kickOff & upg_wen_i;
    
    // 指令地址选择
    wire [13:0] rom_addr = kickOff ? rom_adr_i : upg_adr_i;
    
    // 实例化指令存储器IP核
    instruction_mem instmem(
        .clka(rom_clk),              // 时钟输入
        .wea(rom_we),                // 写使能
        .addra(rom_addr),            // 地址
        .dina(upg_dat_i),            // 写入数据（仅在编程模式时有效）
        .douta(Instruction_o)        // 读出指令
    );

endmodule 