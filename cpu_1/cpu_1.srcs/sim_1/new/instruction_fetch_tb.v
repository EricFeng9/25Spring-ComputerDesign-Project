`timescale 1ns / 1ps

module instruction_fetch_tb();
    reg clk;          
    reg rst;
    reg kick_off;                // 工作模式信号: 1=正常模式  
    reg branch_taken;            // 分支条件满足信号
    reg jump;                    // 跳转信号
    reg [31:0] imm;              // 立即数(用于分支/跳转目标计算)
    
    // UART编程接口 (仅声明但不会实际测试)
    reg upg_clk;
    reg upg_rst;
    reg upg_wen;
    reg [14:0] upg_adr;
    reg [31:0] upg_dat;
    reg upg_done;
    
    // 输出信号
    wire [31:0] pc;              // 程序计数器
    wire [31:0] instruction;     // 当前指令
    
    // 实例化instruction_fetch模块
    instruction_fetch i_fetch (
        .clk(clk),                  // CPU时钟
        .rst(rst),                  // 复位信号
        .kick_off(kick_off),        // 工作模式: 1=正常模式
        .branch_taken(branch_taken),// 分支条件满足
        .jump(jump),                // 跳转指令
        .imm(imm),                  // 立即数
        
        // UART编程器接口
        .upg_clk(upg_clk),          // UART编程时钟
        .upg_rst(upg_rst),          // UART编程复位
        .upg_wen(upg_wen),          // UART写使能
        .upg_adr(upg_adr),          // UART地址
        .upg_dat(upg_dat),          // UART数据
        .upg_done(upg_done),        // UART编程完成
        
        .pc(pc),                    // 程序计数器输出
        .instruction(instruction)   // 当前指令输出
    );
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;      // 10ns周期
    end
    
    // 测试过程
    initial begin
        // 初始化所有信号
        rst = 1;
        kick_off = 1;               // 设置为正常执行模式
        branch_taken = 0;
        jump = 0;
        imm = 32'h8;
        
        // UART相关信号设置为默认值(不会影响测试)
        upg_clk = 0;
        upg_rst = 1;
        upg_wen = 0;
        upg_adr = 15'h0;
        upg_dat = 32'h0;
        upg_done = 1;
        
        // 复位后释放，开始测试顺序执行
        #15;
        rst = 0;      
        branch_taken = 0;
        jump = 0;    
        #20;
        
        // 测试分支指令
        branch_taken = 1;
        #10;
        branch_taken = 0;
        #20;
        
        // 测试跳转指令
        jump = 1;
        #10;
        jump = 0;
        #20;
        
        // 测试同时有分支和跳转
        branch_taken = 1;
        jump = 1;
        #10;
        branch_taken = 0;
        jump = 0;
        #20;
        

        $finish;
    end
    
    // 监视器：打印重要信号值
    initial begin
        $monitor("Time=%0t, rst=%b, kick_off=%b, branch_taken=%b, jump=%b, imm=%h, pc=%h, instruction=%h",
                $time, rst, kick_off, branch_taken, jump, imm, pc, instruction);
    end
    
endmodule 