`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ����ģ����Դ��ļ�
// ��������ִ��ָ��ģʽ
//////////////////////////////////////////////////////////////////////////////////

module top_tb();
    // �����ź�
    reg clk;                  // ʱ���ź�
    reg rst;                  // ��λ�ź�
    reg [10:0] switch;        // ���������ź�
    reg start_pg;             // UART���ģʽ�����ź�
    reg rx;                   // UART��������
    
    // ����ź�
    wire [7:0] seg_en;        // �����ʹ���ź�
    wire [7:0] seg_out;       // ����ܶ�ѡ�ź�
    wire [7:0] led;           // LED����ź�
    wire tx;                  // UART��������
    
    // �ڲ������źţ����ڲ��ԣ�
    wire [31:0] pc_monitor;
    wire [31:0] instruction_monitor;
    wire [31:0] reg_data1;
    wire [31:0] reg_data2;
    wire [31:0] alu_input1;         // ALU����1
    wire [31:0] alu_input2;         // ALU����2
    wire [31:0] alu_src_1;
    wire [31:0] alu_src_2;
    wire [31:0] alu_result;
    wire [31:0] imm;                // ������
    wire [31:0] r_wdata;
    wire [31:0] mem_read_data;
    wire [31:0] mem_write_data;
    wire [31:0] io_wdata;
    wire [31:0] io_rdata;
    // �����ڲ��ź�
    assign pc_monitor = uut.pc;
    assign instruction_monitor = uut.instruction;
    assign reg_data1 = uut.reg_data1;
    assign reg_data2 = uut.reg_data2;
    assign alu_input1 = uut.alu_input1;
    assign alu_input2 = uut.alu_input2;
    assign alu_src_1 = uut.alu_src_1;
    assign alu_src_2 = uut.alu_src_2;
    assign alu_result = uut.alu_result;
    assign imm = uut.imm;
    assign r_wdata = uut.r_wdata;
    assign mem_read_data = uut.mem_read_data;
    assign mem_write_data = uut.mem_write_data;
    assign io_wdata = uut.io_wdata;
    assign io_rdata = uut.io_rdata;
    // ʵ��������ģ��
    top uut(
        .clk(clk),
        .rst(rst),
        .switch(switch),
        .seg_en(seg_en),
        .seg_out(seg_out),
        .led(led),
        .start_pg(start_pg),
        .rx(rx),
        .tx(tx)
    );
    
    
    
    // ʱ������
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHzʱ�� (����10ns)
    end
    
    // ��������
    initial begin
        // ��ʼ������
        rst = 1;
        switch = 11'b0;
        start_pg = 0;         // ȷ����������ִ��ģʽ (kick_off=1)
        
        // �ȴ�ʱ���ź��ȶ�
        #2000;  // ���Ӹ�λʱ������Ӧ2MHzʱ��
        rst = 0;
        
        #10000;  // ���Ӳ���ʱ������Ӧ2MHzʱ�ӣ���4MHz��һ����
        
        // ��������
        $display("�������");
        $finish;
    end

endmodule 