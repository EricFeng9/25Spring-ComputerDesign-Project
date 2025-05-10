`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ʱ�ӷ�Ƶģ��
// ��100MHz������ʱ�ӽ�ƵΪ2MHz
// ��������ģ����ȫ��claude-3.7-sonnet����
//////////////////////////////////////////////////////////////////////////////////

module clk_100mhz_to_2mhz(
    input wire clk_in,     // ����ʱ�� 100MHz
    input wire rst,        // ��λ�ź�
    output reg clk_out     // ���ʱ�� 2MHz
);

    // 50��Ƶ (100MHz / 50 = 2MHz)
    // ������25Ȼ��תʱ�ӣ�25*2=50��Ƶ��
    reg [5:0] counter;
    
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 6'b0;
            clk_out <= 1'b0;
        end else begin
            if (counter == 6'd24) begin // ������24����0��ʼ����25��������
                counter <= 6'b0;
                clk_out <= ~clk_out;  // ��תʱ��
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule 