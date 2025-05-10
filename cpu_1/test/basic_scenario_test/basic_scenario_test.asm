# RISC-V基本测试场景1
.text
.globl main

main:
    # 初始化寄存器用于存储开关输入值
    addi s0, x0, 0     # s0用于存储案例编号
    addi s1, x0, 0     # s1用于存储测试数据a
    addi s2, x0, 0     # s2用于存储测试数据b
    addi s3, x0, 200   # s3用于存储数据a和b在内存中的基地址,a在0(s3),b在1(s3)
io_load_case:
	# 读取开关值：开关读取地址设置为0xFFFFC700
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # 开关地址高20位
	addi t0, t0, 0x700 # t0 = 0xFFFFC700 (开关地址)
	lw t1, 0(t0)       # 读取开关状态
    
	# 提取案例编号
	andi s0, t1, 0x7   # 取低3位作为案例编号(x2,x1,x0)
	#srli t2, t1, 3     # 右移3位，提取sw7-sw0的值
	#andi s1, t2, 0xFF  # 取低8位作为测试数据
    
	# 根据案例编号跳转到对应处理流程
	beq s0, x0, case0     # 3'b000(0): 简单显示
	addi t0, x0, 1
	beq s0, t0, case1     # 3'b001(1): LB存储显示
	addi t0, x0, 2
	beq s0, t0, case2     # 3'b010(2): LBU存储显示
	addi t0, x0, 3
	beq s0, t0, case3     # 3'b011(3): BEQ比较
	addi t0, x0, 4
	beq s0, t0, case4     # 3'b100(4): BLT比较
	addi t0, x0, 5
 	beq s0, t0, case5     # 3'b101(5): BLTU比较
 	addi t0, x0, 6
  	beq s0, t0, case6     # 3'b110(6): SLT比较
  	j case7               # 3'b111(7): SLTU比较

case0:
	# 读取开关值：开关读取地址设置为0xFFFFC700
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # 开关地址高20位
	addi t0, t0, 0x700 # t0 = 0xFFFFC700 (开关地址)
	lw t1, 0(t0)       # 读取开关状态
	# 提取测试数据
	srli t2, t1, 3     # 右移3位，提取sw0-sw7的值
	andi s1, t2, 0xFF  # 取低8位作为测试数据存到s1
	# LED地址设置为0xFFFFC600
	sub t0,t0,t0	#t0寄存器归零
 	lui t0, 0xFFFFC    # LED地址高20位
 	addi t0, t0, 0x600 # t0 = 0xFFFFC600 (LED地址)
 	# 显示a
 	sw s1, 0(t0)       # 向LED写入s1的数据
	j io_load_case

case1:
	# 读取开关值：开关读取地址设置为0xFFFFC700
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # 开关地址高20位
	addi t0, t0, 0x700 # t0 = 0xFFFFC700 (开关地址)
	lw t1, 0(t0)       # 读取开关状态
	# 提取测试数据a
	srli t2, t1, 3     # 右移3位，提取sw0-sw7的值
	andi s1, t2, 0xFF  # 取低8位作为测试数据存到s1
	sw s1,0(s3)	#将a存入内存的0(s3)位置
	# 加载并显示
  	lb t1, 0(s3)       # 使用lb加载(符号扩展)
	# 显示到数码管
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # 数码管地址高20位
	addi t0, t0, 0x500 # t0 = 0xFFFFC500 (数码管地址)
 	sw t1, 0(t0)       # 将带符号扩展的值显示到数码管
	j io_load_case
case2:
	# 读取开关值：开关读取地址设置为0xFFFFC700
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # 开关地址高20位
	addi t0, t0, 0x700 # t0 = 0xFFFFC700 (开关地址)
	lw t1, 0(t0)       # 读取开关状态
	# 提取测试数据b
	srli t2, t1, 3     # 右移3位，提取sw0-sw7的值
	andi s1, t2, 0xFF  # 取低8位作为测试数据存到s1
	sw s1,1(s3)	#将b存入内存的1(s3)位置
	# 加载并显示
  	lb t1, 1(s3)       # 使用lb加载(符号扩展)
	# 显示到数码管
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # 数码管地址高20位
	addi t0, t0, 0x500 # t0 = 0xFFFFC500 (数码管地址)
 	sw t1, 0(t0)       # 将带符号扩展的值显示到数码管
	j io_load_case
	
