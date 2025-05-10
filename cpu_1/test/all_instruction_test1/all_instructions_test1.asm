# 全面测试程序 - 测试RISC-V指令集
# 包含RV32I指令集中所有支持的指令

.text
.globl main

main:
    # ======= 初始化测试数据 =======
    addi x1, x0, 10        # x1 = 10
    addi x2, x0, 5         # x2 = 5
    lui  x3, 0x12345       # x3 = 0x12345000
    addi x4, x0, -20       # x4 = -20 (测试负数)
    
    # ======= 测试R型算术指令 =======
    # ADD, SUB
    add  x5, x1, x2        # x5 = 10 + 5 = 15
    sub  x6, x1, x2        # x6 = 10 - 5 = 5
    sub  x7, x2, x1        # x7 = 5 - 10 = -5 (测试负结果)
    
    # 测试逻辑运算
    or   x8, x1, x2        # x8 = 10 | 5 = 15
    and  x9, x1, x2        # x9 = 10 & 5 = 0
    xor  x10, x1, x2       # x10 = 10 ^ 5 = 15
    
    # 测试移位指令
    addi x11, x0, 1        # x11 = 1
    sll  x12, x11, x2      # x12 = 1 << 5 = 32
    srl  x13, x3, x11      # x13 = 0x12345000 >> 1 = 0x091A2800
    
    # 测试算术右移 (符号扩展)
    addi x14, x0, -1024    # x14 = -1024
    sra  x15, x14, x11     # x15 = -1024 >>> 1 = -512 (保留符号位)
    
    # 测试比较指令
    slt  x16, x2, x1       # x16 = (5 < 10) ? 1 : 0 = 1
    slt  x17, x1, x2       # x17 = (10 < 5) ? 1 : 0 = 0
    sltu x18, x2, x1       # x18 = (5 < 10) ? 1 : 0 = 1 (无符号)
    sltu x19, x4, x1       # x19 = (-20 < 10) ? 1 : 0 = 0 (无符号,-20被视为大正数)
    
    # ======= 测试I型指令 =======
    # 立即数算术和逻辑运算
    addi x20, x1, 100      # x20 = 10 + 100 = 110
    andi x21, x1, 0xF      # x21 = 10 & 0xF = 10
    ori  x22, x1, 0xF      # x22 = 10 | 0xF = 15
    xori x23, x1, 0xFF     # x23 = 10 ^ 0xFF = 0xF5 = 245
    
    # 立即数移位
    slli x24, x1, 4        # x24 = 10 << 4 = 160
    srli x25, x3, 8        # x25 = 0x12345000 >> 8 = 0x00123450
    srai x26, x4, 2        # x26 = -20 >>> 2 = -5 (保留符号位)
    
    # 立即数比较
    slti  x27, x1, 20      # x27 = (10 < 20) ? 1 : 0 = 1
    slti  x28, x1, 5       # x28 = (10 < 5) ? 1 : 0 = 0
    sltiu x29, x1, 20      # x29 = (10 < 20) ? 1 : 0 = 1 (无符号)
    sltiu x30, x4, 10      # x30 = (-20 < 10) ? 1 : 0 = 0 (无符号,-20被视为大正数)
    
    # ======= 测试加载指令 =======
    # 先存储一些数据
    lui  x31, 0x80000      # 用于测试地址基址
    addi x31, x31, 0x100   # x31 = 基址地址
    
    sw   x1, 0(x31)        # mem[addr+0] = 10 (0x0000000A)
    sh   x2, 4(x31)        # mem[addr+4] = 5 (低16位)
    sb   x4, 6(x31)        # mem[addr+6] = -20 (低8位,截断为0xEC)
    
    # 测试各种加载
    lw   x5, 0(x31)        # x5 = mem[addr+0] = 10
    lh   x6, 4(x31)        # x6 = mem[addr+4] = 5 (符号扩展)
    lb   x7, 6(x31)        # x7 = mem[addr+6] = -20 (符号扩展)
    lbu  x8, 6(x31)        # x8 = mem[addr+6] = 0xEC (零扩展为0x000000EC = 236)
    lhu  x9, 4(x31)        # x9 = mem[addr+4] = 0x0005 (零扩展)
    
    # ======= 测试AUIPC和LUI =======
    auipc x10, 0x12345     # x10 = PC + (0x12345 << 12)
    lui   x11, 0x54321     # x11 = 0x54321000
    
    # ======= 测试分支指令 =======
    # BEQ和BNE
    beq  x1, x1, beq_target    # 相等,应跳转
    addi x12, x0, 999          # 如果跳转成功，不会执行
    
