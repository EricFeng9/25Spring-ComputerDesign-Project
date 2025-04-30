module mem_or_io(
    input wire io_read_en,          // IO读信号，来自Controller
    input wire io_write_en,         // IO写信号，来自Controller
    input wire [31:0] addr_in,  // 地址输入，来自ALU计算结果
    output wire [31:0] addr_out, // 地址输出，连接到Data mem
    input wire [31:0] m_rdata,  // 从Data mem读取的数据
    input wire [15:0] io_rdata, // 从IO设备读取的数据(拨码开关等)
    output reg [31:0] r_wdata, // 写入寄存器的数据
    input wire [31:0] r_rdata,  // 从寄存器读取的数据
    output reg [31:0] io_wdata, // 写入IO的数据
    output reg [31:0] m_wdata,   // 写入内存的数据
    output reg [0:0] led_ctrl,         // LED片选信号
    output reg [0:0]switch_ctrl,       // 开关片选信号
    output reg [0:0]seg_display_ctrl, //7段数码显示管片选信号
    input wire [10:0] switch    //开关输入信号
 );
    // IO设备地址范围定义
    parameter LED_BASE = 32'hFFFFC600;    // LED灯控制基地址
    parameter SWITCH_BASE = 32'hFFFFC700; // 开关控制基地址
    parameter SEG_DISPLAY_BASE = 32'hFFFFC700; // 七段数码管基地址

    always @(*) begin
        //橙色数据流
        if(io_read_en && addr_in == SWITCH_BASE)begin
            //io读入状态，且地址指向开关，则寄存器读入开关的值(reg_write_en要打开)
            r_wdata <= io_rdata;
            switch_ctrl<=1;
        end
        else begin
            //否则寄存器读入memory的值（前提是reg_write_en\mem_read_en也得打开）
            r_wdata <= m_rdata;
        end
        
        //黄色数据流
        if(io_write_en && addr_in == LED_BASE)begin
            //io写入状态，且地址指向LED
             io_wdata <= r_rdata;
             led_ctrl <= 1;
        end else if(io_write_en && addr_in == SEG_DISPLAY_BASE)begin
            //io写入状态，且地址指向数码管
            io_wdata <= r_rdata;
            seg_display_ctrl <=1;
        end else begin
            //否则将寄存器的值写入memory（前提是mem_write_en也得打开）
            m_wdata <= r_rdata;
        end
        
        
    end
    
    //黑色数据流
    assign addr_in = addr_out;
    

endmodule    