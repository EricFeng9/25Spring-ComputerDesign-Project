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
    // 内部信号声明
    // PC 相关信号
    reg [31:0] pc_current;     // 当前PC值
    reg [31:0] pc_next;        // 下一个PC值
    wire [31:0] pc_plus4;       // PC+4
    wire [31:0] branch_target;  // 分支/跳转目标地址
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
    wire alu_src;               // ALU源选择信号
    wire mem_to_reg;            // 存储器到寄存器选择信号
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

    // 指令存储器 - 存储程序指令 可以用ip核
    instruction_memory inst_mem (
        .addr(pc_current),      // 地址输入为当前PC值
        .instruction(instruction) // 输出指令
    );

    // PC+4计算
    assign pc_plus4 = pc_current + 4;
    
    // 分支/跳转目标地址计算
    assign branch_target = pc_current + imm;
    
    // 分支条件判断
    assign branch_taken = branch & alu_zero;

    // PC多路复用器 - 选择下一个PC值
    mux_pc pc_mux (
        .pc_plus4(pc_plus4),
        .branch_target(branch_target),
        .branch_taken(branch_taken),
        .jump(jump),
        .pc_next(pc_next)
    );
    
    // PC寄存器更新
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_current <= 32'h00000000; // 复位时PC置零
        end else begin
            pc_current <= pc_next;      // 更新PC
        end
    end

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
    mux_alu_input alu_mux (
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
    mux_writeback wb_mux (
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .pc_plus4(pc_plus4),
        .imm(imm),
        .reg_src(reg_src),
        .write_data(reg_write_data)
    );

    // 结果多路复用器 - 选择CPU输出结果
    mux_result result_mux (
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .pc_data(pc_current),
        .imm_data(imm),
        .result_src(result_src),
        .result(result)
    );
    
    // 为测试设置结果源选择信号
    assign result_src = 2'b00; // 默认选择ALU结果

endmodule

// 指令存储器模块
module instruction_memory (
    input wire [31:0] addr,         // 地址输入
    output reg [31:0] instruction  // 指令输出
);
    // 指令存储器（ROM）
    reg [31:0] memory [0:1023];  // 4KB指令存储器
    
    // 初始化一些示例指令
    initial begin
        // 这里可以加载指令
        // 例如: memory[0] = 32'h00500113; // addi x2, x0, 5
    end
    
    // 读取指令
    always @(*) begin
        instruction = memory[addr[31:2]]; // 按字（32位）寻址
    end
endmodule

// 控制单元模块
module control_unit (
    input wire [6:0] opcode,     // 操作码
    input wire [2:0] funct3,     // 功能码3
    input wire [6:0] funct7,     // 功能码7
    output reg [3:0] alu_op,     // ALU操作码
    output reg reg_write_en,     // 寄存器写使能
    output reg alu_src,          // ALU源选择
    output reg mem_write_en,     // 存储器写使能
    output reg mem_read_en,      // 存储器读使能
    output reg mem_to_reg,       // 存储器到寄存器
    output reg branch,           // 分支信号
    output reg jump,             // 跳转信号
    output reg [1:0] reg_src     // 寄存器源选择
);
    // 操作码定义
    parameter R_TYPE     = 7'b0110011;  // R型指令
    parameter I_TYPE_ALU = 7'b0010011;  // I型ALU指令
    parameter I_TYPE_LOAD = 7'b0000011; // I型加载指令
    parameter S_TYPE     = 7'b0100011;  // S型存储指令
    parameter B_TYPE     = 7'b1100011;  // B型分支指令
    parameter J_TYPE     = 7'b1101111;  // J型跳转指令
    parameter I_TYPE_JALR = 7'b1100111; // I型间接跳转
    parameter U_TYPE_LUI = 7'b0110111;  // U型加载上立即数
    parameter U_TYPE_AUIPC = 7'b0010111; // U型PC相对加载
    
    always @(*) begin
        // 默认控制信号
        reg_write_en = 0;
        alu_src = 0;
        mem_write_en = 0;
        mem_read_en = 0;
        mem_to_reg = 0;
        branch = 0;
        jump = 0;
        reg_src = 2'b00;
        alu_op = 4'b0000;
        
        case (opcode)
            R_TYPE: begin
                reg_write_en = 1;
                alu_src = 0;      // 使用寄存器作为ALU第二个操作数
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;   // ALU结果写入寄存器
                branch = 0;
                jump = 0;
                reg_src = 2'b00;  // 选择ALU结果
                
                // 根据funct3和funct7设置ALU操作
                case (funct3)
                    3'b000: alu_op = (funct7 == 7'b0000000) ? 4'b0000 : 4'b0001; // ADD/SUB
                    3'b001: alu_op = 4'b0010; // SLL
                    3'b010: alu_op = 4'b0011; // SLT
                    3'b011: alu_op = 4'b0100; // SLTU
                    3'b100: alu_op = 4'b0101; // XOR
                    3'b101: alu_op = (funct7 == 7'b0000000) ? 4'b0110 : 4'b0111; // SRL/SRA
                    3'b110: alu_op = 4'b1000; // OR
                    3'b111: alu_op = 4'b1001; // AND
                endcase
            end
            
            I_TYPE_ALU: begin
                reg_write_en = 1;
                alu_src = 1;      // 使用立即数作为ALU第二个操作数
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;   // ALU结果写入寄存器
                branch = 0;
                jump = 0;
                reg_src = 2'b00;  // 选择ALU结果
                
                // 根据funct3设置ALU操作
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b001: alu_op = 4'b0010; // SLLI
                    3'b010: alu_op = 4'b0011; // SLTI
                    3'b011: alu_op = 4'b0100; // SLTIU
                    3'b100: alu_op = 4'b0101; // XORI
                    3'b101: alu_op = (funct7 == 7'b0000000) ? 4'b0110 : 4'b0111; // SRLI/SRAI
                    3'b110: alu_op = 4'b1000; // ORI
                    3'b111: alu_op = 4'b1001; // ANDI
                endcase
            end
            
            I_TYPE_LOAD: begin
                reg_write_en = 1;
                alu_src = 1;      // 使用立即数作为ALU第二个操作数
                mem_write_en = 0;
                mem_read_en = 1;  // 读取存储器
                mem_to_reg = 1;   // 存储器数据写入寄存器
                branch = 0;
                jump = 0;
                reg_src = 2'b01;  // 选择存储器数据
                alu_op = 4'b0000; // 使用加法计算地址
            end
            
            S_TYPE: begin
                reg_write_en = 0;
                alu_src = 1;      // 使用立即数作为ALU第二个操作数
                mem_write_en = 1; // 写入存储器
                mem_read_en = 0;
                mem_to_reg = 0;   // 不使用
                branch = 0;
                jump = 0;
                reg_src = 2'b00;  // 不使用
                alu_op = 4'b0000; // 使用加法计算地址
            end
            
            B_TYPE: begin
                reg_write_en = 0;
                alu_src = 0;      // 使用寄存器作为ALU第二个操作数
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;   // 不使用
                branch = 1;       // 分支指令
                jump = 0;
                reg_src = 2'b00;  // 不使用
                
                // 根据funct3设置分支类型
                case (funct3)
                    3'b000: alu_op = 4'b0001; // BEQ (相等比较，使用减法)
                    3'b001: alu_op = 4'b0001; // BNE (不等比较，使用减法)
                    3'b100: alu_op = 4'b0011; // BLT (小于比较)
                    3'b101: alu_op = 4'b0011; // BGE (大于等于比较)
                    3'b110: alu_op = 4'b0100; // BLTU (无符号小于比较)
                    3'b111: alu_op = 4'b0100; // BGEU (无符号大于等于比较)
                    default: alu_op = 4'b0000;
                endcase
            end
            
            J_TYPE: begin
                reg_write_en = 1;
                alu_src = 0;      // 不使用ALU
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 1;         // 跳转指令
                reg_src = 2'b10;  // 选择PC+4
                alu_op = 4'b0000; // 不使用ALU
            end
            
            I_TYPE_JALR: begin
                reg_write_en = 1;
                alu_src = 1;      // 使用立即数作为ALU第二个操作数
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 1;         // 跳转指令
                reg_src = 2'b10;  // 选择PC+4
                alu_op = 4'b0000; // 使用加法计算地址
            end
            
            U_TYPE_LUI: begin
                reg_write_en = 1;
                alu_src = 1;      // 使用立即数
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                reg_src = 2'b11;  // 选择立即数
                alu_op = 4'b1111; // 直通操作
            end
            
            U_TYPE_AUIPC: begin
                reg_write_en = 1;
                alu_src = 1;      // 使用立即数
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                reg_src = 2'b00;  // 选择ALU结果
                alu_op = 4'b0000; // 加法 (PC + imm)
            end
            
            default: begin
                // 默认不操作
                reg_write_en = 0;
                alu_src = 0;
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                reg_src = 2'b00;
                alu_op = 4'b0000;
            end
        endcase
    end
