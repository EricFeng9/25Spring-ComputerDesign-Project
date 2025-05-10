`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// �������ʾ������
// ����8λ�������ʾ���ݺͱ��״̬
//////////////////////////////////////////////////////////////////////////////////

module display_controller(
    input wire clk,                 
    input wire rst,                  // �ߵ�ƽ��Ч�ĸ�λ�ź�
    input wire seg_display_ctrl,     // �������ʾ�����ź�
    input wire [31:0] result1,       // 32λ����ź�1
    input wire [31:0] result2,       // 32λ����ź�2
    input wire prog_mode,            // ���ģʽ��־
    input wire prog_done,            // �����ɱ�־
    output reg [7:0] seg_en,         // �����ʹ���ź�
    output reg [7:0] seg_out         // ����ܶ�ѡ�ź�(gfedcba)
);

    // �ڲ���������ʱ�ӷ�Ƶ
    reg [31:0] cnt;                  // ��Ƶ������
    reg clkout;                      // ��Ƶ���ʱ��
    parameter period = 10;       // ��Ƶϵ��(500Hz)
    
    // ɨ�����������ѡ��ǰ��ʾ�������
    reg [2:0] scan_cnt;              // ɨ�������(0-7)
    
    // ��ʱ�洢ÿ������
    wire [3:0] digit1 = result1[31:24];  // DK1��ʾ
    wire [3:0] digit2 = result1[23:16];  // DK2��ʾ
    wire [3:0] digit3 = result1[15:8];   // DK3��ʾ
    wire [3:0] digit4 = result1[7:0];    // DK4��ʾ
    wire [3:0] digit5 = result2[31:24];  // DK5��ʾ
    wire [3:0] digit6 = result2[23:16];  // DK6��ʾ
    wire [3:0] digit7 = result2[15:8];   // DK7��ʾ
    wire [3:0] digit8 = result2[7:0];    // DK8��ʾ
    
    // ������״̬��ʾ�ַ�
    // S = 10110110, U = 01111100, C = 10011100, E = 10011110, 
    // S = 10110110, S = 10110110
    // I = 00001100, N = 11101100, G = 11110110
    parameter S_CHAR = 8'b10110110;
    parameter U_CHAR = 8'b01111100;
    parameter C_CHAR = 8'b10011100;
    parameter E_CHAR = 8'b10011110;
    parameter I_CHAR = 8'b00001100;
    parameter N_CHAR = 8'b11101100;
    parameter G_CHAR = 8'b11110110;
    
    // ��Ƶ��ϵͳʱ�� -> ɨ��ʱ��
    always @(posedge clk or posedge rst) begin  // ����첽��λ
        if(rst) begin
            cnt <= 0;
            clkout <= 1'b0;  // ��ȷ��Ϊ0
        end else begin
            if(cnt >= period-1) begin  // ʹ��>=�����������
                cnt <= 0;
                clkout <= ~clkout;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end
    
    // ɨ�����������
    always @(posedge clkout or posedge rst) begin  // ����첽��λ
        if(rst) begin
            scan_cnt <= 3'd0;
        end else if(!seg_display_ctrl) begin  // �ֿ���λ��ʹ�ܼ��
            scan_cnt <= 3'd0;
        end else begin
            scan_cnt <= scan_cnt + 1;  // ���߼���ʼ��ѭ��
        end
    end
    
    // ����ɨ�������ѡ��ǰ��ʾ�ĸ������
    always @(scan_cnt) begin
        case(scan_cnt)
            3'b000: seg_en = 8'h01;  // ѡ���1�������(DK1)
            3'b001: seg_en = 8'h02;  // ѡ���2�������(DK2)
            3'b010: seg_en = 8'h04;  // ѡ���3�������(DK3)
            3'b011: seg_en = 8'h08;  // ѡ���4�������(DK4)
            3'b100: seg_en = 8'h10;  // ѡ���5�������(DK5)
            3'b101: seg_en = 8'h20;  // ѡ���6�������(DK6)
            3'b110: seg_en = 8'h40;  // ѡ���7�������(DK7)
            3'b111: seg_en = 8'h80;  // ѡ���8�������(DK8)
            default: seg_en = 8'h00; // Ĭ�ϲ�ѡ��
        endcase
    end
    
    // ���ݵ�ǰɨ��������Ͷ�Ӧ�����ֻ���״̬���ö�ѡ�ź�
    always @(*) begin
        if(prog_mode) begin
            // ���ģʽ��ʾ
            if(prog_done) begin
                // ��ʾ "SUCCESS"
                case(scan_cnt)
                    3'b000: seg_out = S_CHAR;  // S
                    3'b001: seg_out = U_CHAR;  // U
                    3'b010: seg_out = C_CHAR;  // C
                    3'b011: seg_out = C_CHAR;  // C
                    3'b100: seg_out = E_CHAR;  // E
                    3'b101: seg_out = S_CHAR;  // S
                    3'b110: seg_out = S_CHAR;  // S
                    3'b111: seg_out = 8'b00000000; // ��
                    default: seg_out = 8'b00000000;
                endcase
            end else begin
                // ��ʾ "ing"
                case(scan_cnt) 
                    3'b000: seg_out = I_CHAR;  // I
                    3'b001: seg_out = N_CHAR;  // N
                    3'b010: seg_out = G_CHAR;  // G
                    3'b011: seg_out = 8'b00000000; // ��
                    3'b100: seg_out = 8'b00000000; // ��
                    3'b101: seg_out = 8'b00000000; // ��
                    3'b110: seg_out = 8'b00000000; // ��
                    3'b111: seg_out = 8'b00000000; // ��
                    default: seg_out = 8'b00000000;
                endcase
            end
        end else begin
            // ����ģʽ��ʾ�������
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
    end
    
    // ��4λ����ת��Ϊ7������ܵ���ʾ����
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