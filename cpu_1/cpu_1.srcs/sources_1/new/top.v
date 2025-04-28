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
    // �ڲ��ź�����
    // PC ����ź�
    reg [31:0] pc_current;     // ��ǰPCֵ
    reg [31:0] pc_next;        // ��һ��PCֵ
    wire [31:0] pc_plus4;       // PC+4
    wire [31:0] branch_target;  // ��֧/��תĿ���ַ
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
    wire alu_src;               // ALUԴѡ���ź�
    wire mem_to_reg;            // �洢�����Ĵ���ѡ���ź�
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

    // ָ��洢�� - �洢����ָ�� ������ip��
    instruction_memory inst_mem (
        .addr(pc_current),      // ��ַ����Ϊ��ǰPCֵ
        .instruction(instruction) // ���ָ��
    );

    // PC+4����
    assign pc_plus4 = pc_current + 4;
    
    // ��֧/��תĿ���ַ����
    assign branch_target = pc_current + imm;
    
    // ��֧�����ж�
    assign branch_taken = branch & alu_zero;

    // PC��·������ - ѡ����һ��PCֵ
    mux_pc pc_mux (
        .pc_plus4(pc_plus4),
        .branch_target(branch_target),
        .branch_taken(branch_taken),
        .jump(jump),
        .pc_next(pc_next)
    );
    
    // PC�Ĵ�������
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_current <= 32'h00000000; // ��λʱPC����
        end else begin
            pc_current <= pc_next;      // ����PC
        end
    end

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
    mux_alu_input alu_mux (
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
    mux_writeback wb_mux (
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .pc_plus4(pc_plus4),
        .imm(imm),
        .reg_src(reg_src),
        .write_data(reg_write_data)
    );

    // �����·������ - ѡ��CPU������
    mux_result result_mux (
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .pc_data(pc_current),
        .imm_data(imm),
        .result_src(result_src),
        .result(result)
    );
    
    // Ϊ�������ý��Դѡ���ź�
    assign result_src = 2'b00; // Ĭ��ѡ��ALU���

endmodule

// ָ��洢��ģ��
module instruction_memory (
    input wire [31:0] addr,         // ��ַ����
    output reg [31:0] instruction  // ָ�����
);
    // ָ��洢����ROM��
    reg [31:0] memory [0:1023];  // 4KBָ��洢��
    
    // ��ʼ��һЩʾ��ָ��
    initial begin
        // ������Լ���ָ��
        // ����: memory[0] = 32'h00500113; // addi x2, x0, 5
    end
    
    // ��ȡָ��
    always @(*) begin
        instruction = memory[addr[31:2]]; // ���֣�32λ��Ѱַ
    end
endmodule

// ���Ƶ�Ԫģ��
module control_unit (
    input wire [6:0] opcode,     // ������
    input wire [2:0] funct3,     // ������3
    input wire [6:0] funct7,     // ������7
    output reg [3:0] alu_op,     // ALU������
    output reg reg_write_en,     // �Ĵ���дʹ��
    output reg alu_src,          // ALUԴѡ��
    output reg mem_write_en,     // �洢��дʹ��
    output reg mem_read_en,      // �洢����ʹ��
    output reg mem_to_reg,       // �洢�����Ĵ���
    output reg branch,           // ��֧�ź�
    output reg jump,             // ��ת�ź�
    output reg [1:0] reg_src     // �Ĵ���Դѡ��
);
    // �����붨��
    parameter R_TYPE     = 7'b0110011;  // R��ָ��
    parameter I_TYPE_ALU = 7'b0010011;  // I��ALUָ��
    parameter I_TYPE_LOAD = 7'b0000011; // I�ͼ���ָ��
    parameter S_TYPE     = 7'b0100011;  // S�ʹ洢ָ��
    parameter B_TYPE     = 7'b1100011;  // B�ͷ�ָ֧��
    parameter J_TYPE     = 7'b1101111;  // J����תָ��
    parameter I_TYPE_JALR = 7'b1100111; // I�ͼ����ת
    parameter U_TYPE_LUI = 7'b0110111;  // U�ͼ�����������
    parameter U_TYPE_AUIPC = 7'b0010111; // U��PC��Լ���
    
    always @(*) begin
        // Ĭ�Ͽ����ź�
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
                alu_src = 0;      // ʹ�üĴ�����ΪALU�ڶ���������
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;   // ALU���д��Ĵ���
                branch = 0;
                jump = 0;
                reg_src = 2'b00;  // ѡ��ALU���
                
                // ����funct3��funct7����ALU����
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
                alu_src = 1;      // ʹ����������ΪALU�ڶ���������
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;   // ALU���д��Ĵ���
                branch = 0;
                jump = 0;
                reg_src = 2'b00;  // ѡ��ALU���
                
                // ����funct3����ALU����
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
                alu_src = 1;      // ʹ����������ΪALU�ڶ���������
                mem_write_en = 0;
                mem_read_en = 1;  // ��ȡ�洢��
                mem_to_reg = 1;   // �洢������д��Ĵ���
                branch = 0;
                jump = 0;
                reg_src = 2'b01;  // ѡ��洢������
                alu_op = 4'b0000; // ʹ�üӷ������ַ
            end
            
            S_TYPE: begin
                reg_write_en = 0;
                alu_src = 1;      // ʹ����������ΪALU�ڶ���������
                mem_write_en = 1; // д��洢��
                mem_read_en = 0;
                mem_to_reg = 0;   // ��ʹ��
                branch = 0;
                jump = 0;
                reg_src = 2'b00;  // ��ʹ��
                alu_op = 4'b0000; // ʹ�üӷ������ַ
            end
            
            B_TYPE: begin
                reg_write_en = 0;
                alu_src = 0;      // ʹ�üĴ�����ΪALU�ڶ���������
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;   // ��ʹ��
                branch = 1;       // ��ָ֧��
                jump = 0;
                reg_src = 2'b00;  // ��ʹ��
                
                // ����funct3���÷�֧����
                case (funct3)
                    3'b000: alu_op = 4'b0001; // BEQ (��ȱȽϣ�ʹ�ü���)
                    3'b001: alu_op = 4'b0001; // BNE (���ȱȽϣ�ʹ�ü���)
                    3'b100: alu_op = 4'b0011; // BLT (С�ڱȽ�)
                    3'b101: alu_op = 4'b0011; // BGE (���ڵ��ڱȽ�)
                    3'b110: alu_op = 4'b0100; // BLTU (�޷���С�ڱȽ�)
                    3'b111: alu_op = 4'b0100; // BGEU (�޷��Ŵ��ڵ��ڱȽ�)
                    default: alu_op = 4'b0000;
                endcase
            end
            
            J_TYPE: begin
                reg_write_en = 1;
                alu_src = 0;      // ��ʹ��ALU
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 1;         // ��תָ��
                reg_src = 2'b10;  // ѡ��PC+4
                alu_op = 4'b0000; // ��ʹ��ALU
            end
            
            I_TYPE_JALR: begin
                reg_write_en = 1;
                alu_src = 1;      // ʹ����������ΪALU�ڶ���������
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 1;         // ��תָ��
                reg_src = 2'b10;  // ѡ��PC+4
                alu_op = 4'b0000; // ʹ�üӷ������ַ
            end
            
            U_TYPE_LUI: begin
                reg_write_en = 1;
                alu_src = 1;      // ʹ��������
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                reg_src = 2'b11;  // ѡ��������
                alu_op = 4'b1111; // ֱͨ����
            end
            
            U_TYPE_AUIPC: begin
                reg_write_en = 1;
                alu_src = 1;      // ʹ��������
                mem_write_en = 0;
                mem_read_en = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                reg_src = 2'b00;  // ѡ��ALU���
                alu_op = 4'b0000; // �ӷ� (PC + imm)
            end
            
            default: begin
                // Ĭ�ϲ�����
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

// ������������ģ��
module immediate_gen (
    input wire [31:0] instruction,  // ָ��
    output reg [31:0] imm           // ���ɵ�������
);
    wire [6:0] opcode;
    assign opcode = instruction[6:0];
    
    always @(*) begin
        case (opcode)
            7'b0010011, 7'b0000011, 7'b1100111: // I��ָ��
                imm = {{20{instruction[31]}}, instruction[31:20]};
                
            7'b0100011: // S��ָ��
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                
            7'b1100011: // B��ָ��
                imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                
            7'b1101111: // J��ָ��
                imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                
            7'b0110111, 7'b0010111: // U��ָ��
                imm = {instruction[31:12], 12'b0};
                
            default:
                imm = 32'h00000000;
        endcase
    end
endmodule

// �Ĵ�����ģ��
module register_file (
    input wire clk,                 // ʱ��
    input wire rst,                 // ��λ
    input wire reg_write_en,        // �Ĵ���дʹ��
    input wire [4:0] read_reg1,     // ���Ĵ���1��ַ
    input wire [4:0] read_reg2,     // ���Ĵ���2��ַ
    input wire [4:0] write_reg,     // д�Ĵ�����ַ
    input wire [31:0] write_data,   // д������
    output wire [31:0] read_data1,  // ��������1
    output wire [31:0] read_data2   // ��������2
);
    // �Ĵ�����
    reg [31:0] registers [0:31];
    integer i;
    
    // ��ʼ���Ĵ���
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'h00000000;
        end
    end
    
    // ���Ĵ���
    assign read_data1 = (read_reg1 == 0) ? 32'h00000000 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'h00000000 : registers[read_reg2];
    
    // д�Ĵ���
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

// ALUģ��
module alu (
    input wire [31:0] a,           // ���������a
    input wire [31:0] b,           // ���������b
    input wire [3:0] alu_op,       // ALU������
    output reg [31:0] result,      // ������
    output wire zero               // ���־
);
    // ALU�����붨��
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
    
    // ���ݲ�����ִ�ж�Ӧ����
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
            ALU_PASS: result = b;  // ֱͨ����������LUI��ָ��
            default:  result = 32'h00000000;
        endcase
    end
    
    // �������־
    assign zero = (result == 32'h00000000);
endmodule

// ���ݴ洢��ģ��
module data_memory (
    input wire clk,                // ʱ��
    input wire [31:0] addr,        // ��ַ
    input wire [31:0] write_data,  // д������
    input wire write_en,           // дʹ��
    input wire read_en,            // ��ʹ��
    output reg [31:0] read_data    // ��������
);
    // ���ݴ洢��
    reg [31:0] memory [0:1023];  // 4KB���ݴ洢��
    
    // ������
    always @(*) begin
        if (read_en) begin
            read_data = memory[addr[31:2]];  // ���֣�32λ��Ѱַ
        end else begin
            read_data = 32'h00000000;
        end
    end
    
    // д����
    always @(posedge clk) begin
        if (write_en) begin
            memory[addr[31:2]] <= write_data;
        end
    end
endmodule

// д�ض�·������ģ��
module mux_writeback (
    input wire [31:0] alu_result,  // ALU���
    input wire [31:0] mem_data,    // �洢������
    input wire [31:0] pc_plus4,    // PC+4
    input wire [31:0] imm,         // ������
    input wire [1:0] reg_src,      // �Ĵ���Դѡ��
    output reg [31:0] write_data   // д������
);
    always @(*) begin
        case (reg_src)
            2'b00: write_data = alu_result;  // ALU���
            2'b01: write_data = mem_data;    // �洢������
            2'b10: write_data = pc_plus4;    // PC+4 (����JAL, JALR)
            2'b11: write_data = imm;         // ������ (����LUI)
        endcase
    end
endmodule

// �����·������ģ��
module mux_result (
    input wire [31:0] alu_result,  // ALU���
    input wire [31:0] mem_data,    // �洢������
    input wire [31:0] pc_data,     // PCֵ
    input wire [31:0] imm_data,    // ������
    input wire [1:0] result_src,   // ������ѡ��
    output reg [31:0] result       // ������
);
    always @(*) begin
        case (result_src)
            2'b00: result = alu_result;  // ѡ��ALU���
            2'b01: result = mem_data;    // ѡ��洢������
            2'b10: result = pc_data + imm_data; // ѡ��PC+������
            2'b11: result = imm_data;    // ѡ��������
        endcase
    end
endmodule
