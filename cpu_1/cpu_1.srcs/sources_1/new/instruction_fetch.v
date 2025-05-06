`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ָ���ȡģ��
// ����PC���º�ָ��洢�����ʣ�֧��UART��̹���
//////////////////////////////////////////////////////////////////////////////////

module instruction_fetch(
    input wire clk,                  // CPUʱ��
    input wire rst,                  // ��λ�ź�
    input wire kick_off,             // ����ģʽ: 1=����ģʽ, 0=���ģʽ
    input wire branch_taken,         // ��֧���������ź�
    input wire jump,                 // ��תָ���ź�
    input wire [31:0] imm,           // ������(���ڼ�����ת��ַ)
    
    // UART������ӿ�
    input wire upg_clk,              // UART���ʱ��
    input wire upg_rst,              // UART��̸�λ
    input wire upg_wen,              // UARTдʹ��
    input wire [14:0] upg_adr,       // UART��ַ
    input wire [31:0] upg_dat,       // UART����
    input wire upg_done,             // UART������
    
    output reg [31:0] pc,            // ���������
    output wire [31:0] instruction   // ��ǰָ��
);
    
    // PC�����߼�
    wire [31:0] pc_plus4;            // PC+4
    wire [31:0] pc_branch;           // ��֧Ŀ���ַ
    wire [31:0] pc_next;             // ��һ��PCֵ
    
    // ���㱸ѡPCֵ
    assign pc_plus4 = pc + 4;                // ˳��ִ��
    assign pc_branch = pc + imm;             // ��֧/��תĿ��
    
    // ѡ����һ��PCֵ
    assign pc_next = (branch_taken || jump) ? pc_branch : pc_plus4;
    
    // ����PC
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'h0;            // ��λʱPC����
        end 
        else if (kick_off) begin    // ֻ������ģʽ�¸���PC
            pc <= pc_next;          // ����PCΪpc_next��ֵ
        end
    end
    
    // ָ��洢��ʵ����
    imemory32 instruction_memory(
        .rom_clk_i(kick_off ? clk : upg_clk),      // ʱ�����루����ģʽѡ��
        .rom_adr_i(kick_off ? pc[15:2] : upg_adr[13:0]),   // ��ַ���루����ģʽѡ��
        .Instruction_o(instruction),                   // ָ�����
        // UART������ӿ�
        .upg_rst_i(upg_rst),                           // UART��λ
        .upg_clk_i(upg_clk),                           // UARTʱ��
        .upg_wen_i(kick_off ? 1'b0 : upg_wen & ~upg_adr[14]),  // UARTдʹ�ܣ���Գ���洢����
        .upg_adr_i(upg_adr[13:0]),                   // UART��ַ
        .upg_dat_i(upg_dat),                         // UART����
        .upg_done_i(upg_done)                        // UART����ź�
    );

endmodule
