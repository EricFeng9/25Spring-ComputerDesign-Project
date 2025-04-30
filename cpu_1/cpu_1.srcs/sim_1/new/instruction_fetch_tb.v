`timescale 1ns / 1ps

module instruction_fetch_tb();
    reg clk;          
    reg branch_taken;        
    reg rst;          
    reg [31:0] imm;  
    reg [31:0]pc;
    wire [31:0] instruction; 
    wire [31:0] pc_next;
    //指令获取模块 i_fetch
    instruction_fetch i_fetch (
        .clk(clk),
        .branch_taken(branch_taken),
        .rst(rst),
        .imm32(imm),
        .pc(pc),
        .instruction(instruction),
        .pc_next(pc_next)  // 连接pc_next输出
        );
    // 更新pc
    always @(negedge clk) begin
        if (rst) begin
            pc <= 32'h0;  // 复位时PC置零
        end else begin
            pc <= pc_next; // 每个时钟周期更新PC为pc_next的值
        end
    end
    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns周期
    end
    
    // 测试过程
    initial begin
        // 初始化测试信号
        branch_taken = 0;
        rst = 1;
        imm = 32'h8;
        
        #15;
        //正常顺序执行
        rst = 0;      
        branch_taken = 0;    
        #60;
        //跳转
        branch_taken = 1;
        #10;
        branch_taken = 0;
        #20;
        
        $finish;
    end
    
    
endmodule 