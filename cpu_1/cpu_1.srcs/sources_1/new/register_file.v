`timescale 1ns / 1ps

module register_file(
input clk,
input rst,
input reg_write_en,
input [4:0]read_reg1,
input [4:0]read_reg2,
input [4:0] write_reg,
input [31:0]write_data,
output [31:0]read_data1,
output [31:0]read_data2
    );
    //����vivado��true dual port RAM��ÿ���˿ڣ���һ������ֻ��ִ�ж���д����˴�ģ��ṹ���£�
    //������RAMʵ��
    //д��˿������ݵȽӵ�����RAM��д���
    //������RAM�ֱ��������1������2

//reset �ź��������������Ϊ�͵�ƽ�ģ���ֹx��������Ҳ����Ҫ����register����
//��֮ϣ���õ��ź�֮ǰ���ź��Ѿ��ȶ���


//����0����
wire [31:0] actual_write_data = (write_reg == 5'd0) ? 32'b0 : write_data;
wire actual_we = (write_reg == 5'd0) ? 1'b0 : reg_write_en;
wire rst0=1'b0;

register_file_dist r1(
    .clk(clk),
    .rst(rst0),
    .reg_write_en(write_reg),
    .read_reg1(read_reg1),
    .read_reg2(read_reg2),
    .write_reg(write_reg),
    .write_data(actual_write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);
endmodule
