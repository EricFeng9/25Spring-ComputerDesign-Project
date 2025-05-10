`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/11 01:04:54
// Design Name: 
// Module Name: top_tb_scen1
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


module top_tb_scen1();
// 输入信号定义
    reg clk;                  // 系统时钟
    reg rst;                  // 复位信号
    reg [10:0] switch;        // 开关输入信号
    reg start_pg;             // UART编程开始信号
    reg rx;                   // UART接收数据
    reg  led_en_button;
    // 输出信号
    wire [7:0] seg_en;        // 数码管使能信号
    wire [7:0] seg_out;       // 数码管段选信号
    wire [7:0] led;           // LED指示灯
    wire tx;                  // UART发送数据
    
    // 监控信号（用于调试和观察）
    wire cpu_clk;
    wire [31:0] pc_monitor;
    wire [31:0] instruction_monitor;
    wire [31:0] reg_data1;
    wire [31:0] reg_data2;
    wire [31:0] alu_input1;         // ALU输入1
    wire [31:0] alu_input2;         // ALU输入2
    wire [31:0] alu_src_1;
    wire [31:0] alu_src_2;
    wire [31:0] alu_result;
    wire [31:0] imm;                // 立即数
    wire [31:0] r_wdata;
    wire [31:0] mem_read_data;
    wire [31:0] mem_write_data;
    wire [31:0] io_wdata;
    wire [31:0] switch_values_extended;
    wire [1:0] wb_select;
    wire [1:0] alu_op;
    wire [7:0] led_value;
    wire [7:0] led_ctrl;
    wire seg_display_ctrl;
    // 连接监控信号
    assign cpu_clk = uut.cpu_clk;
    assign pc_monitor = uut.pc;
    assign instruction_monitor = uut.instruction;
    assign reg_data1 = uut.reg_data1;
    assign reg_data2 = uut.reg_data2;
    assign alu_input1 = uut.alu_input1;
    assign alu_input2 = uut.alu_input2;
    assign alu_src_1 = uut.alu_src_1;
    assign alu_src_2 = uut.alu_src_2;
    assign alu_result = uut.alu_result;
    assign imm = uut.imm;
    assign r_wdata = uut.r_wdata;
    assign mem_read_data = uut.mem_read_data;
    assign mem_write_data = uut.mem_write_data;
    assign io_wdata = uut.io_wdata;
    assign switch_values_extended = uut.switch_values_extended;
    assign wb_select = uut.wb_select;
    assign alu_op = uut.alu_op;
    assign led_value =uut.led_value;
    assign led_ctrl =uut.led_ctrl;
    assign seg_display_ctrl = uut.seg_display_ctrl;
    // 实例化被测试模块
    top uut(
        .clk(clk),
        .rst(rst),
        .switch(switch),
        .seg_en(seg_en),
        .seg_out(seg_out),
        .led(led),
        .start_pg(start_pg),
        .rx(rx),
        .tx(tx),
        .led_en_button(led_en_button)
    );
    
    
    
    // 时钟生成器
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz时钟 (周期10ns)
    end
    
    // 测试激励信号
    initial begin
        // 初始化输入信号
        rst = 1;
        switch = 11'b0;
        start_pg = 0;         // 选择正常执行模式 (kick_off=1)
        led_en_button = 1'b0;
        
        // 释放复位信号开始
        #300;
        rst = 0;
        //main
        //第一条代码在这执行
        #250
        //第二条代码
        #250
        //第三条...
        #250
        #250
        //io_load_case
        //case1:
        //读取开关状态
        switch = 11'b0000111_001;
        #250
        #250
        #250
        #250
        //提取案例编号
        #250
        //根据案例编号跳转
        #250
        #250
        #250
        //跳转到case1
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        $finish;
        
        #10000; //250ns每条指令，10000仿真40条指令
        
        // 结束仿真
        $display("仿真结束");
        $finish;
    end
endmodule
