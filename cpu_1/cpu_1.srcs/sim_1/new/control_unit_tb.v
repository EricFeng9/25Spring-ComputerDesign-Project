`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/07 10:55:41
// Design Name: 
// Module Name: control_unit_tb
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
module control_unit_tb;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    
    wire branch, alu_src, reg_write_en, mem_write_en, mem_read_en,jump;
    wire [1:0] alu_op;
    wire io_write_en, io_read_en;
    
    control_unit uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .branch(branch),
        .alu_src(alu_src),
        .reg_write_en(reg_write_en),
        .mem_write_en(mem_write_en),
        .mem_read_en(mem_read_en),
        .jump(jump),
        .alu_op(alu_op),
        .io_write_en(io_write_en),
        .io_read_en(io_read_en)
    );
    
    initial begin
        // ��ʼ������
        opcode = 7'b0;
        funct3 = 3'b0;
        funct7 = 7'b0;
        
        // ��ʼ����
        $display("��ʼcontrol_unitģ�����...");
        $display("======================================");
        
        // ����R-typeָ��
        $display("����R-typeָ��...");
        opcode = 7'b0110011; // R-type
        #10;
        check_outputs(1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b10, 1'b0, 1'b0, "R-type");
        
        // ����I-type����/�߼�ָ��
        $display("����I-type����/�߼�ָ��...");
        opcode = 7'b0010011; // I-type
        #10;
        check_outputs(1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0, "I-type");
        
        // ����Loadָ��
        $display("����Loadָ��...");
        opcode = 7'b0000011; // Load
        #10;
        check_outputs(1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b1, "Load");
        
        // ����Storeָ��
        $display("����Storeָ��...");
        opcode = 7'b0100011; // Store
        #10;
        check_outputs(1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, "Store");
        
        // ����Branchָ��
        $display("����Branchָ��...");
        opcode = 7'b1100011; // Branch
        funct3 = 3'b000; // BEQ
        #10;
        check_outputs(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b01, 1'b0, 1'b0, "Branch");
        
        // ����JALָ��
        $display("����JALָ��...");
        opcode = 7'b1101111; // JAL
        #10;
        check_outputs(1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 2'b11, 1'b0, 1'b0, "JAL");
        
        // ����JALRָ��
        $display("����JALRָ��...");
        opcode = 7'b1100111; // JALR
        #10;
        check_outputs(1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 2'b11, 1'b0, 1'b0, "JALR");
        
        // ����LUIָ��
        $display("����LUIָ��...");
        opcode = 7'b0110111; // LUI
        #10;
        check_outputs(1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0, "LUI");
        
        // ����AUIPCָ��
        $display("����AUIPCָ��...");
        opcode = 7'b0010111; // AUIPC
        #10;
        check_outputs(1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0, "AUIPC");
        
        // ����δָ֪��
        $display("����δָ֪��...");
        opcode = 7'b1111111; // δָ֪��
        #10;
        check_outputs(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b11, 1'b0, 1'b0, "Unknown");
        
        $display("======================================");
        $display("control_unitģ��������!");
        $finish;
    end
    
    // �������񣺼������Ƿ����Ԥ��
    task check_outputs;
        input exp_branch, exp_alu_src, exp_reg_write_en;
        input exp_mem_write_en, exp_mem_read_en, exp_jump;
        input [1:0] exp_alu_op;
        input exp_io_write_en, exp_io_read_en;
        input [100:0] test_name;
        
        begin
            if (branch !== exp_branch || alu_src !== exp_alu_src || 
                reg_write_en !== exp_reg_write_en || mem_write_en !== exp_mem_write_en || 
                mem_read_en !== exp_mem_read_en || jump !== exp_jump || 
                alu_op !== exp_alu_op || io_write_en !== exp_io_write_en || 
                io_read_en !== exp_io_read_en) begin
                
                $display("����ʧ��: %s", test_name);
                $display("Ԥ�����:");
                $display("branch=%b, alu_src=%b, reg_write_en=%b", 
                         exp_branch, exp_alu_src, exp_reg_write_en);
                $display("mem_write_en=%b, mem_read_en=%b, jump=%b, alu_op=%b", 
                         exp_mem_write_en, exp_mem_read_en, exp_jump, exp_alu_op);
                $display("io_write_en=%b, io_read_en=%b", 
                         exp_io_write_en, exp_io_read_en);
                
                $display("ʵ�����:");
                $display("branch=%b, alu_src=%b, reg_write_en=%b", 
                         branch, alu_src, reg_write_en);
                $display("mem_write_en=%b, mem_read_en=%b, jump=%b, alu_op=%b", 
                         mem_write_en, mem_read_en, jump, alu_op);
                $display("io_write_en=%b, io_read_en=%b", 
                         io_write_en, io_read_en);
                $display("--------------------------------------");
            end
            else begin
                $display("����ͨ��: %s", test_name);
            end
        end
    endtask
    
endmodule
