`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ������CPU����ģ��
// ����RISCָ��ܹ�
// ��������������ͨ·�Ϳ��Ƶ�Ԫ
//////////////////////////////////////////////////////////////////////////////////

module top(
    input wire clk,             // ʱ���ź�
    input wire rst,             // ��λ�ź�
    output wire [31:0] result   // CPUִ�н�����
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

    // �Ĵ�������ź�
    wire [31:0] reg_data1;      // �Ĵ���������1
    wire [31:0] reg_data2;      // �Ĵ���������2
    wire [31:0] reg_write_data; // �Ĵ���д����
    wire reg_write_en;          // �Ĵ���дʹ��

    // ALU����ź�
    wire [31:0] alu_input1;     // ALU����1
    wire [31:0] alu_input2;     // ALU����2
    wire [31:0] alu_result;     // ALU���
    wire [3:0] alu_op;          // ALU������
    wire alu_zero;              // ALU���־

    // ���ݴ洢������ź�
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
    always @(*) begin
        if (rst) begin
            pc <= 32'h0;  // ��λʱPC����
        end else begin
            pc <= pc_next; // ÿ��ʱ�����ڸ���PCΪpc_next��ֵ
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

    // ALU - ִ�������߼�����
    alu alu_unit (
        .a(alu_input1),
        .b(alu_input2),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(alu_zero)
    );

    // ���ݴ洢�� - �������ݶ�д IP�� 
    data_memory data_mem (
        .clk(clk),
        .addr(alu_result),
        .write_data(reg_data2),
        .write_en(mem_write_en),
        .read_en(mem_read_en),
        .read_data(mem_read_data)
    );

    // д�ض�·������ - ѡ��д��Ĵ���������
    assign pc_plus4 = pc + 4;
    writeback_mux uwriteback_mux (
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .mem_to_reg(mem_to_reg),
        .write_data(reg_write_data)
    );

    // �����·������ - ѡ��CPU������
    result_mux uresult_mux(
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .pc_data(pc),
        .imm_data(imm),
        .result_src(result_src),
        .result(result)
    );
    
    // Ϊ�������ý��Դѡ���ź�
    assign result_src = 2'b00; // Ĭ��ѡ��ALU���

endmodule





