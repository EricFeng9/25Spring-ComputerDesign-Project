`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 内存与IO接口控制器模块
// 用于判断访问的是内存还是IO设备
//////////////////////////////////////////////////////////////////////////////////

module mem_or_io(
    input wire io_read_en,          // IO读取使能信号，来自Controller
    input wire io_write_en,         // IO写入使能信号，来自Controller
    input wire mem_read_en,         // 内存读取使能信号，来自Controller
    input wire mem_write_en,        // 内存写入使能信号，来自Controller
    input wire [31:0] addr_in,      // 地址输入，来自ALU计算结果
    input wire [2:0] funct3,        // 指令的funct3字段，用于区分不同的Load/Store类型
    output wire [31:0] addr_out,    // 地址输出，连接到Data mem
    input wire [31:0] m_rdata,      // 从Data mem读取的数据
    input wire [31:0] io_rdata,     // 从IO设备读取的数据(开关输入)
    input wire [31:0] r_rdata,      // 从寄存器读取的数据
    input wire [31:0] pc_plus4,     // PC+4 信号
    input wire [31:0] imm,          // 立即数输入 (来自immediate_gen)
    input wire [1:0] wb_select,     // 来自control_unit的写回数据选择,00:ALU结果, 01:Mem/IO数据, 10:PC+4, 11:Imm
    output reg [31:0] r_wdata,      // 写入寄存器的数据
    output reg [31:0] io_wdata,     // 写入IO的数据
    output reg [31:0] m_wdata,      // 写入内存的数据
    output reg [0:0] led_ctrl,      // LED控制信号
    output reg [0:0] switch_ctrl,   // 开关控制信号
    output reg [0:0] seg_display_ctrl // 7段数码管控制信号
 );
    // IO设备的地址范围定义
    parameter LED_BASE = 32'hFFFFC600;    // LED控制器地址
    parameter SWITCH_BASE = 32'hFFFFC700; // 开关控制器地址
    parameter SEG_DISPLAY_BASE = 32'hFFFFC500; // 数码管控制器地址 (可能与文档不一致)

    // 将地址直接传递给内存模块
    assign addr_out = addr_in;
    
    // 检测地址是属于内存还是IO设备
    wire is_io_addr = (addr_in == LED_BASE) || 
                      (addr_in == SWITCH_BASE) || 
                      (addr_in == SEG_DISPLAY_BASE);
    
    // 字节选择信号，使用地址的低2位
    wire [1:0] byte_offset = addr_in[1:0];
    
    // 从32位数据中提取指定的字节
    reg [7:0] selected_byte;
    
    // 获取选定的字节
    always @(*) begin
        case(byte_offset)
            2'b00: selected_byte = m_rdata[7:0];
            2'b01: selected_byte = m_rdata[15:8];
            2'b10: selected_byte = m_rdata[23:16];
            2'b11: selected_byte = m_rdata[31:24];
        endcase
    end
    
    // 处理从内存或IO读取的数据
    reg [31:0] processed_mem_data;
    
    always @(*) begin
        case(funct3)
            3'h0: processed_mem_data = {{24{selected_byte[7]}}, selected_byte}; // lb (符号扩展)
            3'h1: processed_mem_data = (byte_offset[1] == 1'b0) ? 
                                        {{16{m_rdata[15]}}, m_rdata[15:0]} : 
                                        {{16{m_rdata[31]}}, m_rdata[31:16]}; // lh (符号扩展)
            3'h2: processed_mem_data = m_rdata; // lw (保持32位)
            3'h4: processed_mem_data = {24'b0, selected_byte}; // lbu (零扩展)
            3'h5: processed_mem_data = (byte_offset[1] == 1'b0) ? 
                                        {16'b0, m_rdata[15:0]} : 
                                        {16'b0, m_rdata[31:16]}; // lhu (零扩展)
            default: processed_mem_data = m_rdata; // 默认为lw
        endcase
    end
    
    reg [31:0] data_from_mem_or_io_source;
    always @(*) begin
        // 初始化所有控制信号和输出数据
        led_ctrl = 1'b0;
        switch_ctrl = 1'b0;
        seg_display_ctrl = 1'b0;
        io_wdata = 32'h0; // 写入IO的数据
        m_wdata = 32'h0;  // 写入内存的数据
        
        // 根据 wb_select 选择输出 r_wdata (写入寄存器的数据)
        case (wb_select)
            2'b00: r_wdata = addr_in;
            2'b01: r_wdata = (io_read_en && is_io_addr) ? io_rdata : 
                            (mem_read_en && !is_io_addr) ? processed_mem_data : 32'h0;
            2'b10: r_wdata = pc_plus4;
            2'b11: r_wdata = imm;
            default: r_wdata = 32'h0;
        endcase
        
        // 写入内存/IO的处理 (当mem_write_en或io_write_en有效时)
        if(io_write_en && is_io_addr) begin
            if(addr_in == LED_BASE) begin
                // IO写入操作，将数据写入LED
                io_wdata = r_rdata;
                led_ctrl = 1'b1;
            end
            else if(addr_in == SEG_DISPLAY_BASE) begin
                // IO写入操作，将数据写入数码管
                io_wdata = r_rdata;
                seg_display_ctrl = 1'b1;
            end
        end
        else if(mem_write_en && !is_io_addr) begin
            // 内存写入操作，将数据写入memory
            m_wdata = r_rdata;
        end
    end
endmodule    