`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 单周期CPU顶层模块
// 基于RISC指令集架构
// 包含完整的数据通路和控制单元
//////////////////////////////////////////////////////////////////////////////////

module top(
    input wire clk,             // 时钟信号
    input wire rst,              // 复位信号
    input wire [10:0]switch,     //开关输入信号,[10:3]是SW7...SW0的值,[2:0]是X1、X2、X3的值     
    output reg [7:0] seg_en,         // 数码管使能信号
    output reg [7:0] seg_out,         // 数码管段选信号(gfedcba)
    output reg [7:0] led    //控制led灯的信号
);

    
    //内部信号------
    // IFetch 相关信号
    reg [31:0] pc; //pc
    wire [31:0] pc_plus4;
    wire branch_taken;          // 分支条件满足
    
    // 指令相关信号
    wire [31:0] instruction;    // 当前指令
    wire [6:0] opcode;          // 操作码 [6-0]
    wire [4:0] rd;              // 目标寄存器 [11-7]
    wire [2:0] funct3;          // 功能码3 [14-12]
    wire [4:0] rs1;             // 源寄存器1 [19-15]
    wire [4:0] rs2;             // 源寄存器2 [24-20]
    wire [6:0] funct7;          // 功能码7 [31-25]
    wire [31:0] imm;            // 立即数
    wire [31:0] mem_write_data; //写入memory 的中间信号
    
    // 寄存器相关信号
    wire [31:0] reg_data1;      // 寄存器读数据1
    wire [31:0] reg_data2;      // 寄存器读数据2
    wire [31:0] reg_write_data; // 寄存器写数据
    wire reg_write_en;          // 寄存器写使能
   
    //5.3改动：alu_op应为两位
    // ALU相关信号
    wire [31:0] alu_input1;     // ALU输入1
    wire [31:0] alu_input2;     // ALU输入2
    wire [31:0] alu_result;     // ALU结果 -接到MemOrIO
    wire [1:0] alu_op;          // ALU操作码
    wire alu_zero;              // ALU零标志
    
    // io 相关信号
    wire m_read_en;           // 内存读信号，来自Controller
    wire m_write_en;          // 内存写信号，来自Controller
    wire io_read_en;          // IO读信号，来自Controller
    wire io_write_en;         // IO写信号，来自Controller
    wire [31:0] addr_out;  // 地址输出，连接到Data mem
    reg [31:0] io_rdata;// 从IO设备读取的数据(拨码开关等)
    wire [31:0] r_wdata;//从mem or io中读取出来写进寄存器的数据
    wire [31:0] io_wdata;
    wire led_ctrl;
    wire switch_ctrl;
    wire seg_display_ctrl;
    
    // data memmory相关信号
    wire [31:0] mem_read_data;  // 存储器读数据
    wire mem_write_en;          // 存储器写使能
    wire mem_read_en;           // 存储器读使能

    // 控制信号
    wire [0:0]alu_src;               // ALU源选择信号
    wire [0:0]mem_to_reg;            // 存储器到寄存器选择信号
    wire branch;                // 分支信号
    wire jump;                  // 跳转信号
    wire [1:0] reg_src;         // 寄存器源选择信号
    wire [1:0] result_src;      // 结果输出选择信号

    // 控制单元 - 解码指令并生成控制信号
    // 连接指令字段
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[31:25];
    
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
            pc <= pc_next; // 每个时钟周期下降沿更新PC为pc_next的值
        end
    end
    
    // 分支条件判断
    assign branch_taken = branch & alu_zero;

    // 控制单元 - 生成各种控制信号
    control_unit ctrl_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .reg_write_en(reg_write_en),
        .alu_src(alu_src),
        .mem_write_en(mem_write_en),
        .mem_read_en(mem_read_en),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .reg_src(reg_src)
    );

    // 立即数生成器 - 根据指令类型生成立即数
    immediate_gen imm_gen (
        .instruction(instruction),
        .imm(imm)
    );

    // 寄存器堆 - 处理寄存器读写操作
    register_file reg_file (
        .clk(clk),
        .rst(rst),
        .reg_write_en(reg_write_en),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(reg_write_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    // ALU输入1选择
    assign alu_input1 = reg_data1;
 
    // ALU输入2多路复用器 - 选择ALU第二个输入
    alu_input2_mux ualu_input2_mux (
        .reg_data(reg_data2),
        .imm_data(imm),
        .sel(alu_src),
        .alu_input(alu_input2)
    );
    //5.3改动：需要接入func3和指令第三十位
    // ALU - 执行算术逻辑运算
    alu alu_unit (
        .a(alu_input1),
        .b(alu_input2),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(alu_zero),
        .funct3(funct3),
        .inst_30(instruction[30])
    );
    
    //IO部分
//    module mem_or_io(
//        input wire io_read_en,          // IO读信号，来自Controller
//        input wire io_write_en,         // IO写信号，来自Controller
//        input wire [31:0] addr_in,  // 地址输入，来自ALU计算结果
//        output wire [31:0] addr_out, // 地址输出，连接到Data mem
//        input wire [31:0] m_rdata,  // 从Data mem读取的数据
//        input wire [15:0] io_rdata, // 从IO设备读取的数据(拨码开关等)
//        output wire [31:0] r_wdata, // 写入寄存器的数据
//        input wire [31:0] r_rdata,  // 从寄存器读取的数据
//        output reg [31:0] io_wdata, // 写入IO的数据
//        output reg [31:0] m_wdata,   // 写入内存的数据
//        output reg [0:0] led_ctrl,         // LED片选信号
//        output reg [0:0]switch_ctrl,       // 开关片选信号
//        output reg [0:0]seg_display_ctrl //7段数码显示管片选信号
//        input wire [10:0] switch    //开关输入信号
//    );
    always @(*) begin
        if(switch_ctrl) begin
            io_rdata <= switch[10:3];
        end
        else begin
            io_rdata <= 32'bZ; //否则赋值为高阻态
        end
        if(led_ctrl) begin
            led <= io_wdata[8:0];
        end
        else begin
            led <= 8'b0;
        end
    end 
    mem_or_io io (
        .io_read_en(io_read_en),
        .io_write_en(io_write_en),
        .addr_in(alu_result),
        .m_rdata(mem_read_data),
        .io_rdata(io_rdata),
        .r_wdata(reg_write_data),
        .r_rdata(reg_data2),
        .io_wdata(io_wdata),
        .m_wdata(mem_write_data),
        .led_ctrl(led_ctrl),
        .switch_ctrl(switch_ctrl),
        .seg_display_ctrl(seg_display_ctrl)
    );
//    module display_controller(
//        input wire clk,                 
//        input wire rst,                  // 高电平有效的复位信号
//        input wire led_display_ctrl,
//        input wire [31:0] result1,       // 32位结果信号1
//        input wire [31:0] result2,       // 32位结果信号2
//        output reg [7:0] seg_en,         // 数码管使能信号
//        output reg [7:0] seg_out         // 数码管段选信号(gfedcba)
//    );
    display_controller udisplay_controller(
        .clk(clk),
        .rst(rst),
        .seg_display_ctrl(seg_display_ctrl),
        .result1(io_wdata),
        .result2(io_wdata),
        .seg_en(seg_en),
        .seg_out(seg_out)
    );
    
    
    //data memory部分
    data_memory data_mem (
        .clk(clk),
        .addr(addr_out),
        .write_data(mem_write_data),
        .write_en(mem_write_en),
        .read_en(mem_read_en),
        .read_data(mem_read_data)
    );

    // 写回多路复用器 - 选择写入寄存器的数据
    assign pc_plus4 = pc + 4;
    writeback_mux uwriteback_mux (
        .r_wdata(r_wdata),
        .mem_data(mem_read_data),
        .mem_to_reg(mem_to_reg),
        .write_data(reg_write_data)
    );

//    // 结果多路复用器 - 选择CPU输出结果
//    result_mux uresult_mux(
//        .alu_result(alu_result),
//        .mem_data(mem_read_data),
//        .pc_data(pc),
//        .imm_data(imm),
//        .result_src(result_src),
//        .result(result)
//    );
    

endmodule





