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
// ���Ƶ�Ԫ - ���ɸ��ֿ����ź�
// beq, lw, sw, and, or, add, sub...

module control_unit(
input [6:0] opcode,       
input [2:0] funct3,          
input [6:0] funct7,
output reg branch, alu_src_2,
output reg alu_src_1,  // AUIPCר��: 0=reg_data1, 1=PC ��ΪALU����A
reg_write_en, mem_write_en, mem_read_en,
jump,//�����ĵط�û�ã�����jalrָ��
output reg [1:0]alu_op,//topԭ��4bits;
output reg io_write_en, io_read_en,  // IO�����ź�
output reg [1:0] wb_select  // д������Դѡ���ź�: 00:ALU���, 01:Mem/IO����, 10:PC+4, 11:Imm
    );
    
    // ����IO��ַ���� (��mem_or_io.v��һ��)
    parameter LED_BASE = 32'hFFFFC600;
    parameter SWITCH_BASE = 32'hFFFFC700;
    parameter SEG_DISPLAY_BASE = 32'hFFFFC700;
    
    always @(*) begin
        // Ĭ��ֵ
        reg_write_en = 1'b0;
        alu_src_2 = 1'b0;
        mem_write_en = 1'b0;
        mem_read_en = 1'b0;
        branch = 1'b0;
        alu_op = 2'b11;
        jump = 1'b0;
        io_write_en = 1'b0;  
        io_read_en = 1'b0;   
        wb_select = 2'b00;   // Ĭ��д��ALU���
        alu_src_1 = 1'b0; // Ĭ��ALU����AΪreg_data1
               
        case (opcode)
            // R-typeָ��
            7'b0110011: begin
                reg_write_en = 1'b1;
                alu_op = 2'b10;
                wb_select = 2'b00;   // д��ALU���
            end
                   
            // I-typeָ�� (����/�߼�)
            7'b0010011: begin
                reg_write_en = 1'b1;
                alu_src_2 = 1'b1;
                alu_op = 2'b10; //fjm �����޸�
                wb_select = 2'b00;   // д��ALU���
            end
                   
            // Loadָ��
            7'b0000011: begin
                reg_write_en = 1'b1;
                alu_src_2 = 1'b1;
                mem_read_en = 1'b1;
                alu_op = 2'b00;
                io_read_en = 1'b1;  // ͬʱ���ܶ�ȡIO�豸
                wb_select = 2'b01;   // д�ش��ڴ��IO��ȡ������
            end
                   
            // Storeָ��
            7'b0100011: begin
                alu_src_2 = 1'b1;
                mem_write_en = 1'b1;
                alu_op = 2'b00;
                io_write_en = 1'b1; // ͬʱ����д��IO�豸
                // reg_write_en is 0, wb_select can be don't care or default
            end
                   
            // Branchָ��
            7'b1100011: begin
                branch = 1'b1;
                alu_op = 2'b01;
                // reg_write_en is 0, wb_select can be don't care or default
            end
                   
            // Jumpָ�� 
            7'b1101111,7'b1100111: begin //JAL,jalr
                reg_write_en = 1'b1;
                alu_src_2=1'b1;
                jump = 1'b1;
                alu_op = 2'b11;
                if (opcode == 7'b1100111) // JALR
                    alu_src_2 = 1'b1; // ALU_B is imm for PC calculation
                wb_select = 2'b10;   // д�� PC+4
            end 
            
            //lui,auipc
            7'b0110111,7'b0010111:begin
                reg_write_en = 1'b1;
                if (opcode == 7'b0010111) begin // AUIPC
                    alu_src_1 = 1'b1;       // ALU input 1 ѡ�� pc
                    alu_src_2 = 1'b1;       // ALU input 2 ѡ�� imm
                    alu_op = 2'b00;         // ALUִ��add
                    wb_select = 2'b00;      // Write back ALU result (PC+imm)
                end else begin // LUI
                    // For LUI, alu_src_1/alu_src_2/alu_op ������д��û���κ�Ӱ��
                    wb_select = 2'b11;      // д�����������Ĵ���
                end
            end
            
            default: begin
                // �޲�����δָ֪��
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

