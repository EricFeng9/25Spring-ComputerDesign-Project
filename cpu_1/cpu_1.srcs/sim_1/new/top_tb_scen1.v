`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/11 01:04:54
// Design Name: 
// Module Name: top_tb_scen1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb_scen1();
// �����źŶ���
    reg clk;                  // ϵͳʱ��
    reg rst;                  // ��λ�ź�
    reg [10:0] switch;        // ���������ź�
    reg start_pg;             // UART��̿�ʼ�ź�
    reg rx;                   // UART��������
    reg  led_en_button;
    // ����ź�
    wire [7:0] seg_en;        // �����ʹ���ź�
    wire [7:0] seg_out;       // ����ܶ�ѡ�ź�
    wire [7:0] led;           // LEDָʾ��
    wire tx;                  // UART��������
    
    // ����źţ����ڵ��Ժ͹۲죩
    wire cpu_clk;
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
    wire [31:0] switch_values_extended;
    wire [1:0] wb_select;
    wire [1:0] alu_op;
    wire [7:0] led_value;
    wire [7:0] led_ctrl;
    wire seg_display_ctrl;
    // ���Ӽ���ź�
    assign cpu_clk = uut.cpu_clk;
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
    assign switch_values_extended = uut.switch_values_extended;
    assign wb_select = uut.wb_select;
    assign alu_op = uut.alu_op;
    assign led_value =uut.led_value;
    assign led_ctrl =uut.led_ctrl;
    assign seg_display_ctrl = uut.seg_display_ctrl;
    // ʵ����������ģ��
    top uut(
        .clk(clk),
        .rst(rst),
        .switch(switch),
        .seg_en(seg_en),
        .seg_out(seg_out),
        .led(led),
        .start_pg(start_pg),
        .rx(rx),
        .tx(tx),
        .led_en_button(led_en_button)
    );
    
    
    
    // ʱ��������
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHzʱ�� (����10ns)
    end
    
    // ���Լ����ź�
    initial begin
        // ��ʼ�������ź�
        rst = 1;
        switch = 11'b0;
        start_pg = 0;         // ѡ������ִ��ģʽ (kick_off=1)
        led_en_button = 1'b0;
        
        // �ͷŸ�λ�źſ�ʼ
        #300;
        rst = 0;
        //main
        //��һ����������ִ��
        #250
        //�ڶ�������
        #250
        //������...
        #250
        #250
        //io_load_case
        //case1:
        //��ȡ����״̬
        switch = 11'b0000111_001;
        #250
        #250
        #250
        #250
        //��ȡ�������
        #250
        //���ݰ��������ת
        #250
        #250
        #250
        //��ת��case1
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        #250
        $finish;
        
        #10000; //250nsÿ��ָ�10000����40��ָ��
        
        // ��������
        $display("�������");
        $finish;
    end
endmodule
