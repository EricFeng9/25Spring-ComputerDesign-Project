`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ָ��洢��ģ��
// �ڲ�ʵ���� instruction_mem IP��, ��֧��UART��̸���ָ��
//////////////////////////////////////////////////////////////////////////////////

module imemory32(
    input wire clk,             // ϵͳʱ�� (��IP��ʹ��)
    input wire [13:0] rom_adr_i,      // ROM��ַ���� (����PC, CPU��������ʱʹ��)
    output wire [31:0] instruction_o, // ָ�����
    
    // UART��̽ӿ�
    input wire upg_rst_i,             // UART���ģʽ��λ�ź� (����Чͨ����ʾCPUģʽ, ����Ч����UART���ģʽ)
    input wire upg_clk_i,             // UART���ʱ��
    input wire upg_wen_i,             // UARTдʹ�� (���ڱ��ָ��洢��)
    input wire [13:0] upg_adr_i,      // UART��ַ���� (���ڱ��)
    input wire [31:0] upg_dat_i,      // UART�������� (���ڱ��)
    input wire upg_done_i             // UART�������ź�
);
    
    // ģʽѡ��: kickOff=1 ��ʾCPU��������ģʽ, kickOff=0 ��ʾUART���ģʽ
    // ��upg_rst_iΪ�� (CPUģʽ), �� upg_rst_iΪ����upg_done_iΪ�� (�����ɻָ�CPUģʽ) ʱ, kickOffΪ1
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    
    // ROMдʹ��: ����UART���ģʽ�� (kickOff=0) ��UARTдʹ����Чʱ, ��ʹ��IP�˵�д����
    wire rom_we = ~kickOff & upg_wen_i;
    
    // ROM��ַѡ��: CPUģʽ��ʹ��PC��ַ, UART���ģʽ��ʹ��UART�ṩ�ĵ�ַ
    wire [13:0] rom_addr = kickOff ? rom_adr_i : upg_adr_i;
    
    // ʵ����ָ��洢��IP�� (���� Xilinx �� Distributed Memory Generator)
    instruction_mem_dist instmem(
        .clk(clk),              // IP��ʱ������
        .we(rom_we),            // IP��дʹ������
        .a(rom_addr),           // IP�˵�ַ����
        .d(upg_dat_i),          // IP���������� (���ڱ��ʱд��)
        .spo(instruction_o)     // IP��������� (���˿�RAM�����)
    );

endmodule 