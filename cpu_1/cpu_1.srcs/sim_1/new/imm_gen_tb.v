`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/07 08:49:29
// Design Name: 
// Module Name: imm_gen_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module immediate_gen_tb;
    reg [31:0] instruction;
    wire [31:0] imm;
    
    immediate_gen uut (
        .instruction(instruction),
        .imm(imm)
    );
    
    initial begin
        // 1. I-type ���� (Load/Immediate/Jalr)
        $display("\n���� I-type ָ��...");
        // ��������
        instruction = 32'b111111100000_00101_000_00100_0010011; // addi x4, x5, -32 :32'hfe028213
        #10;
        if (imm !== 32'hffffffe0) $error("I-type ��������ʧ�ܣ��õ� %h", imm);
        else instruction = 32'b111111110100_00101_010_00100_0000011; // lw x4, -12(x5) ff42a203
        #10;
        if (imm !== 32'hfffffff4) $error("lw ��ƫ��������ʧ�ܣ��õ� %h", imm);
        else $display("I-type ��������ͨ��");
        // ��������
        instruction = 32'b000000001111_00101_000_00100_0010011; // addi x4, x5, 15 00f28213
        #10;
        if (imm !== 32'h0000000f) $error("I-type ��������ʧ�ܣ��õ� %h", imm);
        else instruction = 32'b000000001100_00101_010_00100_0000011; // lw x4, 12(x5) 00c2a203
        #10;
        if (imm !== 32'h0000000c) $error("lw ��ƫ��������ʧ�ܣ��õ� %h", imm);
        else $display("I-type ��������ͨ��");
        
        // 2. S-type ���� (Store)
        $display("\n���� S-type ָ��...");
        instruction = 32'b0000000_00101_00100_010_11000_0100011; // sw x5, 24(x4) 00522c23
        #10;
        if (imm !== 32'h00000018) $error("S-type ����ʧ�ܣ��õ� %h", imm);
        else $display("S-type ����ͨ��");
        
        // 3. B-type ���� (Branch) 
        $display("\n���� B-type ָ��...");
        instruction = 32'b1_111111_00101_00100_000_0100_1_1100011; // beq x4, x5, -24  �ٶ�target�͵�ǰpc��ƫ��Ϊ-24
        #10;
        if (imm !== 32'hffffffe8) $error("B-type ����ʧ�ܣ��õ� %h", imm);
        else $display("B-type ����ͨ��");
        
        // 4. J-type ���� (Jump) 
        $display("\n���� J-type ָ��...");
        instruction = 32'b0_0000000110_0_00000000_00001_1101111; // jal x0, 12 00c000ef
        #10;
        if (imm !== 32'h0000000c) $error("J-type ����ʧ�ܣ��õ� %h", imm);
        else $display("J-type ����ͨ��");  
        
        // 5. U-type ���� (LUI/AUIPC)
        $display("\n���� U-type ָ��...");
        // LUI ����
        instruction = 32'b11111111111111111111_00100_0110111; // lui x4, 0xfffff  fffff237
        #10;
        if (imm !== 32'hfffff000) $error("U-type LUI ����ʧ�ܣ��õ� %h", imm);
        else $display("U-type LUI ����ͨ��");
        // AUIPC ����
        instruction = 32'b00000000000000000001_00100_0010111; // auipc x4, 1  00001217
        #10;
        if (imm !== 32'h00001000) $error("U-type AUIPC ����ʧ�ܣ��õ� %h", imm);
        else $display("U-type AUIPC ����ͨ��");
        
        // 6. Ĭ��������� (R-type)
        $display("\n����Ĭ�����...");
        instruction = 32'b0000000_00000_00000_000_00000_0110011; // add x0, x0, x0  00000033
        #10;
        if (imm !== 32'h00000000) $error("Ĭ���������ʧ�ܣ��õ� %h", imm);
        //add,sub,or,and,sll,srl,
        else $display("Ĭ���������ͨ��");
        
        $display("\n���в������!");
        $finish;
    end
    
    
endmodule