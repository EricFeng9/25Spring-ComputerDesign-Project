`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 单周期CPU顶层模块
// 基于RISC指令集架构
// 包含完整的数据通路和控制单元
//////////////////////////////////////////////////////////////////////////////////

module top(
    input wire clk,             // 时钟信号
    input wire rst,             // 复位信号
    output wire [31:0] result   // CPU执行结果输出
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

    // 寄存器相关信号
    wire [31:0] reg_data1;      // 寄存器读数据1
    wire [31:0] reg_data2;      // 寄存器读数据2
    wire [31:0] reg_write_data; // 寄存器写数据
    wire reg_write_en;          // 寄存器写使能

    // ALU相关信号
    wire [31:0] alu_input1;     // ALU输入1
    wire [31:0] alu_input2;     // ALU输入2
    wire [31:0] alu_result;     // ALU结果
    wire [3:0] alu_op;          // ALU操作码
    wire alu_zero;              // ALU零标志

    // 数据存储器相关信号
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
    always @(*) begin
        if (rst) begin
            pc <= 32'h0;  // 复位时PC置零
        end else begin
            pc <= pc_next; // 每个时钟周期更新PC为pc_next的值
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

    // ALU - 执行算术逻辑运算
    alu alu_unit (
        .a(alu_input1),
        .b(alu_input2),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(alu_zero)
    );

    // 数据存储器 - 处理数据读写 IP核 
    data_memory data_mem (
        .clk(clk),
        .addr(alu_result),
        .write_data(reg_data2),
        .write_en(mem_write_en),
        .read_en(mem_read_en),
        .read_data(mem_read_data)
    );

    // 写回多路复用器 - 选择写入寄存器的数据
    assign pc_plus4 = pc + 4;
    writeback_mux uwriteback_mux (
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .mem_to_reg(mem_to_reg),
        .write_data(reg_write_data)
    );

    // 结果多路复用器 - 选择CPU输出结果
    result_mux uresult_mux(
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .pc_data(pc),
        .imm_data(imm),
        .result_src(result_src),
        .result(result)
    );
    
    // 为测试设置结果源选择信号
    assign result_src = 2'b00; // 默认选择ALU结果

endmodule





