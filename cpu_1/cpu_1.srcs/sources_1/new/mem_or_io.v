`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// �ڴ���IO�ӿڿ�����ģ��
// �����жϷ��ʵ����ڴ滹��IO�豸
//////////////////////////////////////////////////////////////////////////////////

module mem_or_io(
    input wire io_read_en,          // IO��ȡʹ���źţ�����Controller
    input wire io_write_en,         // IOд��ʹ���źţ�����Controller
    input wire mem_read_en,         // �ڴ��ȡʹ���źţ�����Controller
    input wire mem_write_en,        // �ڴ�д��ʹ���źţ�����Controller
    input wire [31:0] addr_in,      // ��ַ���룬����ALU������
    output wire [31:0] addr_out,    // ��ַ��������ӵ�Data mem
    input wire [31:0] m_rdata,      // ��Data mem��ȡ������
    input wire [31:0] io_rdata,     // ��IO�豸��ȡ������(��������)
    input wire [31:0] r_rdata,      // �ӼĴ�����ȡ������
    input wire [31:0] pc_plus4,     // PC+4 �ź�
    input wire [31:0] imm,          // ���������� (����immediate_gen)
    input wire [1:0] wb_select,     // ����control_unit��д������ѡ��,00:ALU���, 01:Mem/IO����, 10:PC+4, 11:Imm
    output reg [31:0] r_wdata,      // д��Ĵ���������
    output reg [31:0] io_wdata,     // д��IO������
    output reg [31:0] m_wdata,      // д���ڴ������
    output reg [0:0] led_ctrl,      // LED�����ź�
    output reg [0:0] switch_ctrl,   // ���ؿ����ź�
    output reg [0:0] seg_display_ctrl // 7������ܿ����ź�
 );
    // IO�豸�ĵ�ַ��Χ����
    parameter LED_BASE = 32'hFFFFC600;    // LED��������ַ
    parameter SWITCH_BASE = 32'hFFFFC700; // ���ؿ�������ַ
    parameter SEG_DISPLAY_BASE = 32'hFFFFC800; // ����ܿ�������ַ (�������ĵ���һ��)

    // ����ֱַ�Ӵ��ݸ��ڴ�ģ��
    assign addr_out = addr_in;
    
    // ����ַ�������ڴ滹��IO�豸
    wire is_io_addr = (addr_in == LED_BASE) || 
                      (addr_in == SWITCH_BASE) || 
                      (addr_in == SEG_DISPLAY_BASE);
    
    reg [31:0] data_from_mem_or_io_source;
    always @(*) begin
        // ��ʼ�����п����źź��������
        led_ctrl = 1'b0;
        switch_ctrl = 1'b0;
        seg_display_ctrl = 1'b0;
        io_wdata = 32'h0; // д��IO������
        m_wdata = 32'h0;  // д���ڴ������
        
        // r_wdata �߼�ʵ��mux�Ĺ���
        // 1. ��ȡ�ڴ�/IO������ (�ⲿ�����ݽ��� wb_select == 2'b01 ʱ�Żᱻʹ��)
       
        

        // 2. ���� wb_select ѡ����� r_wdata (д��Ĵ���������)
        case (wb_select)
            2'b00: r_wdata = addr_in;
            2'b01: r_wdata = (io_read_en && is_io_addr) ? io_rdata : 
                            (mem_read_en && !is_io_addr) ? m_rdata : 32'h0;
            2'b10: r_wdata = pc_plus4;
            2'b11: r_wdata = imm;
            default: r_wdata = 32'h0;
        endcase
        
        // 3. д���ڴ�/IO�Ĵ��� (��mem_write_en��io_write_en��Чʱ)
        if(io_write_en && is_io_addr) begin
            if(addr_in == LED_BASE) begin
                // IOд�������������д��LED
                io_wdata = r_rdata;
                led_ctrl = 1'b1;
            end
            else if(addr_in == SEG_DISPLAY_BASE) begin
                // IOд�������������д�������
                io_wdata = r_rdata;
                seg_display_ctrl = 1'b1;
            end
        end
        else if(mem_write_en && !is_io_addr) begin
            // �ڴ�д�������������д��memory
            m_wdata = r_rdata;
        end
    end
endmodule    