`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//��������ģ����ȫ��claude-3.7-sonnet����
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

    // 32��32λ�Ĵ���
    reg [31:0] registers [0:31];
    
    // ������ - ����߼������ӳ�
    // ���⴦���дͬһ�Ĵ������������д��ͻ��д���ȣ�
    assign read_data1 = (reg_write_en && read_reg1 == write_reg && write_reg != 0) ? write_data : registers[read_reg1];
    assign read_data2 = (reg_write_en && read_reg2 == write_reg && write_reg != 0) ? write_data : registers[read_reg2];
    
    // ��ʼ���Ĵ���ֵΪ0
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end
    
    // д����
    always @(posedge clk) begin
        if (rst) begin
            registers[0] <= 32'b0; // ֻ���üĴ���0
        end else begin
            if (reg_write_en && write_reg != 5'd0) begin
                registers[write_reg] <= write_data;
            end
            registers[0] <= 32'b0; // ȷ���Ĵ���0ʼ��Ϊ0
        end
    end

endmodule
