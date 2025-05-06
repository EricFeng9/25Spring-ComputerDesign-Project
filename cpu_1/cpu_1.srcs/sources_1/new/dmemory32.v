`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 数据存储器包装模块
// 用于包装data_mem_ram IP核并添加UART编程接口
//////////////////////////////////////////////////////////////////////////////////

module dmemory32(
    input wire ram_clk_i,         // 内存时钟
    input wire ram_wen_i,         // 写使能
    input wire [13:0] ram_adr_i,  // 地址输入
    input wire [31:0] ram_dat_i,  // 写入数据
    output wire [31:0] ram_dat_o, // 读出数据
    
    // UART编程接口
    input wire upg_rst_i,         // UART编程复位
    input wire upg_clk_i,         // UART编程时钟
    input wire upg_wen_i,         // UART编程写使能
    input wire [13:0] upg_adr_i,  // UART编程地址
    input wire [31:0] upg_dat_i,  // UART编程数据
    input wire upg_done_i         // UART编程完成
);

    // 时钟选择：RAM工作时钟信号
    wire ram_clk = ram_clk_i;
    
    // 工作模式判断：kickOff=1为正常CPU模式，kickOff=0为UART编程模式
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    
    // 内存写使能
    wire ram_we = kickOff ? ram_wen_i : upg_wen_i;
    
    // 内存地址选择
    wire [13:0] ram_addr = kickOff ? ram_adr_i : upg_adr_i;
    
    // 写入数据选择
    wire [31:0] ram_data_in = kickOff ? ram_dat_i : upg_dat_i;
    
    // 实例化数据存储器IP核
    data_mem_ram data_ram(
        .clka(ram_clk),            // 时钟输入
        .wea(ram_we),              // 写使能
        .addra(ram_addr),          // 地址
        .dina(ram_data_in),        // 写入数据
        .douta(ram_dat_o)          // 读出数据
    );

endmodule 