beq_target:
    addi x12, x0, 111          # x12 = 111
    
    bne  x1, x2, bne_target    # 不相等,应跳转
    addi x13, x0, 999          # 如果跳转成功，不会执行
    
bne_target:
    addi x13, x0, 222          # x13 = 222
    
    # BLT和BGE
    blt  x2, x1, blt_target    # 5 < 10,应跳转
    addi x14, x0, 999          # 如果跳转成功，不会执行
    
blt_target:
    addi x14, x0, 333          # x14 = 333
    
    bge  x1, x2, bge_target    # 10 >= 5,应跳转
    addi x15, x0, 999          # 如果跳转成功，不会执行
    
bge_target:
    addi x15, x0, 444          # x15 = 444
    
    # BLTU和BGEU (无符号比较)
    bltu x2, x1, bltu_target   # 5 < 10 (无符号),应跳转
    addi x16, x0, 999          # 如果跳转成功，不会执行
    
bltu_target:
    addi x16, x0, 555          # x16 = 555
    
    bgeu x1, x2, bgeu_target   # 10 >= 5 (无符号),应跳转
    addi x17, x0, 999          # 如果跳转成功，不会执行
    
bgeu_target:
    addi x17, x0, 666          # x17 = 666
    
    # 负数无符号比较测试
    bltu x1, x4, bltu_special  # 10 < -20 (无符号,实际是10 < 大正数),不应跳转
    addi x18, x0, 777          # x18 = 777
    j    bgeu_special_test
    
bltu_special:
    addi x18, x0, 999          # 不应执行
    
bgeu_special_test:
    bgeu x4, x1, bgeu_special  # -20 >= 10 (无符号,实际是大正数 >= 10),应跳转
    addi x19, x0, 999          # 如果跳转成功，不会执行
    
bgeu_special:
    addi x19, x0, 888          # x19 = 888
    
    # ======= 测试跳转和链接指令 =======
    jal  x20, jal_target      # 跳转并将返回地址(PC+4)保存到x20
    addi x21, x0, 999         # 不应执行，因为下一条被执行的指令是jal_target处
    
jal_target:
    addi x21, x0, 100         # x21 = 100
    
    # 现在x20包含的是jal跳转后的返回地址
    jalr x22, 0(x20)          # 使用x20中的地址跳回,并将返回地址(PC+4)保存到x22
    
    # 上述jalr将跳回到这里
    addi x23, x0, 200         # x23 = 200
    
    # ======= 测试存储指令和向IO设备写入 =======
    # IO地址
    lui  x25, 0xFFFFC         # IO地址基址高20位
    addi x26, x0, 0x55        # 数据0x55 (0b01010101)
    
    # LED地址 = 0xFFFFC600
    addi x25, x25, 0x600      # x25 = 0xFFFFC600 (LED地址)
    sw   x26, 0(x25)          # 向LED写入0x55
    
    # 开关地址 = 0xFFFFC700
    addi x25, x25, 0x100      # 将x25修改为0xFFFFC700 (开关地址)
    lw   x27, 0(x25)          # 读取开关状态到x27
    
    # 数码管地址 = 0xFFFFC700 (与开关共用地址)
    # 向数码管显示写入值
    addi x28, x0, 0xABCD     # 显示数据
    sw   x28, 0(x25)         # 向数码管写入0xABCD
    
    # ======= 系统调用指令测试 =======
    # 注意：ecall和ebreak可能在仿真中需要特殊处理
    # ecall                   # 调用操作系统功能
    # ebreak                  # 调试断点

end_loop:
    j end_loop               # 无限循环

.data
buffer: .word 0, 0, 0, 0, 0  # 预留一些空间用于存储
    
# 测试结果总结:
# x5 = 15 (add)
# x6 = 5 (sub)
# x7 = -5 (sub 负数结果)
# x8 = 15 (or)
# x9 = 0 (and)
# x10 = 15 或 PC+立即数 (xor 或 auipc)
# x11 = 1 或 0x54321000 (addi 或 lui)
# x12 = 111 (beq成功)
# x13 = 222 (bne成功)
# x14 = 333 (blt成功)
# x15 = 444 (bge成功)
# x16 = 555 (bltu成功)
# x17 = 666 (bgeu成功)
# x18 = 777 (bltu特殊情况)
# x19 = 888 (bgeu特殊情况)
# x20 = 跳转返回地址
# x21 = 100 (jal目标)
# x22 = jalr返回地址
# x23 = 200 (jalr后执行)
# x25-x28 = IO相关值 