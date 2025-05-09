`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 数码管驱动模块 - AI生成的流水灯代码
//////////////////////////////////////////////////////////////////////////////////

module display_controller(
    input wire clk,                 
    input wire rst,                  // 高电平有效的复位信号
    input wire led_display_ctrl,
    input wire [31:0] result1,       // 32位结果信号1
    input wire [31:0] result2,       // 32位结果信号2
    output reg [7:0] seg_en,         // 数码管使能信号
    output reg [7:0] seg_out         // 数码管段选信号(gfedcba)
);

    // 内部计数器和时钟分频
    reg [31:0] cnt;                  // 分频计数器
    reg clkout;                      // 分频后的时钟
    parameter period = 200000;       // 分频系数(500Hz)
    
    // 扫描计数器用于选择当前显示的数码管
    reg [2:0] scan_cnt;              // 扫描计数器(0-7)
    
    // 临时存储每个数字
    wire [3:0] digit1 = result1[31:24];  // DK1显示
    wire [3:0] digit2 = result1[23:16];  // DK2显示
    wire [3:0] digit3 = result1[15:8];   // DK3显示
    wire [3:0] digit4 = result1[7:0];    // DK4显示
    wire [3:0] digit5 = result2[31:24];  // DK5显示
    wire [3:0] digit6 = result2[23:16];  // DK6显示
    wire [3:0] digit7 = result2[15:8];   // DK7显示
    wire [3:0] digit8 = result2[7:0];    // DK8显示
    
    // 分频：系统时钟 -> 扫描时钟
    always @(posedge clk) begin
        if(rst) begin
            cnt <= 0;
            clkout <= 0;
        end else begin
            if(cnt == period-1) begin
                cnt <= 0;
                clkout <= ~clkout;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end
    
    // 扫描计数器控制，每个clkout周期更新一次scan_cnt
    always @(posedge clkout) begin
        if(rst || !led_display_ctrl) begin
        //进行了人为修改：必须片选过后才生效
            scan_cnt <= 0;
        end else begin
            if(scan_cnt == 3'd7)
                scan_cnt <= 0;
            else
                scan_cnt <= scan_cnt + 1;
        end
    end
    
    // 根据扫描计数器选择当前显示哪个数码管
    always @(scan_cnt) begin
        case(scan_cnt)
            3'b000: seg_en = 8'h01;  // 选择第1个数码管(DK1)
            3'b001: seg_en = 8'h02;  // 选择第2个数码管(DK2)
            3'b010: seg_en = 8'h04;  // 选择第3个数码管(DK3)
            3'b011: seg_en = 8'h08;  // 选择第4个数码管(DK4)
            3'b100: seg_en = 8'h10;  // 选择第5个数码管(DK5)
            3'b101: seg_en = 8'h20;  // 选择第6个数码管(DK6)
            3'b110: seg_en = 8'h40;  // 选择第7个数码管(DK7)
            3'b111: seg_en = 8'h80;  // 选择第8个数码管(DK8)
            default: seg_en = 8'h00; // 默认不选择
        endcase
    end
    
    // 根据当前扫描计数器和对应的数字设置段选信号
    always @(*) begin
        case(scan_cnt)
            3'b000: seg_out = digit_to_seg(digit1);  // DK1
            3'b001: seg_out = digit_to_seg(digit2);  // DK2
            3'b010: seg_out = digit_to_seg(digit3);  // DK3
            3'b011: seg_out = digit_to_seg(digit4);  // DK4
            3'b100: seg_out = digit_to_seg(digit5);  // DK5
            3'b101: seg_out = digit_to_seg(digit6);  // DK6
            3'b110: seg_out = digit_to_seg(digit7);  // DK7
            3'b111: seg_out = digit_to_seg(digit8);  // DK8
            default: seg_out = 8'b00000000;
        endcase
    end
    
    // 将4位数字转换为7段数码管的显示编码
    function [7:0] digit_to_seg;
        input [3:0] digit;
        begin
            case(digit)
                4'h0: digit_to_seg = 8'b11111100;  // 0
                4'h1: digit_to_seg = 8'b01100000;  // 1
                4'h2: digit_to_seg = 8'b11011010;  // 2
                4'h3: digit_to_seg = 8'b11110010;  // 3
                4'h4: digit_to_seg = 8'b01100110;  // 4
                4'h5: digit_to_seg = 8'b10110110;  // 5
                4'h6: digit_to_seg = 8'b10111110;  // 6
                4'h7: digit_to_seg = 8'b11100000;  // 7
                4'h8: digit_to_seg = 8'b11111110;  // 8
                4'h9: digit_to_seg = 8'b11110110;  // 9
                4'ha: digit_to_seg = 8'b11101110;  // A
                4'hb: digit_to_seg = 8'b00111110;  // b
                4'hc: digit_to_seg = 8'b10011100;  // C
                4'hd: digit_to_seg = 8'b01111010;  // d
                4'he: digit_to_seg = 8'b10011110;  // E
                4'hf: digit_to_seg = 8'b10001110;  // F
                default: digit_to_seg = 8'b00000000;
            endcase
        end
    endfunction

endmodule