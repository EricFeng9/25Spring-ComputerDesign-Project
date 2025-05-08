`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ����洢����װģ��
// ���ڰ�װinstruction_mem IP�˲����UART��̽ӿ�
//////////////////////////////////////////////////////////////////////////////////

module imemory32(
    input wire clk,             // ָ���ڴ�ʱ��
    input wire [13:0] rom_adr_i,      // ָ���ַ���루pc���룩
    output wire [31:0] instruction_o, // ָ�����
    
    // UART��̽ӿ�
    input wire upg_rst_i,             // UART��̸�λ
    input wire upg_clk_i,             // UART���ʱ��
    input wire upg_wen_i,             // UART���дʹ��
    input wire [13:0] upg_adr_i,      // UART��̵�ַ
    input wire [31:0] upg_dat_i,      // UART�������
    input wire upg_done_i             // UART������
);
    
    // ����ģʽ�жϣ�kickOff=1Ϊ����CPUģʽ��kickOff=0ΪUART���ģʽ
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    
    // ROMдʹ�ܣ�ֻ�ڱ��ģʽ������д�룩
    wire rom_we = ~kickOff & upg_wen_i;
    
    // ָ���ַѡ��
    wire [13:0] rom_addr = kickOff ? rom_adr_i : upg_adr_i;
    
    // ʵ����ָ��洢��IP��
    instruction_mem_dist instmem(
        .clk(clk),              // ʱ������
        .we(rom_we),                // дʹ��
        .a(rom_addr),            // ��ַ
        .d(upg_dat_i),            // д�����ݣ����ڱ��ģʽʱ��Ч��
        .spo(instruction_o)        // ����ָ��
    );

endmodule 