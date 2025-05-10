`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 时钟分频器模块
// 将100MHz的输入时钟降频为4MHz
// 声明：此模块完全由claude-3.7-sonnet生成
//////////////////////////////////////////////////////////////////////////////////

module clk_100mhz_to_4mhz(
    input wire clk_in,     // 输入时钟 100MHz
    input wire rst,        // 复位信号
    output reg clk_out     // 输出时钟 4MHz
);

    // 25分频 (100MHz / 25 = 4MHz)
    // 需要计数到12然后翻转时钟
    reg [4:0] counter;
    
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 5'b0;
            clk_out <= 1'b0;
        end else begin
            if (counter == 5'd12) begin
                counter <= 5'b0;
                clk_out <= ~clk_out;  // 翻转时钟
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule 