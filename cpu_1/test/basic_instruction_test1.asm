# 简化版测试程序 - 测试RISC-V标红框指令

.text
.globl main

main:
    # 初始化寄存器
    addi x1, x0, 10        # x1 = 10	p
    addi x2, x0, 5         # x2 = 5	p
    
    # 测试R型指令
    add  x3, x1, x2        # x3 = 10 + 5 = 15	p
    sub  x4, x1, x2        # x4 = 10 - 5 = 5	p
    or   x5, x1, x2        # x5 = 10 | 5 = 15	p
    and  x6, x1, x2        # x6 = 10 & 5 = 0	p
    
    # 测试移位指令
    addi x7, x0, 1         # x7 = 1	p
    sll  x8, x7, x2        # x8 = 1 << 5 = 32	p
    srl  x9, x3, x7        # x9 = 15 >> 1 = 7	p
    
    # 测试存储和加载
    sw   x3, 0(x0)         # 保存15到内存地址0	p
    sw   x4, 4(x0)         # 保存5到内存地址4	p
    lw   x10, 0(x0)        # x10 = 内存[0] = 15	p
    lw   x11, 4(x0)        # x11 = 内存[4] = 5	p
    
    # 测试分支指令
    beq  x4, x2, equal     # 如果x4 == x2，跳转到equal (应该跳转，两者都是5)	p
    addi x12, x0, 1        # 不应执行
    j    continue
    
equal:
    addi x12, x0, 100      # x12 = 100	p
    
continue:
    bne  x3, x2, not_equal # 如果x3 != x2，跳转到not_equal (应该跳转，15 != 5) p
    addi x13, x0, 2        # 不应执行
    j    continue2
    
not_equal:
    addi x13, x0, 200      # x13 = 200	p
    
continue2:
    blt  x2, x3, less_than # 如果x2 < x3，跳转到less_than (应该跳转，5 < 15)	p
    addi x14, x0, 3        # 不应执行
    j    continue3
    
less_than:
    addi x14, x0, 300      # x14 = 300	p
    
continue3:
    bge  x1, x2, greater_eq # 如果x1 >= x2，跳转到greater_eq (应该跳转，10 >= 5)	p
    addi x15, x0, 4         # 不应执行
    j    io_test
    
greater_eq:
    addi x15, x0, 400      # x15 = 400	p
    
io_test:
    # 测试IO操作
    # LED地址: 0xFFFFC600
    lui  x16, 0xFFFFC      # 高20位
    addi x16, x16, 0x600   # x16 = 0xFFFFC600 (LED地址)
    addi x17, x0, 0x55     # x17 = 0x55 (交替的二进制模式)
    sw   x17, 0(x16)       # 向LED写入0x55
    
end:
    j end                  # 无限循环
    
.data
	buf: .word 0x0000
