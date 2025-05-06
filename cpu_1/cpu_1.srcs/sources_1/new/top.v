`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ������CPU����ģ��
// ����RISCָ��ܹ�
// ��������������ͨ·�Ϳ��Ƶ�Ԫ
//////////////////////////////////////////////////////////////////////////////////

module top(
    input wire clk,             // ʱ���ź�
    input wire rst,              // ��λ�ź�
    input wire [10:0]switch,     //���������ź�,[10:3]��SW7...SW0��ֵ,[2:0]��X1��X2��X3��ֵ     
    output reg [7:0] seg_en,         // �����ʹ���ź�
    output reg [7:0] seg_out,         // ����ܶ�ѡ�ź�(gfedcba)
    output reg [7:0] led    //����led�Ƶ��ź�
);

    
    //�ڲ��ź�------
    // IFetch ����ź�
    reg [31:0] pc; //pc
    wire [31:0] pc_plus4;
    wire branch_taken;          // ��֧��������
    
    // ָ������ź�
    wire [31:0] instruction;    // ��ǰָ��
    wire [6:0] opcode;          // ������ [6-0]
    wire [4:0] rd;              // Ŀ��Ĵ��� [11-7]
    wire [2:0] funct3;          // ������3 [14-12]
    wire [4:0] rs1;             // Դ�Ĵ���1 [19-15]
    wire [4:0] rs2;             // Դ�Ĵ���2 [24-20]
    wire [6:0] funct7;          // ������7 [31-25]
    wire [31:0] imm;            // ������
    wire [31:0] mem_write_data; //д��memory ���м��ź�
    
    // �Ĵ�������ź�
    wire [31:0] reg_data1;      // �Ĵ���������1
    wire [31:0] reg_data2;      // �Ĵ���������2
    wire [31:0] reg_write_data; // �Ĵ���д����
    wire reg_write_en;          // �Ĵ���дʹ��
   
    //5.3�Ķ���alu_opӦΪ��λ
    // ALU����ź�
    wire [31:0] alu_input1;     // ALU����1
    wire [31:0] alu_input2;     // ALU����2
    wire [31:0] alu_result;     // ALU��� -�ӵ�MemOrIO
    wire [1:0] alu_op;          // ALU������
    wire alu_zero;              // ALU���־
    
    // io ����ź�
    wire m_read_en;           // �ڴ���źţ�����Controller
    wire m_write_en;          // �ڴ�д�źţ�����Controller
    wire io_read_en;          // IO���źţ�����Controller
    wire io_write_en;         // IOд�źţ�����Controller
    wire [31:0] addr_out;  // ��ַ��������ӵ�Data mem
    reg [31:0] io_rdata;// ��IO�豸��ȡ������(���뿪�ص�)
    wire [31:0] r_wdata;//��mem or io�ж�ȡ����д���Ĵ���������
    wire [31:0] io_wdata;
    wire led_ctrl;
    wire switch_ctrl;
    wire seg_display_ctrl;
    
    // data memmory����ź�
    wire [31:0] mem_read_data;  // �洢��������
    wire mem_write_en;          // �洢��дʹ��
    wire mem_read_en;           // �洢����ʹ��

    // �����ź�
    wire [0:0]alu_src;               // ALUԴѡ���ź�
    wire [0:0]mem_to_reg;            // �洢�����Ĵ���ѡ���ź�
    wire branch;                // ��֧�ź�
    wire jump;                  // ��ת�ź�
    wire [1:0] reg_src;         // �Ĵ���Դѡ���ź�
    wire [1:0] result_src;      // ������ѡ���ź�

    // ���Ƶ�Ԫ - ����ָ����ɿ����ź�
    // ����ָ���ֶ�
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[31:25];
    
    wire [31:0] pc_next;
    //ָ���ȡģ�� i_fetch
    instruction_fetch i_fetch (
        .clk(clk),
        .branch_taken(branch_taken),
        .rst(rst),
        .imm32(imm),
        .pc(pc),
        .instruction(instruction),
        .pc_next(pc_next)  // ����pc_next���
    );
    // ����pc
    always @(negedge clk) begin
        if (rst) begin
            pc <= 32'h0;  // ��λʱPC����
        end else begin
            pc <= pc_next; // ÿ��ʱ�������½��ظ���PCΪpc_next��ֵ
        end
    end
    
    // ��֧�����ж�
    assign branch_taken = branch & alu_zero;

    // ���Ƶ�Ԫ - ���ɸ��ֿ����ź�
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

    // ������������ - ����ָ����������������
    immediate_gen imm_gen (
        .instruction(instruction),
        .imm(imm)
    );

    // �Ĵ����� - ����Ĵ�����д����
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

    // ALU����1ѡ��
    assign alu_input1 = reg_data1;
 
    // ALU����2��·������ - ѡ��ALU�ڶ�������
    alu_input2_mux ualu_input2_mux (
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
    
    //IO����
//    module mem_or_io(
//        input wire io_read_en,          // IO���źţ�����Controller
//        input wire io_write_en,         // IOд�źţ�����Controller
//        input wire [31:0] addr_in,  // ��ַ���룬����ALU������
//        output wire [31:0] addr_out, // ��ַ��������ӵ�Data mem
//        input wire [31:0] m_rdata,  // ��Data mem��ȡ������
//        input wire [15:0] io_rdata, // ��IO�豸��ȡ������(���뿪�ص�)
//        output wire [31:0] r_wdata, // д��Ĵ���������
//        input wire [31:0] r_rdata,  // �ӼĴ�����ȡ������
//        output reg [31:0] io_wdata, // д��IO������
//        output reg [31:0] m_wdata,   // д���ڴ������
//        output reg [0:0] led_ctrl,         // LEDƬѡ�ź�
//        output reg [0:0]switch_ctrl,       // ����Ƭѡ�ź�
//        output reg [0:0]seg_display_ctrl //7��������ʾ��Ƭѡ�ź�
//        input wire [10:0] switch    //���������ź�
//    );
    always @(*) begin
        if(switch_ctrl) begin
            io_rdata <= switch[10:3];
        end
        else begin
            io_rdata <= 32'bZ; //����ֵΪ����̬
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
//        input wire rst,                  // �ߵ�ƽ��Ч�ĸ�λ�ź�
//        input wire led_display_ctrl,
//        input wire [31:0] result1,       // 32λ����ź�1
//        input wire [31:0] result2,       // 32λ����ź�2
//        output reg [7:0] seg_en,         // �����ʹ���ź�
//        output reg [7:0] seg_out         // ����ܶ�ѡ�ź�(gfedcba)
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
    
    
    //data memory����
    data_memory data_mem (
        .clk(clk),
        .addr(addr_out),
        .write_data(mem_write_data),
        .write_en(mem_write_en),
        .read_en(mem_read_en),
        .read_data(mem_read_data)
    );

    // д�ض�·������ - ѡ��д��Ĵ���������
    assign pc_plus4 = pc + 4;
    writeback_mux uwriteback_mux (
        .r_wdata(r_wdata),
        .mem_data(mem_read_data),
        .mem_to_reg(mem_to_reg),
        .write_data(reg_write_data)
    );

//    // �����·������ - ѡ��CPU������
//    result_mux uresult_mux(
//        .alu_result(alu_result),
//        .mem_data(mem_read_data),
//        .pc_data(pc),
//        .imm_data(imm),
//        .result_src(result_src),
//        .result(result)
//    );
    

endmodule





