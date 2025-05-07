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
        // 1. I-type 测试 (Load/Immediate/Jalr)
        $display("\n测试 I-type 指令...");
        // 负数测试
        instruction = 32'b111111100000_00101_000_00100_0010011; // addi x4, x5, -32 :32'hfe028213
        #10;
        if (imm !== 32'hffffffe0) $error("I-type 正数测试失败，得到 %h", imm);
        else instruction = 32'b111111110100_00101_010_00100_0000011; // lw x4, -12(x5) ff42a203
        #10;
        if (imm !== 32'hfffffff4) $error("lw 负偏移量测试失败，得到 %h", imm);
        else $display("I-type 负数测试通过");
        // 正数测试
        instruction = 32'b000000001111_00101_000_00100_0010011; // addi x4, x5, 15 00f28213
        #10;
        if (imm !== 32'h0000000f) $error("I-type 负数测试失败，得到 %h", imm);
        else instruction = 32'b000000001100_00101_010_00100_0000011; // lw x4, 12(x5) 00c2a203
        #10;
        if (imm !== 32'h0000000c) $error("lw 正偏移量测试失败，得到 %h", imm);
        else $display("I-type 负数测试通过");
        
        // 2. S-type 测试 (Store)
        $display("\n测试 S-type 指令...");
        instruction = 32'b0000000_00101_00100_010_11000_0100011; // sw x5, 24(x4) 00522c23
        #10;
        if (imm !== 32'h00000018) $error("S-type 测试失败，得到 %h", imm);
        else $display("S-type 测试通过");
        
        // 3. B-type 测试 (Branch) 
        $display("\n测试 B-type 指令...");
        instruction = 32'b1_111111_00101_00100_000_0100_1_1100011; // beq x4, x5, -24  假定target和当前pc的偏移为-24
        #10;
        if (imm !== 32'hffffffe8) $error("B-type 测试失败，得到 %h", imm);
        else $display("B-type 测试通过");
        
        // 4. J-type 测试 (Jump) 
        $display("\n测试 J-type 指令...");
        instruction = 32'b0_0000000110_0_00000000_00001_1101111; // jal x0, 12 00c000ef
        #10;
        if (imm !== 32'h0000000c) $error("J-type 测试失败，得到 %h", imm);
        else $display("J-type 测试通过");  
        
        // 5. U-type 测试 (LUI/AUIPC)
        $display("\n测试 U-type 指令...");
        // LUI 测试
        instruction = 32'b11111111111111111111_00100_0110111; // lui x4, 0xfffff  fffff237
        #10;
        if (imm !== 32'hfffff000) $error("U-type LUI 测试失败，得到 %h", imm);
        else $display("U-type LUI 测试通过");
        // AUIPC 测试
        instruction = 32'b00000000000000000001_00100_0010111; // auipc x4, 1  00001217
        #10;
        if (imm !== 32'h00001000) $error("U-type AUIPC 测试失败，得到 %h", imm);
        else $display("U-type AUIPC 测试通过");
        
        // 6. 默认情况测试 (R-type)
        $display("\n测试默认情况...");
        instruction = 32'b0000000_00000_00000_000_00000_0110011; // add x0, x0, x0  00000033
        #10;
        if (imm !== 32'h00000000) $error("默认情况测试失败，得到 %h", imm);
        //add,sub,or,and,sll,srl,
        else $display("默认情况测试通过");
        
        $display("\n所有测试完成!");
        $finish;
    end
    
    
endmodule