`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ������CPU����ģ��
// ����RISC-Vָ�
// ��������ͨ·�Ϳ����߼�
// ֧�ִ�UART���ģʽ����������ģʽ�л�
//////////////////////////////////////////////////////////////////////////////////

module top(
    input wire clk,              // ϵͳʱ��,ԼΪ100MHz
    input wire rst,              // ��λ�ź� active high
    input wire [10:0]switch,     // ���������ź�,[10:3]��SW7...SW0����,[2:0]��X1��X2��X3����     
    output wire [7:0] seg_en,     // �����ʹ���ź�
    output wire [7:0] seg_out,    // ����ܶ�ѡ�ź�(gfedcba)
    output reg [7:0] led,        // ���ledָʾ��
    
    //UART �ӿ�
    input start_pg,              // active high
    input rx,                    // receive data by UART �ο�lab12 ppt 10ҳ�����ӷ�ʽ
    output tx                    // send data by UART �ο�lab12 ppt 10ҳ�����ӷ�ʽ
);

    //----------- UART���ģʽ����ź� -----------
    // �����ź�
    wire spg_bufg;                  // ������start_pg�ź�
    reg upg_rst;                    // UART��̸�λ�ź�
    wire kick_off;                   // CPU����ģʽָʾ�ź�: 1=����ģʽ, 0=UART���ģʽ
    
    // UART���������ź�
    wire upg_clk_o;                 // UART���ʱ�����
    wire upg_wen_o;                 // UARTдʹ���ź�
    wire upg_done_o;                // UART�������ź�
    wire [14:0] upg_adr_o;          // UART��ַ�ź�
    wire [31:0] upg_dat_o;          // UART�����ź�
    
    // ʱ���ź�
    wire cpu_clk;                   // CPU����ʱ��
    wire ram_clk;                   // �ڴ�ʱ��
    wire upg_clk;                   // UART���ʱ�� 10MHz
    
    //----------- ����ͨ· -----------
    // IFetch ����ź�
    wire [31:0] pc;                 // ���������
    wire [31:0] pc_plus4;
    wire branch_taken;              // ��֧��ת�ź�
    
    // ָ������ź�
    wire [31:0] instruction;        // ��ǰָ��
    wire [6:0] opcode;              // ������ [6-0]
    wire [4:0] rd;                  // Ŀ��Ĵ��� [11-7]
    wire [2:0] funct3;              // ������3 [14-12]
    wire [4:0] rs1;                 // Դ�Ĵ���1 [19-15]
    wire [4:0] rs2;                 // Դ�Ĵ���2 [24-20]
    wire [6:0] funct7;              // ������7 [31-25]
    wire [31:0] imm;                // ������
    wire [31:0] mem_write_data;     // д��memory���м�����
    
    // �Ĵ���������ź�
    wire [31:0] reg_data1;          // �Ĵ�����������1
    wire [31:0] reg_data2;          // �Ĵ�����������2
    wire reg_write_en;              // �Ĵ���дʹ��
   
    // ALU����ź�
    wire alu_src_2;                   // ALU����2ѡ���ź�
    wire alu_src_1;
    wire [31:0] alu_input1;         // ALU����1
    wire [31:0] alu_input2;         // ALU����2
    wire [31:0] alu_result;         // ALU��� -����MemOrIO
    wire [1:0] alu_op;              // ALU������ 5.3�޸�-�ĳ�2λ
    wire alu_zero;                  // ALU���־
    
    // IO ����ź�
    wire io_read_en;                // IO��ʹ���ź� control_unit ���
    wire io_write_en;               // IOдʹ���ź� control_unit ���
    wire [1:0] wb_select;           // д��ѡ���ź� control_unit ���
    wire [31:0] addr_out;           // �ڴ��ַ�ź�
    reg [31:0] io_rdata;            // ��IO�豸����������(ͨ��)
    wire [31:0] r_wdata;            // ��mem or io������д����
    wire [31:0] io_wdata;           // д��IO�豸������
    wire led_ctrl;                  // LED�����ź�
    wire switch_ctrl;               // ���ؿ����ź�
    wire seg_display_ctrl;          // �������ʾ�����ź�
    
    // �ڴ�����ź�
    wire [31:0] mem_read_data;      // ���ڴ����������
    wire mem_write_en;              // �ڴ�дʹ���ź�
    wire mem_read_en;               // �ڴ��ʹ���ź�

    // ��֧����ź�
    wire branch;                    // ��֧�ź�
    wire jump;                      // ��ת�ź�
    wire [1:0] reg_src;             // �Ĵ���Դѡ���ź�
    wire [1:0] result_src;          // ���Դѡ���ź�
    
    //----------- ģ��ʵ���� -----------

    
    // 4MHz��Ƶ���CPUʱ��
    clk_100mhz_to_4mhz cpu_clock_div(
        .clk_in(clk),        // ����100MHzʱ��
        .rst(rst),                  // ��λ�ź�
        .clk_out(cpu_clk)           // ���4MHz CPUʱ��
    );
    
    // 2MHz��Ƶ���UARTʱ��
    clk_100mhz_to_2mhz uart_clock_div(
        .clk_in(clk),        // ����100MHzʱ��
        .rst(rst),                  // ��λ�ź�
        .clk_out(upg_clk)           // ���2MHz UARTʱ��
    );
    
    //----------- UART���ģʽ����ź� -----------
    // �����ź�
    BUFG U1(.I(start_pg), .O(spg_bufg)); // ����
    
    // UART��̸�λ�ź�
    always @(posedge cpu_clk) begin
        if (spg_bufg) begin
            upg_rst <= 0;           // UART��̸�λ�ź�
        end
        else begin
            upg_rst <= 1;           // UART��̸�λ�ź�
        end
    end
    
    ////////////////////////////////////
    //UART��λ�ź�ͬ��
    // ��UARTʱ�������ػ�λ�ź�������ͬ��
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
    // UART��λ�ź�ͬ�����
    wire upg_rst_synchronized;
    assign upg_rst_synchronized = upg_rst_sync2;
    ////////////////////////////////////
    
    // ����ģʽָʾ�ź�
    assign kick_off = ~spg_bufg;
    
    // �ڴ�ʱ��
    assign ram_clk = kick_off ? cpu_clk : upg_clk;
    
    //----------- UART���������ź� -----------
    uart_programmer uart(
        .upg_clk_i(upg_clk),        // UARTʱ������
        .upg_rst_i(upg_rst_synchronized),        // UART��λ�ź�
        .upg_rx_i(rx),              // UART��������
        .upg_clk_o(upg_clk_o),      // UARTʱ�����
        .upg_wen_o(upg_wen_o),      // UARTдʹ���ź�
        .upg_adr_o(upg_adr_o),      // UART��ַ�ź�
        .upg_dat_o(upg_dat_o),      // UART�����ź�
        .upg_done_o(upg_done_o),    // UART�������ź�
        .upg_tx_o(tx)               // UART�������
    );
    
    //----------- ����ͨ·����ź� -----------
    // ��֧�����ж�
    wire branch_condition;
    wire unsigned_less;             // �޷��űȽ�: rs1 < rs2 (�޷��űȽ�)
    
    // �޷��űȽ�alu_input1 < alu_input2
    assign unsigned_less = (alu_input1 < alu_input2);
    assign branch_condition = (funct3 == 3'h0) ? alu_zero :      // beq: ���
                             (funct3 == 3'h1) ? ~alu_zero :     // bne: �����
                             (funct3 == 3'h4) ? (alu_result[31]) : // blt: С��
                             (funct3 == 3'h5) ? (~alu_result[31]) : // bge: ���ڵ���
                             (funct3 == 3'h6) ? unsigned_less : // bltu: rs1 < rs2 (�޷��űȽ�)
                             (funct3 == 3'h7) ? ~unsigned_less : // bgeu: rs1 >= rs2 (�޷��űȽ�)
                             1'b0;  // Ĭ�ϲ���ת
    
    assign branch_taken = branch & branch_condition;
    
    // ָ���ȡ
    instruction_fetch ifetch(
        .clk(cpu_clk),                           // CPUʱ��
        .rst(rst),                               // ��λ�ź�
        .kick_off(kick_off),                     // ����ģʽ�ź�
        .branch_taken(branch_taken),             // ��֧��ת�ź�
        .jump(jump),                             // ��ת�ź�
        .imm(imm),                               // ������(����������)
        
        // UART����ź�
        .upg_clk(upg_clk),                       // UARTʱ��
        .upg_rst(upg_rst_synchronized),                       // UART��λ�ź�
        .upg_wen(upg_wen_o),                     // UARTдʹ���ź�
        .upg_adr(upg_adr_o),                     // UART��ַ
        .upg_dat(upg_dat_o),                     // UART����
        .upg_done(upg_done_o),                   // UART����ź�
        
        .pc(pc),                                 // ���������
        .pc_plus4(pc_plus4),                     // pc+4�ź�
        .instruction(instruction)                // ��ǰָ��
    );
    

    // ָ������ź�
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

    // ����������
    immediate_gen imm_gen (
        .instruction(instruction),
        .imm(imm)
    );

    // �Ĵ�����
    register_file reg_file (
        .clk(cpu_clk),              // ����CPUʱ�� 
        .rst(rst),
        .reg_write_en(kick_off & reg_write_en), // �Ĵ���дʹ��
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(r_wdata),  // д��mem_or_io������
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );


    // ALU����1ѡ��
    mux_alu_input umux_alu_input1 (
        .data0(reg_data1),
        .data1(pc),
        .sel(alu_src_1),
        .alu_input(alu_input1)
    );
    
    // ALU����2ѡ��
    mux_alu_input umux_alu_input2 (
        .data0(reg_data2),
        .data1(imm),
        .sel(alu_src_2),
        .alu_input(alu_input2)
    );
    
    // ALU - �������
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
    
    //----------- IO����ź� -----------
    // ֱ�ӽ�����ֵ����һ���м��źţ�����ֱ�����ӵ� mem_or_io �� io_rdata ����
    wire [31:0] switch_values_extended = {21'b0, switch[10:0]}; // ʹ������11λ���أ���λ����
    // LED�������߼����Ա�����
    always @(*) begin
        if(led_ctrl) begin
            led <= io_wdata[7:0];
        end
        else begin
            led <= 8'b0;
        end
    end
    
    // �ڴ��IO��ȡ
    mem_or_io io (
        .io_read_en(kick_off & io_read_en),     // �ڴ��IO��ʹ��
        .io_write_en(kick_off & io_write_en),   // �ڴ��IOдʹ��
        .mem_read_en(kick_off & mem_read_en),   // �ڴ��ʹ��
        .mem_write_en(kick_off & mem_write_en), // �ڴ�дʹ��
        .addr_in(alu_result),
        .addr_out(addr_out),             // �ڴ��ַ�ź�
        .m_rdata(mem_read_data),
        .io_rdata(switch_values_extended), // ֱ�Ӵ��ݿ���ֵ
        .r_wdata(r_wdata),              // �ڴ��IOд����
        .pc_plus4(pc_plus4),            // ����pc_plus4�ź�
        .imm(imm),  // ����immgen�ź�
        .wb_select(wb_select), //control unit���д��ѡ���ź�: 00:ALU???, 01:Mem/IO????, 10:PC+4, 11:Imm
        .r_rdata(reg_data2),
        .io_wdata(io_wdata),
        .m_wdata(mem_write_data),
        .led_ctrl(led_ctrl),
        .switch_ctrl(switch_ctrl),
        .seg_display_ctrl(seg_display_ctrl)
    );

    // �������ʾ����
    display_controller udisplay_controller(
        .clk(cpu_clk),
        .rst(rst),
        .led_display_ctrl(~kick_off | seg_display_ctrl),// ����kick_off�ź�,0��ʾ��������ģʽ,led��ʾ�����ź�
        .result1(io_wdata),
        .result2(io_wdata),
        .prog_mode(~kick_off),             // ����kick_off�ź�,0��ʾ��������ģʽ
        .prog_done(upg_done_o),           // ����UART����ź�
        .seg_en(seg_en),
        .seg_out(seg_out)
    );
    
    //----------- �ڴ�����ź� -----------
    // �ڴ��ȡ
    dmemory32 data_memory (
        .ram_clk_i(ram_clk),        // �ڴ�ʱ��
        .ram_wen_i(kick_off ? mem_write_en : upg_wen_o & upg_adr_o[14]), // �ڴ�дʹ��
        .ram_adr_i(kick_off ? alu_result[15:2] : upg_adr_o[13:0]),  // �ڴ��ַ
        .ram_dat_i(kick_off ? mem_write_data : upg_dat_o),  // �ڴ�д������
        .ram_dat_o(mem_read_data),  // �ڴ��������
        // UART����ź�
        .upg_rst_i(upg_rst_synchronized),        // UART��λ�ź�
        .upg_clk_i(upg_clk),        // UARTʱ��
        .upg_wen_i(upg_wen_o & upg_adr_o[14]), // UARTдʹ��
        .upg_adr_i(upg_adr_o[13:0]), // UART��ַ
        .upg_dat_i(upg_dat_o),      // UART����
        .upg_done_i(upg_done_o)     // UART����ź�
    );

    

endmodule





