`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/06 17:28:50
// Design Name: 
// Module Name: control_unit
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
// 控制单元 - 生成各种控制信号
// beq, lw, sw, and, or, add, sub...

module control_unit(
input [6:0] opcode,       
input [2:0] funct3,          
input [6:0] funct7,
output reg branch, mem_to_reg, alu_src, 
reg_write_en, mem_write_en, mem_read_en,
jump,//后续的地方没用，给了jalr指令
output reg [1:0]alu_op,//top原定4bits;
output reg io_write_en, io_read_en  // IO控制信号
    );
    
    // 定义IO地址常量 (与mem_or_io.v中一致)
    parameter LED_BASE = 32'hFFFFC600;
    parameter SWITCH_BASE = 32'hFFFFC700;
    parameter SEG_DISPLAY_BASE = 32'hFFFFC700;
    
    always @(*) begin
        // 默认值
        reg_write_en = 1'b0;
        alu_src = 1'b0;
        mem_write_en = 1'b0;
        mem_read_en = 1'b0;
        mem_to_reg = 1'b0;
        branch = 1'b0;
        alu_op = 2'b11;
        jump = 1'b0;
        io_write_en = 1'b0;  
        io_read_en = 1'b0;   
               
        case (opcode)
            // R-type指令
            7'b0110011: begin
                reg_write_en = 1'b1;
                alu_op = 2'b10;
            end
                   
            // I-type指令 (算术/逻辑)
            7'b0010011: begin
                reg_write_en = 1'b1;
                alu_src = 1'b1;
            end
                   
            // Load指令
            7'b0000011: begin
                reg_write_en = 1'b1;
                alu_src = 1'b1;
                mem_read_en = 1'b1;
                mem_to_reg = 1'b1;
                alu_op = 2'b00;
                io_read_en = 1'b1;  // 同时可能读取IO设备
            end
                   
            // Store指令
            7'b0100011: begin
                alu_src = 1'b1;
                mem_write_en = 1'b1;
                alu_op = 2'b00;
                io_write_en = 1'b1; // 同时可能写入IO设备
            end
                   
            // Branch指令
            7'b1100011: begin
                branch = 1'b1;
                alu_op = 2'b01;
            end
                   
            // Jump指令 (JAL)
            7'b1101111: begin
                reg_write_en = 1'b1;
                jump = 1'b1;
            end 
                      
            default: begin
                // 无操作或未知指令
                reg_write_en = 1'b0;
                alu_src = 1'b0;
                mem_write_en = 1'b0;
                mem_read_en = 1'b0;
                mem_to_reg = 1'b0;
                branch = 1'b0;
                alu_op = 2'b11;
                jump = 1'b0;
                io_write_en = 1'b0;  
                io_read_en = 1'b0; 
            end
        endcase
    end
endmodule

