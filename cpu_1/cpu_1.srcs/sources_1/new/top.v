`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ������CPU����ģ��
// ����RISCָ��ܹ�
// ��������������ͨ·�Ϳ��Ƶ�Ԫ
// �����UARTͨ��ģʽ��ִ��ģʽ���л�����
//////////////////////////////////////////////////////////////////////////////////

module top(
    input wire clk,              // ʱ���ź�
    input wire rst,              // ��λ�ź� active high
    input wire [10:0]switch,     // ���������ź�,[10:3]��SW7...SW0��ֵ,[2:0]��X1��X2��X3��ֵ     
    output wire [7:0] seg_en,     // �����ʹ���ź�
    output wire [7:0] seg_out,    // ����ܶ�ѡ�ź�(gfedcba)
    output reg [7:0] led,        // ����led�Ƶ��ź�
    
    //UART ͨ��
    input start_pg,              // active high
    input rx,                    // receive data by UART ����lab12 ppt 10ҳ�Ĵ�������
    output tx                    // send data by UART ����lab12 ppt 10ҳ�Ĵ�������
);

    //----------- UART���������ź� -----------
    // ģʽ�����ź�
    wire spg_bufg;                  // ȥ�������start_pg�ź�
    reg upg_rst;                    // UART�������λ�ź�
    wire kick_off;                   // CPU����ģʽѡ���ź�: 1=����ģʽ, 0=UARTͨ��ģʽ
    
    // UART���������ź�
    wire upg_clk_o;                 // UART�����ʱ�����
    wire upg_wen_o;                 // UARTдʹ�����
    wire upg_done_o;                // UART�������ź�
    wire [14:0] upg_adr_o;          // UART��ַ���
    wire [31:0] upg_dat_o;          // UART�������
    
    // ʱ�����
    wire cpu_clk;                   // CPU����ʱ�� 100MHz
    wire ram_clk;                   // �ڴ�ʱ��
    wire upg_clk;                   // UART�����ʱ�� 10MHz
    
    //----------- �ڲ��ź� -----------
    // IFetch ����ź�
    wire [31:0] pc;                 // ���������
    wire branch_taken;              // ��֧��������
    
    // ָ������ź�
    wire [31:0] instruction;        // ��ǰָ��
    wire [6:0] opcode;              // ������ [6-0]
    wire [4:0] rd;                  // Ŀ��Ĵ��� [11-7]
    wire [2:0] funct3;              // ������3 [14-12]
    wire [4:0] rs1;                 // Դ�Ĵ���1 [19-15]
    wire [4:0] rs2;                 // Դ�Ĵ���2 [24-20]
    wire [6:0] funct7;              // ������7 [31-25]
    wire [31:0] imm;                // ������
    wire [31:0] mem_write_data;     // д��memory���м��ź�
    
    // �Ĵ�������ź�
    wire [31:0] reg_data1;          // �Ĵ���������1
    wire [31:0] reg_data2;          // �Ĵ���������2
    wire reg_write_en;              // �Ĵ���дʹ��
   
    // ALU����ź�
    wire [31:0] alu_input1;         // ALU����1
    wire [31:0] alu_input2;         // ALU����2
    wire [31:0] alu_result;         // ALU��� -�ӵ�MemOrIO
    wire [1:0] alu_op;              // ALU������ 5.3�Ķ�-Ӧ��Ϊ2λ
    wire alu_zero;                  // ALU���־
    
    // IO ����ź�
    wire io_read_en;                // IO���źţ�����Controller
    wire io_write_en;               // IOд�źţ�����Controller
    wire [31:0] addr_out;           // ��ַ��������ӵ�Data mem
    reg [31:0] io_rdata;            // ��IO�豸��ȡ������(���뿪�ص�)
    wire [31:0] r_wdata;            // ��mem or io�ж�ȡ����д���Ĵ���������
    wire [31:0] io_wdata;           // д��IO������
    wire led_ctrl;                  // LED�����ź�
    wire switch_ctrl;               // ���ؿ����ź�
    wire seg_display_ctrl;          // ����ܿ����ź�
    
    // �����ڴ�����ź�
    wire [31:0] mem_read_data;      // �洢��������
    wire mem_write_en;              // �洢��дʹ��
    wire mem_read_en;               // �洢����ʹ��

    // �����ź�
    wire alu_src;                   // ALUԴѡ���ź�
    wire branch;                    // ��֧�ź�
    wire jump;                      // ��ת�ź�
    wire [1:0] reg_src;             // �Ĵ���Դѡ���ź�
    wire [1:0] result_src;          // ������ѡ���ź�
    
    //----------- ʱ������ -----------
    // ʵ����ʱ��ģ�飬��100MHzת��Ϊ10MHz UARTʱ��
    clk_100mhz_to_10mhz clock_gen(
        .clk_in1(clk),              // ����ʱ�� 100MHz
        .clk_out1(upg_clk),         // ���UARTʱ�� 10MHz
        .clk_out2(cpu_clk)          // ���CPUʱ�� ����100MHz
    );
    
    //----------- UART����������߼� -----------
    // ��ťȥ��������
    BUFG U1(.I(start_pg), .O(spg_bufg)); // ȥ����
    
    // ����UART�������λ�ź�
    always @(posedge cpu_clk) begin
        if (spg_bufg) begin
            upg_rst <= 0;           // UART���ģʽ�£���λUART�����
        end
        else begin
            upg_rst <= 1;           // ��UART���ģʽ��UART�������λ
        end
    end
    
    // ����ģʽ�л���kick_off=1Ϊ��������ģʽ��kick_off=0ΪUARTͨ��ģʽ
    // ֱ���ɿ���״̬����
    assign kick_off = ~spg_bufg;
    
    // ����RAMʱ�� (���ݵ�ǰģʽѡ��ͬʱ��Դ)
    assign ram_clk = kick_off ? cpu_clk : upg_clk;
    
    //----------- UART���ģ�� -----------
    uart_programmer uart(
        .upg_clk_i(upg_clk),        // UARTʱ������
        .upg_rst_i(upg_rst),        // UART��λ�ź�
        .upg_rx_i(rx),              // UART��������
        .upg_clk_o(upg_clk_o),      // UARTʱ�����
        .upg_wen_o(upg_wen_o),      // UARTдʹ��
        .upg_adr_o(upg_adr_o),      // UART��ַ
        .upg_dat_o(upg_dat_o),      // UART����
        .upg_done_o(upg_done_o),    // UART�������ź�
        .upg_tx_o(tx)               // UART��������
    );
    
    //----------- ָ���ȡ�ͳ����ڴ� -----------
    // �ж��Ƿ��֧/��ת
    assign branch_taken = branch & alu_zero;
    
    // ʹ��instruction_fetchģ��
    instruction_fetch ifetch(
        .clk(cpu_clk),                           // CPUʱ��
        .rst(rst),                               // ��λ�ź�
        .kick_off(kick_off),                     // ����ģʽѡ��
        .branch_taken(branch_taken),             // ��֧��������
        .jump(jump),                             // ��תָ��
        .imm(imm),                               // ������(���ڼ�����ת��ַ)
        
        // UART������ӿ�
        .upg_clk(upg_clk),                       // UART���ʱ��
        .upg_rst(upg_rst),                       // UART��̸�λ
        .upg_wen(upg_wen_o),                     // UARTдʹ��
        .upg_adr(upg_adr_o),                     // UART��ַ
        .upg_dat(upg_dat_o),                     // UART����
        .upg_done(upg_done_o),                   // UART������
        
        .pc(pc),                                 // ������������
        .instruction(instruction)                // ��ǰָ�����
    );
    
    // ���Ƶ�Ԫ - ����ָ����ɿ����ź�
    // ����ָ���ֶ�
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[31:25];
    
    // ���Ƶ�Ԫ - ���ɸ��ֿ����ź�
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

    // ������������ - ����ָ����������������
    immediate_gen imm_gen (
        .instruction(instruction),
        .imm(imm)
    );

    // �Ĵ����� - ����Ĵ�����д����
    register_file reg_file (
        .clk(cpu_clk),              // ʹ��CPUʱ��
        .rst(rst),
        .reg_write_en(kick_off & reg_write_en), // ֻ������ģʽ��д��Ĵ���
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(r_wdata),  // д������ֱ�Ӵ�mem_or_ioģ���ȡ
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    // ALU����1ѡ��
    assign alu_input1 = reg_data1;
 
    // ALU����2��·������ - ѡ��ALU�ڶ�������
    mux_alu_input umux_alu_input (
        .reg_data(reg_data2),
        .imm_data(imm),
        .sel(alu_src),
        .alu_input(alu_input2)
    );
    //5.3�Ķ�����Ҫ����func3��ָ�����ʮλ
    // ALU - ִ�������߼�����
    alu alu_unit (
        .a(alu_input1),
        .b(alu_input2),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(alu_zero),
        .funct3(funct3),
        .inst_30(instruction[30])
    );
    
    //----------- IO���� -----------
    // IO�����ݴ���
    always @(*) begin
        if(switch_ctrl) begin
            io_rdata <= switch[10:3];    // ��ȡ����״̬
        end
        else begin
            io_rdata <= 32'bZ;          // ����ֵΪ����̬
        end
        
        // LED�������
        if(led_ctrl) begin
            led <= io_wdata[7:0];       // ������д��LED
        end
        else begin
            led <= 8'b0;                // Ĭ��LEDȫ��
        end
    end
    
    // �ڴ��IO�ӿ�ģ��
    mem_or_io io (
        .io_read_en(kick_off & io_read_en),     // ֻ������ģʽ�¶�ȡIO
        .io_write_en(kick_off & io_write_en),   // ֻ������ģʽ��д��IO
        .mem_read_en(kick_off & mem_read_en),   // ֻ������ģʽ�¶�ȡ�ڴ�
        .mem_write_en(kick_off & mem_write_en), // ֻ������ģʽ��д���ڴ�
        .addr_in(alu_result),
        .addr_out(addr_out),             // ����������ڴ�ĵ�ַ
        .m_rdata(mem_read_data),
        .io_rdata(io_rdata),
        .r_wdata(r_wdata),              // ֱ�Ӳ���Ҫд�ؼĴ���������
        .r_rdata(reg_data2),
        .io_wdata(io_wdata),
        .m_wdata(mem_write_data),
        .led_ctrl(led_ctrl),
        .switch_ctrl(switch_ctrl),
        .seg_display_ctrl(seg_display_ctrl)
    );

    // �������ʾ������
    display_controller udisplay_controller(
        .clk(cpu_clk),
        .rst(rst),
        .led_display_ctrl(~kick_off | seg_display_ctrl),// ��kick_offΪ0ʱ�����ڱ��ģʽ,led��Ҳ������ʾ���������Ƭѡ�ź���ʾ
        .result1(io_wdata),
        .result2(io_wdata),
        .prog_mode(~kick_off),             // ��kick_offΪ0ʱ�����ڱ��ģʽ
        .prog_done(upg_done_o),           // �����ɱ�־
        .seg_en(seg_en),
        .seg_out(seg_out)
    );
    
    //----------- �����ڴ沿�� -----------
    // �����ڴ棨֧��UART��̣�
    dmemory32 data_memory (
        .ram_clk_i(ram_clk),        // �ڴ�ʱ�ӣ�����ģʽѡ��
        .ram_wen_i(kick_off ? mem_write_en : upg_wen_o & upg_adr_o[14]), // дʹ�ܣ����ﵱ upg_adr_o[14] Ϊ 1 ʱ���Ż����ö������ڴ��д��
        .ram_adr_i(kick_off ? alu_result[15:2] : upg_adr_o[13:0]),  // ��ַ����
        .ram_dat_i(kick_off ? mem_write_data : upg_dat_o),  // д������
        .ram_dat_o(mem_read_data),  // ��������
        // UART������ӿ�
        .upg_rst_i(upg_rst),        // UART��λ
        .upg_clk_i(upg_clk),        // UARTʱ��
        .upg_wen_i(upg_wen_o & upg_adr_o[14]), // UARTдʹ�ܣ���������ڴ棩��ֻ�е� upg_adr_o[14] Ϊ 1 ʱ��UART�������дʹ���źŲŻᴫ�ݸ������ڴ档
        .upg_adr_i(upg_adr_o[13:0]), // UART��ַ
        .upg_dat_i(upg_dat_o),      // UART����
        .upg_done_i(upg_done_o)     // UART����ź�
    );

    

endmodule





