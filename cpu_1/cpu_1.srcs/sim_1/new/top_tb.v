`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// ����ģ����Դ��ļ�
// ��������ִ��ָ��ģʽ
//////////////////////////////////////////////////////////////////////////////////

module top_tb();
    // �����ź�
    reg clk;                  // ʱ���ź�
    reg rst;                  // ��λ�ź�
    reg [10:0] switch;        // ���������ź�
    reg start_pg;             // UART���ģʽ�����ź�
    reg rx;                   // UART��������
    
    // ����ź�
    wire [7:0] seg_en;        // �����ʹ���ź�
    wire [7:0] seg_out;       // ����ܶ�ѡ�ź�
    wire [7:0] led;           // LED����ź�
    wire tx;                  // UART��������
    
    // �ڲ������źţ����ڲ��ԣ�
    wire [31:0] pc_monitor;
    wire [31:0] instruction_monitor;
    wire [31:0] alu_result_monitor;
    wire [31:0] reg_data1_monitor;
    wire [31:0] reg_data2_monitor;
    wire [31:0] r_wdata_monitor;
    wire mem_write_en_monitor;
    wire mem_read_en_monitor;
    wire io_write_en_monitor;
    wire io_read_en_monitor;
    wire reg_write_en_monitor;
    wire branch_taken_monitor;
    wire kick_off_monitor;
    wire branch_taken;
    wire [31:0]imm;
    // ʵ��������ģ��
    top uut(
        .clk(clk),
        .rst(rst),
        .switch(switch),
        .seg_en(seg_en),
        .seg_out(seg_out),
        .led(led),
        .start_pg(start_pg),
        .rx(rx),
        .tx(tx)
    );
    
    // �����ڲ��ź�
    assign pc_monitor = uut.pc;
    assign instruction_monitor = uut.instruction;
    assign alu_result_monitor = uut.alu_result;
    assign reg_data1_monitor = uut.reg_data1;
    assign reg_data2_monitor = uut.reg_data2;
    assign r_wdata_monitor = uut.r_wdata;
    
    assign mem_write_en_monitor = uut.mem_write_en;
    assign mem_read_en_monitor = uut.mem_read_en;
    assign io_write_en_monitor = uut.io_write_en;
    assign io_read_en_monitor = uut.io_read_en;
    assign reg_write_en_monitor = uut.reg_write_en;
    assign branch_taken_monitor = uut.branch_taken;
    assign kick_off_monitor = uut.kick_off;
    assign branch_taken = uut.branch_taken;
    assign imm = uut.imm;
    // ʱ������
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHzʱ�� (����10ns)
    end
    
    // ��������
    initial begin
        // ��ʼ������
        rst = 1;
        switch = 11'b0;
        start_pg = 0;         // ȷ����������ִ��ģʽ (kick_off=1)
        
        // �ȴ�ʱ���ź��ȶ�
        #300;
        rst = 0;
        
        #600;

        
        
        // ��������
        $display("�������");
        $finish;
    end
    
    // ָ����븨������
    task decode_instruction;
        input [31:0] inst;
        begin
            case(inst[6:0])
                7'b0110011: $display("R��ָ��: %h (add/sub/and/or/sll/srl��)", inst);
                7'b0010011: $display("I��ָ��: %h (addi��)", inst);
                7'b0000011: $display("����ָ��: %h (lw��)", inst);
                7'b0100011: $display("�洢ָ��: %h (sw��)", inst);
                7'b1100011: $display("��ָ֧��: %h (beq/bne/blt/bge��)", inst);
                7'b1101111: $display("��תָ��: %h (jal)", inst);
                default: $display("����ָ��: %h", inst);
            endcase
        end
    endtask
    
    // ���ָ��ִ��
    always @(posedge clk) begin
        if(!rst && kick_off_monitor) begin
            decode_instruction(instruction_monitor);
            $display("PC=%h, ALU=%h, REG1=%h, REG2=%h, WRITE_DATA=%h",
                     pc_monitor, alu_result_monitor, reg_data1_monitor, 
                     reg_data2_monitor, r_wdata_monitor);
            if(branch_taken_monitor)
                $display("---> ��֧��ת����!");
            if(mem_write_en_monitor)
                $display("---> �ڴ�д��: ��ַ=%h, ����=%h", alu_result_monitor, reg_data2_monitor);
            if(mem_read_en_monitor)
                $display("---> �ڴ��ȡ: ��ַ=%h", alu_result_monitor);
            if(io_write_en_monitor)
                $display("---> IOд��: ��ַ=%h, ����=%h", alu_result_monitor, reg_data2_monitor);
            if(io_read_en_monitor)
                $display("---> IO��ȡ: ��ַ=%h", alu_result_monitor);
        end
    end
    

endmodule 