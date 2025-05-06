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
    wire [31:0] alu_result_monitor;
    wire [31:0] reg_data1_monitor;
    wire [31:0] reg_data2_monitor;
    wire [31:0] r_wdata_monitor;
    wire mem_write_en_monitor;
    wire mem_read_en_monitor;
    wire io_write_en_monitor;
    wire io_read_en_monitor;
    wire reg_write_en_monitor;
    wire branch_taken_monitor;
    wire kick_off_monitor;
    wire branch_taken;
    wire [31:0]imm;
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
    
    // 监视内部信号
    assign pc_monitor = uut.pc;
    assign instruction_monitor = uut.instruction;
    assign alu_result_monitor = uut.alu_result;
    assign reg_data1_monitor = uut.reg_data1;
    assign reg_data2_monitor = uut.reg_data2;
    assign r_wdata_monitor = uut.r_wdata;
    
    assign mem_write_en_monitor = uut.mem_write_en;
    assign mem_read_en_monitor = uut.mem_read_en;
    assign io_write_en_monitor = uut.io_write_en;
    assign io_read_en_monitor = uut.io_read_en;
    assign reg_write_en_monitor = uut.reg_write_en;
    assign branch_taken_monitor = uut.branch_taken;
    assign kick_off_monitor = uut.kick_off;
    assign branch_taken = uut.branch_taken;
    assign imm = uut.imm;
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
        
        #600;

        
        
        // 结束测试
        $display("测试完成");
        $finish;
    end
    
    // 指令解码辅助任务
    task decode_instruction;
        input [31:0] inst;
        begin
            case(inst[6:0])
                7'b0110011: $display("R型指令: %h (add/sub/and/or/sll/srl等)", inst);
                7'b0010011: $display("I型指令: %h (addi等)", inst);
                7'b0000011: $display("加载指令: %h (lw等)", inst);
                7'b0100011: $display("存储指令: %h (sw等)", inst);
                7'b1100011: $display("分支指令: %h (beq/bne/blt/bge等)", inst);
                7'b1101111: $display("跳转指令: %h (jal)", inst);
                default: $display("其他指令: %h", inst);
            endcase
        end
    endtask
    
    // 监控指令执行
    always @(posedge clk) begin
        if(!rst && kick_off_monitor) begin
            decode_instruction(instruction_monitor);
            $display("PC=%h, ALU=%h, REG1=%h, REG2=%h, WRITE_DATA=%h",
                     pc_monitor, alu_result_monitor, reg_data1_monitor, 
                     reg_data2_monitor, r_wdata_monitor);
            if(branch_taken_monitor)
                $display("---> 分支跳转发生!");
            if(mem_write_en_monitor)
                $display("---> 内存写入: 地址=%h, 数据=%h", alu_result_monitor, reg_data2_monitor);
            if(mem_read_en_monitor)
                $display("---> 内存读取: 地址=%h", alu_result_monitor);
            if(io_write_en_monitor)
                $display("---> IO写入: 地址=%h, 数据=%h", alu_result_monitor, reg_data2_monitor);
            if(io_read_en_monitor)
                $display("---> IO读取: 地址=%h", alu_result_monitor);
        end
    end
    

endmodule 