`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ʱ�ӷ�Ƶ��ģ��
// ��100MHz������ʱ�ӽ�ƵΪ4MHz
// ��������ģ����ȫ��claude-3.7-sonnet����
//////////////////////////////////////////////////////////////////////////////////

module clk_100mhz_to_4mhz(
    input wire clk_in,     // ����ʱ�� 100MHz
    input wire rst,        // ��λ�ź�
    output reg clk_out     // ���ʱ�� 4MHz
);

    // 25��Ƶ (100MHz / 25 = 4MHz)
    // ��Ҫ������12Ȼ��תʱ��
    reg [4:0] counter;
    
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 5'b0;
            clk_out <= 1'b0;
        end else begin
            if (counter == 5'd12) begin
                counter <= 5'b0;
                clk_out <= ~clk_out;  // ��תʱ��
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule 