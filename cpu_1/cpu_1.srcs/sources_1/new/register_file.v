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
    //由于vivado的true dual port RAM的每个端口，在一周期内只能执行读或写，因此此模块结构如下：
    //有两个RAM实例
    //写入端口与数据等接到两个RAM的写入口
    //在两个RAM分别读出数据1和数据2

//reset 信号是用来把输出设为低电平的，防止x，并不会也不需要重置register内容
//总之希望拿到信号之前，信号已经稳定。


//防存0机制
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
