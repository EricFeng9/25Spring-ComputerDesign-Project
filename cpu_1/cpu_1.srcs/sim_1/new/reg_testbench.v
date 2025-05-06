`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/03 11:10:16
// Design Name: 
// Module Name: reg_testbench
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


module reg_testbench(

    );
    // Inputs
    reg clk;
    reg rst;
    reg reg_write_en;
    reg [4:0] read_reg1;
    reg [4:0] read_reg2;
    reg [4:0] write_reg;
    reg [31:0] write_data;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    register_file uut (
        .clk(clk),
        .rst(rst),
        .reg_write_en(reg_write_en),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b1;
        rst = 1'b1;
        reg_write_en = 1'b0;
        write_data = 32'b0;
        write_reg = 5'b0;
        read_reg1 = 5'd5;
        read_reg2 = 5'd5;
        #20;
        //��ʼ��һ��
        rst=1'b0;
        reg_write_en = 1'b1;
        #20;
        //д��
        write_data = 32'h12345678;
        write_reg = 5'd5;
        #20;

        // ��ͬ����������������Ӧ��һ��

        // ����6ûд��Ӧ����0
        read_reg1 = 5'd5;
        read_reg2 = 5'd6;
        #20;
        
         // ��ͬ����������������Ӧ��һ��
        read_reg1 = 5'd5;
        read_reg2 = 5'd5;
        write_reg = 5'd5;
        //�����ܲ��ܸ��£�˳�����һ���ӳ�
        write_data = 32'hffffffff;
        #40;
        write_data = 32'h10086321;
        #40;
        write_data = 32'hafdafdaf;
        write_reg = 5'd5;
        #40;
        write_data = 32'h66666666;
        write_reg = 5'd5;
        #40;
        write_data = 32'h00114514;
        write_reg = 5'd5;
        #40;
        
        //��x0����
        read_reg1 = 5'd0;
        read_reg2 = 5'd0;
        write_data = 32'h12345678;
        write_reg = 5'd0;
        #60;
        
        //Ī��������ǲ�һ��write first
        write_data = 32'h87654321;
        write_reg = 5'd4;
        read_reg1 = 5'd4;
        read_reg2 = 5'd4;
        #40;
        
        read_reg1 = 5'd4;
        read_reg2 = 5'd4;
        #20;        
        //��ر�д���Ƿ���Ч
        reg_write_en = 1'b0;
        #20;
        write_data = 32'h12345678;
        write_reg = 5'd3;
        read_reg1 = 5'd3;
        read_reg2 = 5'd3;
        #40;
        //������
        rst=~rst;
        #20;
        rst=~rst;
        #20;
        // ��ͬ����������������Ӧ��һ��
        read_reg1 = 5'd5;
        read_reg2 = 5'd5;
        #20;
        //�����ܲ��ܸ���
        reg_write_en = 1'b1;
        write_data = 32'hffffffff;
        write_reg = 5'd5;
        #20;
        
        // ��ͬ����������������Ӧ��һ��
        read_reg1 = 5'd5;
        read_reg2 = 5'd5;
        #20;
        $finish;
    end
endmodule
