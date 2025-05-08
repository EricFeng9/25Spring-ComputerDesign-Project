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
output reg branch, alu_src_2,
output reg alu_src_1,  // AUIPC专用: 0=reg_data1, 1=PC 作为ALU输入A
reg_write_en, mem_write_en, mem_read_en,
jump,//后续的地方没用，给了jalr指令
output reg [1:0]alu_op,//top原定4bits;
output reg io_write_en, io_read_en,  // IO控制信号
output reg [1:0] wb_select  // 写回数据源选择信号: 00:ALU结果, 01:Mem/IO数据, 10:PC+4, 11:Imm
    );
    
    // 定义IO地址常量 (与mem_or_io.v中一致)
    parameter LED_BASE = 32'hFFFFC600;
    parameter SWITCH_BASE = 32'hFFFFC700;
    parameter SEG_DISPLAY_BASE = 32'hFFFFC700;
    
    always @(*) begin
        // 默认值
        reg_write_en = 1'b0;
        alu_src_2 = 1'b0;
        mem_write_en = 1'b0;
        mem_read_en = 1'b0;
        branch = 1'b0;
        alu_op = 2'b11;
        jump = 1'b0;
        io_write_en = 1'b0;  
        io_read_en = 1'b0;   
        wb_select = 2'b00;   // 默认写回ALU结果
        alu_src_1 = 1'b0; // 默认ALU输入A为reg_data1
               
        case (opcode)
            // R-type指令
            7'b0110011: begin
                reg_write_en = 1'b1;
                alu_op = 2'b10;
                wb_select = 2'b00;   // 写回ALU结果
            end
                   
            // I-type指令 (算术/逻辑)
            7'b0010011: begin
                reg_write_en = 1'b1;
                alu_src_2 = 1'b1;
                alu_op = 2'b10; //fjm 做了修改
                wb_select = 2'b00;   // 写回ALU结果
            end
                   
            // Load指令
            7'b0000011: begin
                reg_write_en = 1'b1;
                alu_src_2 = 1'b1;
                mem_read_en = 1'b1;
                alu_op = 2'b00;
                io_read_en = 1'b1;  // 同时可能读取IO设备
                wb_select = 2'b01;   // 写回从内存或IO读取的数据
            end
                   
            // Store指令
            7'b0100011: begin
                alu_src_2 = 1'b1;
                mem_write_en = 1'b1;
                alu_op = 2'b00;
                io_write_en = 1'b1; // 同时可能写入IO设备
                // reg_write_en is 0, wb_select can be don't care or default
            end
                   
            // Branch指令
            7'b1100011: begin
                branch = 1'b1;
                alu_op = 2'b01;
                // reg_write_en is 0, wb_select can be don't care or default
            end
                   
            // Jump指令 
            7'b1101111,7'b1100111: begin //JAL,jalr
                reg_write_en = 1'b1;
                alu_src_2=1'b1;
                jump = 1'b1;
                alu_op = 2'b11;
                if (opcode == 7'b1100111) // JALR
                    alu_src_2 = 1'b1; // ALU_B is imm for PC calculation
                wb_select = 2'b10;   // 写回 PC+4
            end 
            
            //lui,auipc
            7'b0110111,7'b0010111:begin
                reg_write_en = 1'b1;
                if (opcode == 7'b0010111) begin // AUIPC
                    alu_src_1 = 1'b1;       // ALU input 1 选择 pc
                    alu_src_2 = 1'b1;       // ALU input 2 选择 imm
                    alu_op = 2'b00;         // ALU执行add
                    wb_select = 2'b00;      // Write back ALU result (PC+imm)
                end else begin // LUI
                    // For LUI, alu_src_1/alu_src_2/alu_op 对最后的写回没有任何影响
                    wb_select = 2'b11;      // 写回立即数到寄存器
                end
            end
            
            default: begin
                // 无操作或未知指令
                reg_write_en = 1'b0;
                alu_src_1 = 1'b0;
                alu_src_2 = 1'b0;
                mem_write_en = 1'b0;
                mem_read_en = 1'b0;
                branch = 1'b0;
                alu_op = 2'b11;
                jump = 1'b0;
                io_write_en = 1'b0;  
                io_read_en = 1'b0; 
            end
        endcase
    end
endmodule

