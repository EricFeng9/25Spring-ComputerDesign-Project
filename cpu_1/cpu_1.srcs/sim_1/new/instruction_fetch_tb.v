`timescale 1ns / 1ps

module instruction_fetch_tb();
    reg clk;          
    reg rst;
    reg kick_off;                // ����ģʽ�ź�: 1=����ģʽ  
    reg branch_taken;            // ��֧���������ź�
    reg jump;                    // ��ת�ź�
    reg [31:0] imm;              // ������(���ڷ�֧/��תĿ�����)
    
    // UART��̽ӿ� (������������ʵ�ʲ���)
    reg upg_clk;
    reg upg_rst;
    reg upg_wen;
    reg [14:0] upg_adr;
    reg [31:0] upg_dat;
    reg upg_done;
    
    // ����ź�
    wire [31:0] pc;              // ���������
    wire [31:0] instruction;     // ��ǰָ��
    
    // ʵ����instruction_fetchģ��
    instruction_fetch i_fetch (
        .clk(clk),                  // CPUʱ��
        .rst(rst),                  // ��λ�ź�
        .kick_off(kick_off),        // ����ģʽ: 1=����ģʽ
        .branch_taken(branch_taken),// ��֧��������
        .jump(jump),                // ��תָ��
        .imm(imm),                  // ������
        
        // UART������ӿ�
        .upg_clk(upg_clk),          // UART���ʱ��
        .upg_rst(upg_rst),          // UART��̸�λ
        .upg_wen(upg_wen),          // UARTдʹ��
        .upg_adr(upg_adr),          // UART��ַ
        .upg_dat(upg_dat),          // UART����
        .upg_done(upg_done),        // UART������
        
        .pc(pc),                    // ������������
        .instruction(instruction)   // ��ǰָ�����
    );
    
    // ʱ������
    initial begin
        clk = 0;
        forever #5 clk = ~clk;      // 10ns����
    end
    
    // ���Թ���
    initial begin
        // ��ʼ�������ź�
        rst = 1;
        kick_off = 1;               // ����Ϊ����ִ��ģʽ
        branch_taken = 0;
        jump = 0;
        imm = 32'h8;
        
        // UART����ź�����ΪĬ��ֵ(����Ӱ�����)
        upg_clk = 0;
        upg_rst = 1;
        upg_wen = 0;
        upg_adr = 15'h0;
        upg_dat = 32'h0;
        upg_done = 1;
        
        // ��λ���ͷţ���ʼ����˳��ִ��
        #15;
        rst = 0;      
        branch_taken = 0;
        jump = 0;    
        #20;
        
        // ���Է�ָ֧��
        branch_taken = 1;
        #10;
        branch_taken = 0;
        #20;
        
        // ������תָ��
        jump = 1;
        #10;
        jump = 0;
        #20;
        
        // ����ͬʱ�з�֧����ת
        branch_taken = 1;
        jump = 1;
        #10;
        branch_taken = 0;
        jump = 0;
        #20;
        

        $finish;
    end
    
    // ����������ӡ��Ҫ�ź�ֵ
    initial begin
        $monitor("Time=%0t, rst=%b, kick_off=%b, branch_taken=%b, jump=%b, imm=%h, pc=%h, instruction=%h",
                $time, rst, kick_off, branch_taken, jump, imm, pc, instruction);
    end
    
endmodule 