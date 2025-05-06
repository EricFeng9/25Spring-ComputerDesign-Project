`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// �ڴ��IO��·����ģ��
// ���ݵ�ַ�ж��Ƿ����ڴ滹��IO�豸
//////////////////////////////////////////////////////////////////////////////////

module mem_or_io(
    input wire io_read_en,          // IO���źţ�����Controller
    input wire io_write_en,         // IOд�źţ�����Controller
    input wire mem_read_en,         // �ڴ���źţ�����Controller
    input wire mem_write_en,        // �ڴ�д�źţ�����Controller
    input wire [31:0] addr_in,      // ��ַ���룬����ALU������
    output wire [31:0] addr_out,    // ��ַ��������ӵ�Data mem
    input wire [31:0] m_rdata,      // ��Data mem��ȡ������
    input wire [31:0] io_rdata,     // ��IO�豸��ȡ������(���뿪�ص�)
    output reg [31:0] r_wdata,      // д��Ĵ���������
    input wire [31:0] r_rdata,      // �ӼĴ�����ȡ������
    output reg [31:0] io_wdata,     // д��IO������
    output reg [31:0] m_wdata,      // д���ڴ������
    output reg [0:0] led_ctrl,      // LEDƬѡ�ź�
    output reg [0:0] switch_ctrl,   // ����Ƭѡ�ź�
    output reg [0:0] seg_display_ctrl // 7��������ʾ��Ƭѡ�ź�
 );
    // IO�豸��ַ��Χ����
    parameter LED_BASE = 32'hFFFFC600;    // LED�ƿ��ƻ���ַ
    parameter SWITCH_BASE = 32'hFFFFC700; // ���ؿ��ƻ���ַ
    parameter SEG_DISPLAY_BASE = 32'hFFFFC700; // �߶�����ܻ���ַ

    // ��ֱַ�Ӵ��ݸ������ڴ�
    assign addr_out = addr_in;
    
    // ���ݵ�ַ�ж��Ƿ����ڴ滹��IO�豸
    wire is_io_addr = (addr_in == LED_BASE) || 
                      (addr_in == SWITCH_BASE) || 
                      (addr_in == SEG_DISPLAY_BASE);

    always @(*) begin
        // ��ʼ�����п����źź�����
        led_ctrl = 1'b0;
        switch_ctrl = 1'b0;
        seg_display_ctrl = 1'b0;
        io_wdata = 32'h0;
        m_wdata = 32'h0;
        r_wdata = 32'h0;
        
        // ��ȡ����·�� (��mem_read_en��io_read_en����)
        if(io_read_en && is_io_addr) begin
            if(addr_in == SWITCH_BASE) begin
                // IO����״̬���ҵ�ַָ�򿪹أ���Ĵ������뿪�ص�ֵ
                r_wdata = io_rdata;
                switch_ctrl = 1'b1;
            end
        end
        else if(mem_read_en && !is_io_addr) begin
            // �ڴ��ȡ״̬���Ĵ�������memory��ֵ
            r_wdata = m_rdata;
        end
        
        // д������·�� (��mem_write_en��io_write_en����)
        if(io_write_en && is_io_addr) begin
            if(addr_in == LED_BASE) begin
                // IOд��״̬���ҵ�ַָ��LED
                io_wdata = r_rdata;
                led_ctrl = 1'b1;
            end 
            else if(addr_in == SEG_DISPLAY_BASE) begin
                // IOд��״̬���ҵ�ַָ�������
                io_wdata = r_rdata;
                seg_display_ctrl = 1'b1;
            end
        end 
        else if(mem_write_en && !is_io_addr) begin
            // �ڴ�д��״̬�����Ĵ�����ֵд��memory
            m_wdata = r_rdata;
        end
    end
endmodule    