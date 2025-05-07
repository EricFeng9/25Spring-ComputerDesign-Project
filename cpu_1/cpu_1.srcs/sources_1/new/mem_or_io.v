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
    input wire [31:0] r_rdata,      // �ӼĴ�����ȡ������
    input wire [31:0] pc_plus4,  // PC+4 ��ֵ
    input wire [31:0] imm,        // ��������ֵ (����immediate_gen)
    input wire [1:0] wb_select,   // ����control_unit��д��ѡ���ź�,00:ALU���, 01:Mem/IO����, 10:PC+4, 11:Imm
    output reg [31:0] r_wdata,      // д��Ĵ���������
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
    
    reg [31:0] data_from_mem_or_io_source;
    always @(*) begin
        // ���ֶԿ����źź�д���ݵ��ڴ�/IO��Ĭ�ϳ�ʼ��
        led_ctrl = 1'b0;
        switch_ctrl = 1'b0;
        seg_display_ctrl = 1'b0;
        io_wdata = 32'h0; // д��IO������
        m_wdata = 32'h0;  // д���ڴ������
        //��ɫ������
        // r_wdata ���������mux�߼�����
        // 1. �����ڴ�/IO�Ķ����� (�ⲿ���߼����ڲ��� wb_select == 2'b01 ʱ������Դ)
       
        data_from_mem_or_io_source = 32'bx; // Default to X if no valid read

        if(io_read_en && is_io_addr) begin
            if(addr_in == SWITCH_BASE) begin
                // IO����״̬���ҵ�ַָ�򿪹أ�����뿪�ص�ֵ
                data_from_mem_or_io_source = io_rdata;
                switch_ctrl = 1'b1;
            end
        end
        else if(mem_read_en && !is_io_addr) begin
            // �ڴ��ȡ״̬������memory��ֵ
            data_from_mem_or_io_source = m_rdata;
        end

        // 2. ���� wb_select ѡ�����յ� r_wdata (д�ؼĴ���������)
        case (wb_select)
            2'b00: r_wdata = addr_in;                      // ALU result (addr_in ���� alu_result)
            2'b01: r_wdata = data_from_mem_or_io_source;   // Data from Memory or IO device
            2'b10: r_wdata = pc_plus4;                  // PC + 4
            2'b11: r_wdata = imm;                        // Immediate (for LUI)
            default: r_wdata = 32'bx;                      // Default ������˵��Ӧ�÷���
        endcase
        //��ɫ������
        // 3. �����ڴ�/IO��д���� (��mem_write_en��io_write_en����)
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