`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 单周期CPU顶层模块
// 基于RISC指令集架构
// 包含完整的数据通路和控制单元
// 添加了UART通信模式和执行模式的切换功能
//////////////////////////////////////////////////////////////////////////////////

module top(
    input wire clk,              // 时钟信号
    input wire rst,              // 复位信号 active high
    input wire [10:0]switch,     // 开关输入信号,[10:3]是SW7...SW0的值,[2:0]是X1、X2、X3的值     
    output wire [7:0] seg_en,     // 数码管使能信号
    output wire [7:0] seg_out,    // 数码管段选信号(gfedcba)
    output reg [7:0] led,        // 控制led灯的信号
    
    //UART 通信
    input start_pg,              // active high
    input rx,                    // receive data by UART ！按lab12 ppt 10页的代码来绑定
    output tx                    // send data by UART ！按lab12 ppt 10页的代码来绑定
);

    //----------- UART编程器相关信号 -----------
    // 模式控制信号
    wire spg_bufg;                  // 去抖动后的start_pg信号
    reg upg_rst;                    // UART编程器复位信号
    wire kick_off;                   // CPU工作模式选择信号: 1=正常模式, 0=UART通信模式
    
    // UART编程器输出信号
    wire upg_clk_o;                 // UART编程器时钟输出
    wire upg_wen_o;                 // UART写使能输出
    wire upg_done_o;                // UART编程完成信号
    wire [14:0] upg_adr_o;          // UART地址输出
    wire [31:0] upg_dat_o;          // UART数据输出
    
    // 时钟相关
    wire cpu_clk;                   // CPU工作时钟 100MHz
    wire ram_clk;                   // 内存时钟
    wire upg_clk;                   // UART编程器时钟 10MHz
    
    //----------- 内部信号 -----------
    // IFetch 相关信号
    wire [31:0] pc;                 // 程序计数器
    wire branch_taken;              // 分支条件满足
    
    // 指令相关信号
    wire [31:0] instruction;        // 当前指令
    wire [6:0] opcode;              // 操作码 [6-0]
    wire [4:0] rd;                  // 目标寄存器 [11-7]
    wire [2:0] funct3;              // 功能码3 [14-12]
    wire [4:0] rs1;                 // 源寄存器1 [19-15]
    wire [4:0] rs2;                 // 源寄存器2 [24-20]
    wire [6:0] funct7;              // 功能码7 [31-25]
    wire [31:0] imm;                // 立即数
    wire [31:0] mem_write_data;     // 写入memory的中间信号
    
    // 寄存器相关信号
    wire [31:0] reg_data1;          // 寄存器读数据1
    wire [31:0] reg_data2;          // 寄存器读数据2
    wire reg_write_en;              // 寄存器写使能
   
    // ALU相关信号
    wire [31:0] alu_input1;         // ALU输入1
    wire [31:0] alu_input2;         // ALU输入2
    wire [31:0] alu_result;         // ALU结果 -接到MemOrIO
    wire [1:0] alu_op;              // ALU操作码 5.3改动-应该为2位
    wire alu_zero;                  // ALU零标志
    
    // IO 相关信号
    wire io_read_en;                // IO读信号，来自Controller
    wire io_write_en;               // IO写信号，来自Controller
    wire [31:0] addr_out;           // 地址输出，连接到Data mem
    reg [31:0] io_rdata;            // 从IO设备读取的数据(拨码开关等)
    wire [31:0] r_wdata;            // 从mem or io中读取出来写进寄存器的数据
    wire [31:0] io_wdata;           // 写入IO的数据
    wire led_ctrl;                  // LED控制信号
    wire switch_ctrl;               // 开关控制信号
    wire seg_display_ctrl;          // 数码管控制信号
    
    // 数据内存相关信号
    wire [31:0] mem_read_data;      // 存储器读数据
    wire mem_write_en;              // 存储器写使能
    wire mem_read_en;               // 存储器读使能

    // 控制信号
    wire alu_src;                   // ALU源选择信号
    wire branch;                    // 分支信号
    wire jump;                      // 跳转信号
    wire [1:0] reg_src;             // 寄存器源选择信号
    wire [1:0] result_src;          // 结果输出选择信号
    
    //----------- 时钟生成 -----------
    // 实例化时钟模块，将100MHz转换为10MHz UART时钟
    clk_100mhz_to_10mhz clock_gen(
        .clk_in1(clk),              // 输入时钟 100MHz
        .clk_out1(upg_clk),         // 输出UART时钟 10MHz
        .clk_out2(cpu_clk)          // 输出CPU时钟 还是100MHz
    );
    
    //----------- UART编程器控制逻辑 -----------
    // 按钮去抖动处理
    BUFG U1(.I(start_pg), .O(spg_bufg)); // 去抖动
    
    // 生成UART编程器复位信号
    always @(posedge cpu_clk) begin
        if (spg_bufg) begin
            upg_rst <= 0;           // UART编程模式下，复位UART编程器
        end
        else begin
            upg_rst <= 1;           // 非UART编程模式，UART编程器复位
        end
    end
    
    // 工作模式切换：kick_off=1为正常工作模式，kick_off=0为UART通信模式
    // 直接由开关状态决定
    assign kick_off = ~spg_bufg;
    
    // 生成RAM时钟 (根据当前模式选择不同时钟源)
    assign ram_clk = kick_off ? cpu_clk : upg_clk;
    
    //----------- UART编程模块 -----------
    uart_programmer uart(
        .upg_clk_i(upg_clk),        // UART时钟输入
        .upg_rst_i(upg_rst),        // UART复位信号
        .upg_rx_i(rx),              // UART接收数据
        .upg_clk_o(upg_clk_o),      // UART时钟输出
        .upg_wen_o(upg_wen_o),      // UART写使能
        .upg_adr_o(upg_adr_o),      // UART地址
        .upg_dat_o(upg_dat_o),      // UART数据
        .upg_done_o(upg_done_o),    // UART编程完成信号
        .upg_tx_o(tx)               // UART发送数据
    );
    
    //----------- 指令获取和程序内存 -----------
    // 判断是否分支/跳转
    assign branch_taken = branch & alu_zero;
    
    // 使用instruction_fetch模块
    instruction_fetch ifetch(
        .clk(cpu_clk),                           // CPU时钟
        .rst(rst),                               // 复位信号
        .kick_off(kick_off),                     // 工作模式选择
        .branch_taken(branch_taken),             // 分支条件满足
        .jump(jump),                             // 跳转指令
        .imm(imm),                               // 立即数(用于计算跳转地址)
        
        // UART编程器接口
        .upg_clk(upg_clk),                       // UART编程时钟
        .upg_rst(upg_rst),                       // UART编程复位
        .upg_wen(upg_wen_o),                     // UART写使能
        .upg_adr(upg_adr_o),                     // UART地址
        .upg_dat(upg_dat_o),                     // UART数据
        .upg_done(upg_done_o),                   // UART编程完成
        
        .pc(pc),                                 // 程序计数器输出
        .instruction(instruction)                // 当前指令输出
    );
    
    // 控制单元 - 解码指令并生成控制信号
    // 连接指令字段
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[31:25];
    
    // 控制单元 - 生成各种控制信号
    control_unit ucontrol_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .reg_write_en(reg_write_en),
        .alu_src(alu_src),
        .mem_write_en(mem_write_en),
        .mem_read_en(mem_read_en),
        .branch(branch),
        .jump(jump),
        .io_write_en(io_write_en),
        .io_read_en(io_read_en)
    );

    // 立即数生成器 - 根据指令类型生成立即数
    immediate_gen imm_gen (
        .instruction(instruction),
        .imm(imm)
    );

    // 寄存器堆 - 处理寄存器读写操作
    register_file reg_file (
        .clk(cpu_clk),              // 使用CPU时钟
        .rst(rst),
        .reg_write_en(kick_off & reg_write_en), // 只在正常模式下写入寄存器
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(r_wdata),  // 写回数据直接从mem_or_io模块获取
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    // ALU输入1选择
    assign alu_input1 = reg_data1;
 
    // ALU输入2多路复用器 - 选择ALU第二个输入
    mux_alu_input umux_alu_input (
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
    
    //----------- IO部分 -----------
    // IO读数据处理
    always @(*) begin
        if(switch_ctrl) begin
            io_rdata <= switch[10:3];    // 读取开关状态
        end
        else begin
            io_rdata <= 32'bZ;          // 否则赋值为高阻态
        end
        
        // LED输出处理
        if(led_ctrl) begin
            led <= io_wdata[7:0];       // 将数据写入LED
        end
        else begin
            led <= 8'b0;                // 默认LED全灭
        end
    end
    
    // 内存和IO接口模块
    mem_or_io io (
        .io_read_en(kick_off & io_read_en),     // 只在正常模式下读取IO
        .io_write_en(kick_off & io_write_en),   // 只在正常模式下写入IO
        .mem_read_en(kick_off & mem_read_en),   // 只在正常模式下读取内存
        .mem_write_en(kick_off & mem_write_en), // 只在正常模式下写入内存
        .addr_in(alu_result),
        .addr_out(addr_out),             // 输出到数据内存的地址
        .m_rdata(mem_read_data),
        .io_rdata(io_rdata),
        .r_wdata(r_wdata),              // 直接产生要写回寄存器的数据
        .r_rdata(reg_data2),
        .io_wdata(io_wdata),
        .m_wdata(mem_write_data),
        .led_ctrl(led_ctrl),
        .switch_ctrl(switch_ctrl),
        .seg_display_ctrl(seg_display_ctrl)
    );

    // 数码管显示控制器
    display_controller udisplay_controller(
        .clk(cpu_clk),
        .rst(rst),
        .led_display_ctrl(~kick_off | seg_display_ctrl),// 当kick_off为0时，处于编程模式,led灯也可以显示，否则根据片选信号显示
        .result1(io_wdata),
        .result2(io_wdata),
        .prog_mode(~kick_off),             // 当kick_off为0时，处于编程模式
        .prog_done(upg_done_o),           // 编程完成标志
        .seg_en(seg_en),
        .seg_out(seg_out)
    );
    
    //----------- 数据内存部分 -----------
    // 数据内存（支持UART编程）
    dmemory32 data_memory (
        .ram_clk_i(ram_clk),        // 内存时钟（根据模式选择）
        .ram_wen_i(kick_off ? mem_write_en : upg_wen_o & upg_adr_o[14]), // 写使能，这里当 upg_adr_o[14] 为 1 时，才会启用对数据内存的写入
        .ram_adr_i(kick_off ? alu_result[15:2] : upg_adr_o[13:0]),  // 地址输入
        .ram_dat_i(kick_off ? mem_write_data : upg_dat_o),  // 写入数据
        .ram_dat_o(mem_read_data),  // 读出数据
        // UART编程器接口
        .upg_rst_i(upg_rst),        // UART复位
        .upg_clk_i(upg_clk),        // UART时钟
        .upg_wen_i(upg_wen_o & upg_adr_o[14]), // UART写使能（针对数据内存），只有当 upg_adr_o[14] 为 1 时，UART编程器的写使能信号才会传递给数据内存。
        .upg_adr_i(upg_adr_o[13:0]), // UART地址
        .upg_dat_i(upg_dat_o),      // UART数据
        .upg_done_i(upg_done_o)     // UART完成信号
    );

    

endmodule





