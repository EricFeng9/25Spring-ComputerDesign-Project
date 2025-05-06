`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 写回多路复用器模块
// 用于选择写入寄存器的数据
//////////////////////////////////////////////////////////////////////////////////

module writeback_mux (
    input wire [31:0] r_wdata,    // 从mem_or_io得到的写回寄存器的data数据
    input wire [31:0] mem_data,   // 存储器数据
    input wire [0:0] mem_to_reg,  // 寄存器写回源选择
    output reg [31:0] write_data  // 写回数据
);
    always @(*) begin
       if(mem_to_reg == 1'b0) begin
           write_data = r_wdata;   // 选择从mem_or_io得到的数据
       end
       else begin
           write_data = mem_data;  // 选择从存储器读取的数据
       end
   end
endmodule
