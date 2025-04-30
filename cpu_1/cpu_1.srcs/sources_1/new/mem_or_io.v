module mem_or_io(
    input wire io_read_en,          // IO���źţ�����Controller
    input wire io_write_en,         // IOд�źţ�����Controller
    input wire [31:0] addr_in,  // ��ַ���룬����ALU������
    output wire [31:0] addr_out, // ��ַ��������ӵ�Data mem
    input wire [31:0] m_rdata,  // ��Data mem��ȡ������
    input wire [15:0] io_rdata, // ��IO�豸��ȡ������(���뿪�ص�)
    output reg [31:0] r_wdata, // д��Ĵ���������
    input wire [31:0] r_rdata,  // �ӼĴ�����ȡ������
    output reg [31:0] io_wdata, // д��IO������
    output reg [31:0] m_wdata,   // д���ڴ������
    output reg [0:0] led_ctrl,         // LEDƬѡ�ź�
    output reg [0:0]switch_ctrl,       // ����Ƭѡ�ź�
    output reg [0:0]seg_display_ctrl, //7��������ʾ��Ƭѡ�ź�
    input wire [10:0] switch    //���������ź�
 );
    // IO�豸��ַ��Χ����
    parameter LED_BASE = 32'hFFFFC600;    // LED�ƿ��ƻ���ַ
    parameter SWITCH_BASE = 32'hFFFFC700; // ���ؿ��ƻ���ַ
    parameter SEG_DISPLAY_BASE = 32'hFFFFC700; // �߶�����ܻ���ַ

    always @(*) begin
        //��ɫ������
        if(io_read_en && addr_in == SWITCH_BASE)begin
            //io����״̬���ҵ�ַָ�򿪹أ���Ĵ������뿪�ص�ֵ(reg_write_enҪ��)
            r_wdata <= io_rdata;
            switch_ctrl<=1;
        end
        else begin
            //����Ĵ�������memory��ֵ��ǰ����reg_write_en\mem_read_enҲ�ô򿪣�
            r_wdata <= m_rdata;
        end
        
        //��ɫ������
        if(io_write_en && addr_in == LED_BASE)begin
            //ioд��״̬���ҵ�ַָ��LED
             io_wdata <= r_rdata;
             led_ctrl <= 1;
        end else if(io_write_en && addr_in == SEG_DISPLAY_BASE)begin
            //ioд��״̬���ҵ�ַָ�������
            io_wdata <= r_rdata;
            seg_display_ctrl <=1;
        end else begin
            //���򽫼Ĵ�����ֵд��memory��ǰ����mem_write_enҲ�ô򿪣�
            m_wdata <= r_rdata;
        end
        
        
    end
    
    //��ɫ������
    assign addr_in = addr_out;
    

endmodule    