#用 beq 比较 测试数 a 和 测试数 b（来自于用例1和用例2），如果关系成立，点亮8个led，关系不成立，8个led都熄灭
case3:
	# LED地址设置为0xFFFFC600
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # LED地址高20位
	addi t0, t0, 0x600 # t0 = 0xFFFFC600 (LED地址)
	# 从内存中加载a和b
	lb s1,0(s3)	#加载a到s1
	lb s2,1(s3)	#加载b到s2
	# 比较a和b
	beq s1, s2, case3_true
	# 不相等: 所有LED全灭
	sw x0, 0(t0)       # 向LED写入0
	j io_load_case
case3_true:
	# 相等: 点亮所有8个LED
	addi t1, x0, 0xFF  # 所有8位都为1
	sw t1, 0(t0)       # 向LED写入0xFF
	j io_load_case
	
#用 blt 比较 测试数 a 和 测试数 b（来自于用例1和用例2），如果关系成立，点亮8个led，关系不成立，8个led都熄灭
case4:
	# LED地址设置为0xFFFFC600
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # LED地址高20位
	addi t0, t0, 0x600 # t0 = 0xFFFFC600 (LED地址)
	# 从内存中加载a和b
	lb s1,0(s3)	#加载a到s1
	lb s2,1(s3)	#加载b到s2
	# 比较a和b
	blt s1,s2,case4_true
	# 不成立: 所有LED全灭
	sw x0, 0(t0)       # 向LED写入0
	j io_load_case
case4_true:
	# 成立: 点亮所有8个LED
	addi t1, x0, 0xFF  # 所有8位都为1
	sw t1, 0(t0)       # 向LED写入0xFF
	j io_load_case
	
#用 bltu 比较 测试数 a 和 测试数 b（来自于用例1和用例2），如果关系成立，点亮8个led，关系不成立，8个led都熄灭
case5:
	# LED地址设置为0xFFFFC600
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # LED地址高20位
	addi t0, t0, 0x600 # t0 = 0xFFFFC600 (LED地址)
	# 从内存中加载a和b
	lb s1,0(s3)	#加载a到s1
	lb s2,1(s3)	#加载b到s2
	# 比较a和b
	bltu s1,s2,case5_true
	# 不成立: 所有LED全灭
	sw x0, 0(t0)       # 向LED写入0
	j io_load_case
case5_true:
	# 成立: 点亮所有8个LED
	sub t1,t1,t1 #t1寄存器归零
	addi t1, x0, 0xFF  # 所有8位都为1
	sw t1, 0(t0)       # 向LED写入0xFF
	j io_load_case

#用 slt 比较 测试数 a 和 测试数 b（来自于用例1和用例2），通过store指令将比较结果输出到led
#如果关系成立，点亮1个led，关系不成立，该led熄灭
case6:
	# LED地址设置为0xFFFFC600
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # LED地址高20位
	addi t0, t0, 0x600 # t0 = 0xFFFFC600 (LED地址)
	# 从内存中加载a和b
	lb s1,0(s3)	#加载a到s1
	lb s2,1(s3)	#加载b到s2
	# 比较a和b
	slt t1,s1,s2
	beq t1,x0,case6_true
	# 不成立: 所有LED全灭
	sw x0, 0(t0)       # 向LED写入0
	j io_load_case
case6_true:
	# 成立: 点亮所有1个LED
	sub t1,t1,t1 #t1寄存器归零
	addi t1, x0, 1  # t1设置位1
	sw t1, 0(t0)       # 向LED写入1
	j io_load_case

#用 sltu 比较 测试数 a 和 测试数 b（来自于用例1和用例2），通过store指令将比较结果输出到led，如果关系成立，点亮1个led，关系
#不成立，该led熄灭
case7:
	# LED地址设置为0xFFFFC600
	sub t0,t0,t0	#t0寄存器归零
	lui t0, 0xFFFFC    # LED地址高20位
	addi t0, t0, 0x600 # t0 = 0xFFFFC600 (LED地址)
	# 从内存中加载a和b
	lb s1,0(s3)	#加载a到s1
	lb s2,1(s3)	#加载b到s2
	# 比较a和b
	sltu t1,s1,s2
	beq t1,x0,case7_true
	# 不成立: 所有LED全灭
	sw x0, 0(t0)       # 向LED写入0
	j io_load_case
case7_true:
	# 成立: 点亮所有1个LED
	sub t1,t1,t1 #t1寄存器归零
	addi t1, x0, 1  # t1设置位1
	sw t1, 0(t0)       # 向LED写入1
	j io_load_case
	
.data
memory_space: .space 1024    # 预留1KB内存空间用于数据存储 
