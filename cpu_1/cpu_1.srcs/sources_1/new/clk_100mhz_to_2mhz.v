`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 时钟分频模块
// 将100MHz的输入时钟降频为2MHz
// 声明：此模块完全由claude-3.7-sonnet生成
//////////////////////////////////////////////////////////////////////////////////

module clk_100mhz_to_2mhz(
    input wire clk_in,     // 输入时钟 100MHz
    input wire rst,        // 复位信号
    output reg clk_out     // 输出时钟 2MHz
);

    // 50分频 (100MHz / 50 = 2MHz)
    // 计数到25然后翻转时钟（25*2=50分频）
    reg [5:0] counter;
    
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 6'b0;
            clk_out <= 1'b0;
        end else begin
            if (counter == 6'd24) begin // 计数到24（从0开始，共25个计数）
                counter <= 6'b0;
                clk_out <= ~clk_out;  // 翻转时钟
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule 