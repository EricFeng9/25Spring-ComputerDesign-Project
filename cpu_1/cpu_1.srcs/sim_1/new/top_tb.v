`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 顶层模块测试床文件
// 测试正常执行指令模式
//////////////////////////////////////////////////////////////////////////////////

module top_tb();
    // 输入信号
    reg clk;                  // 时钟信号
    reg rst;                  // 复位信号
    reg [10:0] switch;        // 开关输入信号
    reg start_pg;             // UART编程模式开关信号
    reg rx;                   // UART接收数据
    
    // 输出信号
    wire [7:0] seg_en;        // 数码管使能信号
    wire [7:0] seg_out;       // 数码管段选信号
    wire [7:0] led;           // LED输出信号
    wire tx;                  // UART发送数据
    
    // 内部监视信号（用于测试）
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
    // 监视内部信号
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
    
    // 实例化顶层模块
    top uut(
        .clk(clk),
        .rst(rst),
        .switch(switch),
        .seg_en(seg_en),
        .seg_out(seg_out),
        .led(led),
        .start_pg(start_pg),
        .rx(rx),
        .tx(tx)
    );
    
    
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz时钟 (周期10ns)
    end
    
    // 测试流程
    initial begin
        // 初始化输入
        rst = 1;
        switch = 11'b0;
        start_pg = 0;         // 确保处于正常执行模式 (kick_off=1)
        
        // 等待时钟信号稳定
        #300;
        rst = 0;
        
        #900;
        
        // 结束测试
        $display("测试完成");
        $finish;
    end

endmodule 