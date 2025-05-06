`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 内存和IO多路复用模块
// 根据地址判断是访问内存还是IO设备
//////////////////////////////////////////////////////////////////////////////////

module mem_or_io(
    input wire io_read_en,          // IO读信号，来自Controller
    input wire io_write_en,         // IO写信号，来自Controller
    input wire mem_read_en,         // 内存读信号，来自Controller
    input wire mem_write_en,        // 内存写信号，来自Controller
    input wire [31:0] addr_in,      // 地址输入，来自ALU计算结果
    output wire [31:0] addr_out,    // 地址输出，连接到Data mem
    input wire [31:0] m_rdata,      // 从Data mem读取的数据
    input wire [31:0] io_rdata,     // 从IO设备读取的数据(拨码开关等)
    output reg [31:0] r_wdata,      // 写入寄存器的数据
    input wire [31:0] r_rdata,      // 从寄存器读取的数据
    output reg [31:0] io_wdata,     // 写入IO的数据
    output reg [31:0] m_wdata,      // 写入内存的数据
    output reg [0:0] led_ctrl,      // LED片选信号
    output reg [0:0] switch_ctrl,   // 开关片选信号
    output reg [0:0] seg_display_ctrl // 7段数码显示管片选信号
 );
    // IO设备地址范围定义
    parameter LED_BASE = 32'hFFFFC600;    // LED灯控制基地址
    parameter SWITCH_BASE = 32'hFFFFC700; // 开关控制基地址
    parameter SEG_DISPLAY_BASE = 32'hFFFFC700; // 七段数码管基地址

    // 地址直接传递给数据内存
    assign addr_out = addr_in;
    
    // 根据地址判断是访问内存还是IO设备
    wire is_io_addr = (addr_in == LED_BASE) || 
                      (addr_in == SWITCH_BASE) || 
                      (addr_in == SEG_DISPLAY_BASE);

    always @(*) begin
        // 初始化所有控制信号和数据
        led_ctrl = 1'b0;
        switch_ctrl = 1'b0;
        seg_display_ctrl = 1'b0;
        io_wdata = 32'h0;
        m_wdata = 32'h0;
        r_wdata = 32'h0;
        
        // 读取数据路径 (由mem_read_en或io_read_en控制)
        if(io_read_en && is_io_addr) begin
            if(addr_in == SWITCH_BASE) begin
                // IO读入状态，且地址指向开关，则寄存器读入开关的值
                r_wdata = io_rdata;
                switch_ctrl = 1'b1;
            end
        end
        else if(mem_read_en && !is_io_addr) begin
            // 内存读取状态，寄存器读入memory的值
            r_wdata = m_rdata;
        end
        
        // 写入数据路径 (由mem_write_en或io_write_en控制)
        if(io_write_en && is_io_addr) begin
            if(addr_in == LED_BASE) begin
                // IO写入状态，且地址指向LED
                io_wdata = r_rdata;
                led_ctrl = 1'b1;
            end 
            else if(addr_in == SEG_DISPLAY_BASE) begin
                // IO写入状态，且地址指向数码管
                io_wdata = r_rdata;
                seg_display_ctrl = 1'b1;
            end
        end 
        else if(mem_write_en && !is_io_addr) begin
            // 内存写入状态，将寄存器的值写入memory
            m_wdata = r_rdata;
        end
    end
endmodule    