endmodule

// 立即数生成器模块
module immediate_gen (
    input wire [31:0] instruction,  // 指令
    output reg [31:0] imm           // 生成的立即数
);
    wire [6:0] opcode;
    assign opcode = instruction[6:0];
    
    always @(*) begin
        case (opcode)
            7'b0010011, 7'b0000011, 7'b1100111: // I型指令
                imm = {{20{instruction[31]}}, instruction[31:20]};
                
            7'b0100011: // S型指令
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                
            7'b1100011: // B型指令
                imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                
            7'b1101111: // J型指令
                imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                
            7'b0110111, 7'b0010111: // U型指令
                imm = {instruction[31:12], 12'b0};
                
            default:
                imm = 32'h00000000;
        endcase
    end
endmodule

// 寄存器堆模块
module register_file (
    input wire clk,                 // 时钟
    input wire rst,                 // 复位
    input wire reg_write_en,        // 寄存器写使能
    input wire [4:0] read_reg1,     // 读寄存器1地址
    input wire [4:0] read_reg2,     // 读寄存器2地址
    input wire [4:0] write_reg,     // 写寄存器地址
    input wire [31:0] write_data,   // 写入数据
    output wire [31:0] read_data1,  // 读出数据1
    output wire [31:0] read_data2   // 读出数据2
);
    // 寄存器堆
    reg [31:0] registers [0:31];
    integer i;
    
    // 初始化寄存器
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'h00000000;
        end
    end
    
    // 读寄存器
    assign read_data1 = (read_reg1 == 0) ? 32'h00000000 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'h00000000 : registers[read_reg2];
    
    // 写寄存器
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h00000000;
            end
        end else if (reg_write_en && write_reg != 0) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule

// ALU模块
module alu (
    input wire [31:0] a,           // 输入操作数a
    input wire [31:0] b,           // 输入操作数b
    input wire [3:0] alu_op,       // ALU操作码
    output reg [31:0] result,      // 运算结果
    output wire zero               // 零标志
);
    // ALU操作码定义
    parameter ALU_ADD  = 4'b0000;
    parameter ALU_SUB  = 4'b0001;
    parameter ALU_SLL  = 4'b0010;
    parameter ALU_SLT  = 4'b0011;
    parameter ALU_SLTU = 4'b0100;
    parameter ALU_XOR  = 4'b0101;
    parameter ALU_SRL  = 4'b0110;
    parameter ALU_SRA  = 4'b0111;
    parameter ALU_OR   = 4'b1000;
    parameter ALU_AND  = 4'b1001;
    parameter ALU_PASS = 4'b1111;
    
    // 根据操作码执行对应操作
    always @(*) begin
        case (alu_op)
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_SLL:  result = a << b[4:0];
            ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'h00000001 : 32'h00000000;
            ALU_SLTU: result = (a < b) ? 32'h00000001 : 32'h00000000;
            ALU_XOR:  result = a ^ b;
            ALU_SRL:  result = a >> b[4:0];
            ALU_SRA:  result = $signed(a) >>> b[4:0];
            ALU_OR:   result = a | b;
            ALU_AND:  result = a & b;
            ALU_PASS: result = b;  // 直通操作，用于LUI等指令
            default:  result = 32'h00000000;
        endcase
    end
    
    // 设置零标志
    assign zero = (result == 32'h00000000);
endmodule

// 数据存储器模块
module data_memory (
    input wire clk,                // 时钟
    input wire [31:0] addr,        // 地址
    input wire [31:0] write_data,  // 写入数据
    input wire write_en,           // 写使能
    input wire read_en,            // 读使能
    output reg [31:0] read_data    // 读出数据
);
    // 数据存储器
    reg [31:0] memory [0:1023];  // 4KB数据存储器
    
    // 读数据
    always @(*) begin
        if (read_en) begin
            read_data = memory[addr[31:2]];  // 按字（32位）寻址
        end else begin
            read_data = 32'h00000000;
        end
    end
    
    // 写数据
    always @(posedge clk) begin
        if (write_en) begin
            memory[addr[31:2]] <= write_data;
        end
    end
endmodule

// 写回多路复用器模块
module mux_writeback (
    input wire [31:0] alu_result,  // ALU结果
    input wire [31:0] mem_data,    // 存储器数据
    input wire [31:0] pc_plus4,    // PC+4
    input wire [31:0] imm,         // 立即数
    input wire [1:0] reg_src,      // 寄存器源选择
    output reg [31:0] write_data   // 写回数据
);
    always @(*) begin
        case (reg_src)
            2'b00: write_data = alu_result;  // ALU结果
            2'b01: write_data = mem_data;    // 存储器数据
            2'b10: write_data = pc_plus4;    // PC+4 (用于JAL, JALR)
            2'b11: write_data = imm;         // 立即数 (用于LUI)
        endcase
    end
endmodule

// 结果多路复用器模块
module mux_result (
    input wire [31:0] alu_result,  // ALU结果
    input wire [31:0] mem_data,    // 存储器数据
    input wire [31:0] pc_data,     // PC值
    input wire [31:0] imm_data,    // 立即数
    input wire [1:0] result_src,   // 结果输出选择
    output reg [31:0] result       // 输出结果
);
    always @(*) begin
        case (result_src)
            2'b00: result = alu_result;  // 选择ALU结果
            2'b01: result = mem_data;    // 选择存储器数据
            2'b10: result = pc_data + imm_data; // 选择PC+立即数
            2'b11: result = imm_data;    // 选择立即数
        endcase
    end
endmodule
