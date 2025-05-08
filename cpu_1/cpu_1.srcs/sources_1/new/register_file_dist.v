`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//声明：此模块完全由claude-3.7-sonnet生成
//////////////////////////////////////////////////////////////////////////////////


module register_file_dist(
    input wire clk,
    input wire rst,
    input wire reg_write_en,
    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,
    input wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    // 32个32位寄存器
    reg [31:0] registers [0:31];
    
    // 读操作 - 组合逻辑，无延迟
    // 特殊处理读写同一寄存器的情况（读写冲突的写优先）
    assign read_data1 = (reg_write_en && read_reg1 == write_reg && write_reg != 0) ? write_data : registers[read_reg1];
    assign read_data2 = (reg_write_en && read_reg2 == write_reg && write_reg != 0) ? write_data : registers[read_reg2];
    
    // 初始化寄存器值为0
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end
    
    // 写操作
    always @(posedge clk) begin
        if (rst) begin
            registers[0] <= 32'b0; // 只重置寄存器0
        end else begin
            if (reg_write_en && write_reg != 5'd0) begin
                registers[write_reg] <= write_data;
            end
            registers[0] <= 32'b0; // 确保寄存器0始终为0
        end
    end

endmodule
