`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ���ݴ洢����װģ��
// ���ڰ�װdata_mem_ram IP�˲����UART��̽ӿ�
//////////////////////////////////////////////////////////////////////////////////

module dmemory32(
    input wire ram_clk_i,         // �ڴ�ʱ��
    input wire ram_wen_i,         // дʹ��
    input wire [13:0] ram_adr_i,  // ��ַ����
    input wire [31:0] ram_dat_i,  // д������
    output wire [31:0] ram_dat_o, // ��������
    
    // UART��̽ӿ�
    input wire upg_rst_i,         // UART��̸�λ
    input wire upg_clk_i,         // UART���ʱ��
    input wire upg_wen_i,         // UART���дʹ��
    input wire [13:0] upg_adr_i,  // UART��̵�ַ
    input wire [31:0] upg_dat_i,  // UART�������
    input wire upg_done_i         // UART������
);

    // ʱ��ѡ��RAM����ʱ���ź�
    wire ram_clk = ram_clk_i;
    
    // ����ģʽ�жϣ�kickOff=1Ϊ����CPUģʽ��kickOff=0ΪUART���ģʽ
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    
    // �ڴ�дʹ��
    wire ram_we = kickOff ? ram_wen_i : upg_wen_i;
    
    // �ڴ��ַѡ��
    wire [13:0] ram_addr = kickOff ? ram_adr_i : upg_adr_i;
    
    // д������ѡ��
    wire [31:0] ram_data_in = kickOff ? ram_dat_i : upg_dat_i;
    
    // ʵ�������ݴ洢��IP��
    data_mem_ram data_ram(
        .clka(ram_clk),            // ʱ������
        .wea(ram_we),              // дʹ��
        .addra(ram_addr),          // ��ַ
        .dina(ram_data_in),        // д������
        .douta(ram_dat_o)          // ��������
    );

endmodule 