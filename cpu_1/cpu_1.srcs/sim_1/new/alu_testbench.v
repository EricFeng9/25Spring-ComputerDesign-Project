`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/03 16:56:06
// Design Name: 
// Module Name: alu_testbench
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


module alu_testbench();

    reg [31:0] rs1;
    reg [31:0] rs2;
    reg [1:0] alu_op;
    wire [31:0] result;
    wire zero;
    reg [2:0] funct3;
    reg inst_30;

    // Instantiate ALU Unit
    alu alu_test(
        .a(rs1),
        .b(rs2),
        .alu_op(alu_op),
        .result(result),
        .zero(zero),
        .funct3(funct3),
        .inst_30(inst_30)
    );

    // Initial Block to drive inputs
    initial begin
        // Test Case 1: Basic ADD Operation
        rs1 = 32'd5;
        rs2 = 32'd3;
        alu_op = 2'b10;
        funct3 = 3'b000;
        inst_30 = 1'b0;
        #10;

        // Test Case 2: Basic SUB Operation
        rs1 = 32'd5;
        rs2 = 32'd3;
        alu_op = 2'b10;
        funct3 = 3'b000;
        inst_30 = 1'b1;
        #10;

        // Test Case 3: SLL Operation
        rs1 = 32'd1;
        rs2 = 32'd2;
        alu_op = 2'b10;
        funct3 = 3'b001;
        inst_30 = 1'b0;
        #10;

        // Test Case 4: SLT Operation
        rs1 = 32'd0 - 32'd1;
        rs2 = 32'd1;
        alu_op = 2'b10;
        funct3 = 3'b010;
        inst_30 = 1'b0;
        #10;

        // Test Case 5: SLTU Operation
        rs1 = 32'hffffffff;
        rs2 = 32'd1;
        alu_op = 2'b10;
        funct3 = 3'b011;
        inst_30 = 1'b0;
        #10;

        // Test Case 6: XOR Operation
        rs1 = 32'd5;
        rs2 = 32'd3;
        alu_op = 2'b10;
        funct3 = 3'b100;
        inst_30 = 1'b0;
        #10;

        // Test Case 7: SRL Operation
        rs1 = 32'h10;
        rs2 = 32'd1;
        alu_op = 2'b10;
        funct3 = 3'b101;
        inst_30 = 1'b0;
        #10;

        // Test Case 8: SRA Operation
        rs1 = 32'hffff_ff80;
        rs2 = 32'd3;
        alu_op = 2'b10;
        funct3 = 3'b101;
        inst_30 = 1'b1;
        #10;

        // Test Case 9: OR Operation
        rs1 = 32'd12;
        rs2 = 32'd5;
        alu_op = 2'b10;
        funct3 = 3'b110;
        inst_30 = 1'b0;
        #10;

        // Test Case 10: AND Operation
        rs1 = 32'd12;
        rs2 = 32'd5;
        alu_op = 2'b10;
        funct3 = 3'b111;
        inst_30 = 1'b0;
        #10;

        // Test Case 11: ADD Operation with different inputs
        rs1 = 32'd7;
        rs2 = 32'd4;
        alu_op = 2'b10;
        funct3 = 3'b000;
        inst_30 = 1'b0;
        #10;

        // Test Case 12: SUB Operation with different inputs
        rs1 = 32'd10;
        rs2 = 32'd5;
        alu_op = 2'b10;
        funct3 = 3'b000;
        inst_30 = 1'b1;
        #10;

        // Test Case 13: SLL Operation with different inputs
        rs1 = 32'd2;
        rs2 = 32'd3;
        alu_op = 2'b10;
        funct3 = 3'b001;
        inst_30 = 1'b0;
        #10;

        // Test Case 14: SLT Operation with different inputs
        rs1 = 32'd100;
        rs2 = 32'd200;
        alu_op = 2'b10;
        funct3 = 3'b010;
        inst_30 = 1'b0;
        #10;

        // Test Case 15: SLTU Operation with different inputs
        rs1 = 32'hffffffff;
        rs2 = 32'd200;
        alu_op = 2'b10;
        funct3 = 3'b011;
        inst_30 = 1'b0;
        #10;

        // Test Case 16: XOR Operation with different inputs
        rs1 = 32'd50;
        rs2 = 32'd15;
        alu_op = 2'b10;
        funct3 = 3'b100;
        inst_30 = 1'b0;
        #10;

        // Test Case 17: SRL Operation with different inputs
        rs1 = 32'h20;
        rs2 = 32'd2;
        alu_op = 2'b10;
        funct3 = 3'b101;
        inst_30 = 1'b0;
        #10;

        // Test Case 18: SRA Operation with different inputs
        rs1 = 32'hffff_fff0;
        rs2 = 32'd4;
        alu_op = 2'b10;
        funct3 = 3'b101;
        inst_30 = 1'b1;
        #10;

        // Test Case 19: OR Operation with different inputs
        rs1 = 32'd30;
        rs2 = 32'd10;
        alu_op = 2'b10;
        funct3 = 3'b110;
        inst_30 = 1'b0;
        #10;

        // Test Case 20: AND Operation with different inputs
        rs1 = 32'd7;
        rs2 = 32'd2;
        alu_op = 2'b10;
        funct3 = 3'b111;
        inst_30 = 1'b0;
        #10;

        $finish;
    end

endmodule
