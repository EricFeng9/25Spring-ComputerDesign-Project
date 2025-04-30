`timescale 1ns / 1ps

module instruction_fetch_tb();
    reg clk;          
    reg branch_taken;        
    reg rst;          
    reg [31:0] imm;  
    reg [31:0]pc;
    wire [31:0] instruction; 
    wire [31:0] pc_next;
    //ָ���ȡģ�� i_fetch
    instruction_fetch i_fetch (
        .clk(clk),
        .branch_taken(branch_taken),
        .rst(rst),
        .imm32(imm),
        .pc(pc),
        .instruction(instruction),
        .pc_next(pc_next)  // ����pc_next���
        );
    // ����pc
    always @(negedge clk) begin
        if (rst) begin
            pc <= 32'h0;  // ��λʱPC����
        end else begin
            pc <= pc_next; // ÿ��ʱ�����ڸ���PCΪpc_next��ֵ
        end
    end
    // ʱ������
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns����
    end
    
    // ���Թ���
    initial begin
        // ��ʼ�������ź�
        branch_taken = 0;
        rst = 1;
        imm = 32'h8;
        
        #15;
        //����˳��ִ��
        rst = 0;      
        branch_taken = 0;    
        #60;
        //��ת
        branch_taken = 1;
        #10;
        branch_taken = 0;
        #20;
        
        $finish;
    end
    
    
endmodule 