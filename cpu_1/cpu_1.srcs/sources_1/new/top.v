`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 单周期CPU顶层模块
// 基于RISC-V指令集
// 包含数据通路和控制逻辑
// 支持串UART编程模式和正常工作模式切换
//////////////////////////////////////////////////////////////////////////////////

module top(
    input wire clk,              // 系统时钟,约为100MHz
    input wire rst,              // 复位信号 active high
    input wire [10:0]switch,     // 开关输入信号,[10:3]是SW7...SW0开关,[2:0]是X1、X2、X3开关     
    output wire [7:0] seg_en,     // 数码管使能信号
    output wire [7:0] seg_out,    // 数码管段选信号(gfedcba)
    output reg [7:0] led,        // 输出led指示灯
    
    //UART 接口
    input start_pg,              // active high
    input rx,                    // receive data by UART 参考lab12 ppt 10页的连接方式
    output tx                    // send data by UART 参考lab12 ppt 10页的连接方式
);

    //----------- UART编程模式相关信号 -----------
    // 控制信号
    wire spg_bufg;                  // 缓冲后的start_pg信号
    reg upg_rst;                    // UART编程复位信号
    wire kick_off;                   // CPU工作模式指示信号: 1=正常模式, 0=UART编程模式
    
    // UART编程器输出信号
    wire upg_clk_o;                 // UART编程时钟输出
    wire upg_wen_o;                 // UART写使能信号
    wire upg_done_o;                // UART编程完成信号
    wire [14:0] upg_adr_o;          // UART地址信号
    wire [31:0] upg_dat_o;          // UART数据信号
    
    // 时钟信号
    wire cpu_clk;                   // CPU工作时钟
    wire ram_clk;                   // 内存时钟
    wire upg_clk;                   // UART编程时钟 10MHz
    
    //----------- 数据通路 -----------
    // IFetch 相关信号
    wire [31:0] pc;                 // 程序计数器
    wire [31:0] pc_plus4;
    wire branch_taken;              // 分支跳转信号
    
    // 指令相关信号
    wire [31:0] instruction;        // 当前指令
    wire [6:0] opcode;              // 操作码 [6-0]
    wire [4:0] rd;                  // 目标寄存器 [11-7]
    wire [2:0] funct3;              // 功能码3 [14-12]
    wire [4:0] rs1;                 // 源寄存器1 [19-15]
    wire [4:0] rs2;                 // 源寄存器2 [24-20]
    wire [6:0] funct7;              // 功能码7 [31-25]
    wire [31:0] imm;                // 立即数
    wire [31:0] mem_write_data;     // 写入memory的中间数据
    
    // 寄存器堆相关信号
    wire [31:0] reg_data1;          // 寄存器读出数据1
    wire [31:0] reg_data2;          // 寄存器读出数据2
    wire reg_write_en;              // 寄存器写使能
   
    // ALU相关信号
    wire alu_src_2;                   // ALU输入2选择信号
    wire alu_src_1;
    wire [31:0] alu_input1;         // ALU输入1
    wire [31:0] alu_input2;         // ALU输入2
    wire [31:0] alu_result;         // ALU结果 -传给MemOrIO
    wire [1:0] alu_op;              // ALU操作码 5.3修改-改成2位
    wire alu_zero;                  // ALU零标志
    
    // IO 相关信号
    wire io_read_en;                // IO读使能信号 control_unit 输出
    wire io_write_en;               // IO写使能信号 control_unit 输出
    wire [1:0] wb_select;           // 写回选择信号 control_unit 输出
    wire [31:0] addr_out;           // 内存地址信号
    reg [31:0] io_rdata;            // 从IO设备读出的数据(通用)
    wire [31:0] r_wdata;            // 从mem or io读出的写数据
    wire [31:0] io_wdata;           // 写入IO设备的数据
    wire led_ctrl;                  // LED控制信号
    wire switch_ctrl;               // 开关控制信号
    wire seg_display_ctrl;          // 数码管显示控制信号
    
    // 内存相关信号
    wire [31:0] mem_read_data;      // 从内存读出的数据
    wire mem_write_en;              // 内存写使能信号
    wire mem_read_en;               // 内存读使能信号

    // 分支相关信号
    wire branch;                    // 分支信号
    wire jump;                      // 跳转信号
    wire [1:0] reg_src;             // 寄存器源选择信号
    wire [1:0] result_src;          // 结果源选择信号
    
    //----------- 模块实例化 -----------

    
    // 4MHz分频后的CPU时钟
    clk_100mhz_to_4mhz cpu_clock_div(
        .clk_in(clk),        // 输入100MHz时钟
        .rst(rst),                  // 复位信号
        .clk_out(cpu_clk)           // 输出4MHz CPU时钟
    );
    
    // 2MHz分频后的UART时钟
    clk_100mhz_to_2mhz uart_clock_div(
        .clk_in(clk),        // 输入100MHz时钟
        .rst(rst),                  // 复位信号
        .clk_out(upg_clk)           // 输出2MHz UART时钟
    );
    
    //----------- UART编程模式相关信号 -----------
    // 控制信号
    BUFG U1(.I(start_pg), .O(spg_bufg)); // 缓冲
    
    // UART编程复位信号
    always @(posedge cpu_clk) begin
        if (spg_bufg) begin
            upg_rst <= 0;           // UART编程复位信号
        end
        else begin
            upg_rst <= 1;           // UART编程复位信号
        end
    end
    
    ////////////////////////////////////
    //UART复位信号同步
    // 在UART时钟上升沿或复位信号上升沿同步
    reg upg_rst_sync1, upg_rst_sync2;
    always @(posedge upg_clk or posedge rst) begin
        if (rst) begin
            upg_rst_sync1 <= 1'b1;
            upg_rst_sync2 <= 1'b1;
        end else begin
            upg_rst_sync1 <= upg_rst;
            upg_rst_sync2 <= upg_rst_sync1;
        end
    end
    // UART复位信号同步完成
    wire upg_rst_synchronized;
    assign upg_rst_synchronized = upg_rst_sync2;
    ////////////////////////////////////
    
    // 正常模式指示信号
    assign kick_off = ~spg_bufg;
    
    // 内存时钟
    assign ram_clk = kick_off ? cpu_clk : upg_clk;
    
    //----------- UART编程器相关信号 -----------
    uart_programmer uart(
        .upg_clk_i(upg_clk),        // UART时钟输入
        .upg_rst_i(upg_rst_synchronized),        // UART复位信号
        .upg_rx_i(rx),              // UART数据输入
        .upg_clk_o(upg_clk_o),      // UART时钟输出
        .upg_wen_o(upg_wen_o),      // UART写使能信号
        .upg_adr_o(upg_adr_o),      // UART地址信号
        .upg_dat_o(upg_dat_o),      // UART数据信号
        .upg_done_o(upg_done_o),    // UART编程完成信号
        .upg_tx_o(tx)               // UART数据输出
    );
    
    //----------- 数据通路相关信号 -----------
    // 分支条件判断
    wire branch_condition;
    wire unsigned_less;             // 无符号比较: rs1 < rs2 (无符号比较)
    
    // 无符号比较alu_input1 < alu_input2
    assign unsigned_less = (alu_input1 < alu_input2);
    assign branch_condition = (funct3 == 3'h0) ? alu_zero :      // beq: 相等
                             (funct3 == 3'h1) ? ~alu_zero :     // bne: 不相等
                             (funct3 == 3'h4) ? (alu_result[31]) : // blt: 小于
                             (funct3 == 3'h5) ? (~alu_result[31]) : // bge: 大于等于
                             (funct3 == 3'h6) ? unsigned_less : // bltu: rs1 < rs2 (无符号比较)
                             (funct3 == 3'h7) ? ~unsigned_less : // bgeu: rs1 >= rs2 (无符号比较)
                             1'b0;  // 默认不跳转
    
    assign branch_taken = branch & branch_condition;
    
    // 指令获取
    instruction_fetch ifetch(
        .clk(cpu_clk),                           // CPU时钟
        .rst(rst),                               // 复位信号
        .kick_off(kick_off),                     // 工作模式信号
        .branch_taken(branch_taken),             // 分支跳转信号
        .jump(jump),                             // 跳转信号
        .imm(imm),                               // 立即数(立即数生成)
        
        // UART相关信号
        .upg_clk(upg_clk),                       // UART时钟
        .upg_rst(upg_rst_synchronized),                       // UART复位信号
        .upg_wen(upg_wen_o),                     // UART写使能信号
        .upg_adr(upg_adr_o),                     // UART地址
        .upg_dat(upg_dat_o),                     // UART数据
        .upg_done(upg_done_o),                   // UART完成信号
        
        .pc(pc),                                 // 程序计数器
        .pc_plus4(pc_plus4),                     // pc+4信号
        .instruction(instruction)                // 当前指令
    );
    

    // 指令相关信号
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[31:25];
    
    control_unit ucontrol_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .reg_write_en(reg_write_en),
        .alu_src_1(alu_src_1),
        .alu_src_2(alu_src_2),
        .mem_write_en(mem_write_en),
        .mem_read_en(mem_read_en),
        .branch(branch),
        .jump(jump),
        .io_write_en(io_write_en),
        .io_read_en(io_read_en),
        .wb_select(wb_select)
    );

    // 立即数生成
    immediate_gen imm_gen (
        .instruction(instruction),
        .imm(imm)
    );

    // 寄存器堆
    register_file reg_file (
        .clk(cpu_clk),              // 输入CPU时钟 
        .rst(rst),
        .reg_write_en(kick_off & reg_write_en), // 寄存器写使能
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(r_wdata),  // 写入mem_or_io的数据
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );


    // ALU输入1选择
    mux_alu_input umux_alu_input1 (
        .data0(reg_data1),
        .data1(pc),
        .sel(alu_src_1),
        .alu_input(alu_input1)
    );
    
    // ALU输入2选择
    mux_alu_input umux_alu_input2 (
        .data0(reg_data2),
        .data1(imm),
        .sel(alu_src_2),
        .alu_input(alu_input2)
    );
    
    // ALU - 结果计算
    alu alu_unit (
        .a(alu_input1),
        .b(alu_input2),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(alu_zero),
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode)
    );
    
    //----------- IO相关信号 -----------
    // 直接将开关值赋给一个中间信号，或者直接连接到 mem_or_io 的 io_rdata 输入
    wire [31:0] switch_values_extended = {21'b0, switch[10:0]}; // 使用所有11位开关，高位补零
    // LED的驱动逻辑可以保留：
    always @(*) begin
        if(led_ctrl) begin
            led <= io_wdata[7:0];
        end
        else begin
            led <= 8'b0;
        end
    end
    
    // 内存或IO读取
    mem_or_io io (
        .io_read_en(kick_off & io_read_en),     // 内存或IO读使能
        .io_write_en(kick_off & io_write_en),   // 内存或IO写使能
        .mem_read_en(kick_off & mem_read_en),   // 内存读使能
        .mem_write_en(kick_off & mem_write_en), // 内存写使能
        .addr_in(alu_result),
        .addr_out(addr_out),             // 内存地址信号
        .m_rdata(mem_read_data),
        .io_rdata(switch_values_extended), // 直接传递开关值
        .r_wdata(r_wdata),              // 内存或IO写数据
        .pc_plus4(pc_plus4),            // 带入pc_plus4信号
        .imm(imm),  // 带入immgen信号
        .wb_select(wb_select), //control unit输出写回选择信号: 00:ALU???, 01:Mem/IO????, 10:PC+4, 11:Imm
        .r_rdata(reg_data2),
        .io_wdata(io_wdata),
        .m_wdata(mem_write_data),
        .led_ctrl(led_ctrl),
        .switch_ctrl(switch_ctrl),
        .seg_display_ctrl(seg_display_ctrl)
    );

    // 数码管显示控制
    display_controller udisplay_controller(
        .clk(cpu_clk),
        .rst(rst),
        .led_display_ctrl(~kick_off | seg_display_ctrl),// 带入kick_off信号,0表示正常工作模式,led显示控制信号
        .result1(io_wdata),
        .result2(io_wdata),
        .prog_mode(~kick_off),             // 带入kick_off信号,0表示正常工作模式
        .prog_done(upg_done_o),           // 带入UART完成信号
        .seg_en(seg_en),
        .seg_out(seg_out)
    );
    
    //----------- 内存相关信号 -----------
    // 内存读取
    dmemory32 data_memory (
        .ram_clk_i(ram_clk),        // 内存时钟
        .ram_wen_i(kick_off ? mem_write_en : upg_wen_o & upg_adr_o[14]), // 内存写使能
        .ram_adr_i(kick_off ? alu_result[15:2] : upg_adr_o[13:0]),  // 内存地址
        .ram_dat_i(kick_off ? mem_write_data : upg_dat_o),  // 内存写入数据
        .ram_dat_o(mem_read_data),  // 内存读出数据
        // UART相关信号
        .upg_rst_i(upg_rst_synchronized),        // UART复位信号
        .upg_clk_i(upg_clk),        // UART时钟
        .upg_wen_i(upg_wen_o & upg_adr_o[14]), // UART写使能
        .upg_adr_i(upg_adr_o[13:0]), // UART地址
        .upg_dat_i(upg_dat_o),      // UART数据
        .upg_done_i(upg_done_o)     // UART完成信号
    );

    

endmodule





