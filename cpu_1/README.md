# 单周期CPU设计项目

## 项目简介
本项目实现了一个基于RISC指令集架构的单周期CPU，可以执行基本的算术逻辑运算、访存操作、分支和跳转指令。CPU采用模块化设计，各功能单元清晰划分，便于理解和维护。

## CPU结构图

<img src=".\图片\image-20250501032207713.png" alt="image-20250428211027924" style="zoom: 80%;" />
## 核心组件说明

### 基本功能模块

1. **指令提取模块(instruction_fetch)**

   > 冯俊铭

   * 功能：提取已存储的程序指令

   * 输入：PC值(地址)，

   * 输出：当前地址的32位指令

   * 功能测试`instruction_fetch_tb`：

     - 初始化及顺序读取测试

       <img src=".\图片\image-20250428211027924.png" alt="image-20250428211027924" style="zoom: 55%;" />

     - 跳转测试

       <img src=".\图片\image-20250428210625977.png" alt="image-20250428210625977" style="zoom: 45%;" />

2. **控制单元(Control Unit)**

   > 周子希

   - 功能：解码指令并生成各种控制信号

   - 输入：指令的opcode, funct3, funct7字段

   - 输出：ALU操作码、寄存器写使能、ALU源选择、存储器读写使能等控制信号

   - 功能测试

     （对各类型指令的测试均正确）

     <img src=".\图片\control_unit_tb.png" alt=".\图片\control_unit_tb" style="zoom: 80%;" />

     TCL窗口信息:

     <img src=".\图片\control_unit_tb_tcl.png" alt=".\图片\control_unit_tb_tcl" style="zoom: 55%;" />

3. **寄存器堆(Register File)**

   > 苏思齐

   - 功能：存储和管理32个通用寄存器

   - 输入：读寄存器地址(rs1, rs2)，写寄存器地址(rd)，写数据，写使能

   - 输出：两个读出的寄存器数据

   - 功能测试

   - <img src=".\图片\alu_test_5_6.png" alt=".\图片\alu_test_5_6.png" style="zoom: 80%;" />

     > 5.8修改：手动实现ip core，解决了延迟（credit:冯

     ![](D:\cpu_proj_5_8\25Spring-ComputerDesign-Project-5.8-3-\25Spring-ComputerDesign-Project-5.8-3-\cpu_1\图片\5_8_updated.png)

     图为解决延迟后的testbench波形。

4. **ALU(算术逻辑单元)**

   > 苏思齐

   - 功能：执行算术和逻辑运算
   - 输入：两个操作数，ALU操作码
   - 输出：运算结果，零标志
   - 功能测试
   - <img src=".\图片\alu_test_5_6.png" alt=".\图片\alu_test_5_6.png" style="zoom: 80%;" />

5. **数据存储器(Data Memory)**

   > 直接使用IP核

   - 功能：存储和读取数据
   - 输入：地址，写数据，读/写使能
   - 输出：读取的数据

6. **立即数生成器(Immediate Generator)**

   > 周子希

   - 功能：从指令中提取并扩展立即数

   - 输入：指令

   - 输出：扩展后的立即数

   - 功能测试

     （对各类型指令，包括I-type中的正负数imm等情况均进行了测试，均正确。）

     <img src=".\图片\Imm_gen_tb.png" alt=".\图片\Imm_gen_tb.png" style="zoom: 70%;" />

     TCL窗口信息：

     <img src=".\图片\imm_gen_tb_tcl.png" alt=".\图片\imm_gen_tb_tcl.png" style="zoom: 50%;" />

### 多路复用器(MUX)

> 冯俊铭

1. **ALU输入多路复用器(alu_input2_mux)**
   - 功能：选择ALU的第二个输入是寄存器数据还是立即数
   - 输入： `reg_data2 `寄存器的第二个输出，`imm `立即数,`alu_src` ALU输入控制信号
   - 输出：`alu_input2`ALU的第二个输入
   - 场景：
     - 当执行R型指令(如add)时，选择寄存器数据
     - 当执行I型指令(如addi)时，选择立即数
     - 计算存储/加载指令的地址时，选择立即数偏移量
2. **写回多路复用器(mux_writeback)**
   - 功能：选择写回到寄存器的数据来源
   - 输入：`alu_result` ALU结果,`mem_data` 存储器数据,`mem_to_reg` 寄存器写入源选择
   - 输出：`write_data  `  写回数据
   - 应用场景：
     - 选择ALU结果(算术逻辑指令)
     - 选择存储器数据(加载指令)
     - 选择PC+4(链接跳转指令保存返回地址)
     - 选择立即数(加载立即数指令)
3. **结果多路复用器(mux_result)** //todo
   - 功能：选择CPU的最终输出结果
   - 应用场景：
     - 测试不同类型指令的执行结果
     - 观察CPU不同组件的输出值
     - 用于调试和可视化CPU内部状态

## 指令支持

本CPU支持以下RISC指令类型：
- R型指令：寄存器-寄存器算术逻辑运算(ADD, SUB, AND, OR, XOR等)
- I型指令：立即数算术逻辑运算(ADDI, SLTI等)和加载指令(LW等)
- S型指令：存储指令(SW等)
- B型指令：条件分支指令(BEQ, BNE, BLT等)
- J型指令：无条件跳转指令(JAL)
- U型指令：上部立即数加载指令(LUI, AUIPC)

## 代码规范

### 1. 结构化设计规范

#### 1.1 模块组织
- 每个功能模块应单独定义，便于测试和复用
- 模块接口应清晰定义输入和输出端口
- 模块名称应反映其功能（如`alu`, `register_file`, `control_unit`等）
- 顶层模块应统一管理各子模块的连接

#### 1.2 层次结构
- 采用自顶向下的设计方法，先定义顶层模块再实现子模块
- 子模块应根据功能进行合理划分
- 避免模块之间不必要的循环依赖

### 2. 统一的命名方式

#### 2.1 模块命名
- 模块名使用小写字母加下划线，如`control_unit`
- 模块名应简洁且能反映模块功能

#### 2.2 信号命名
- 信号名应使用小写字母加下划线
- 时钟信号统一命名为`clk`
- 复位信号统一命名为`rst`
- 控制信号应添加功能后缀，如`xxx_en`（使能）、`xxx_sel`（选择）
- 多位信号使用复数或添加位宽说明，如`registers`或`data_32bit`
- 模块间连接信号应采用一致的命名方式

#### 2.3 参数命名
- 参数名使用大写字母加下划线，如`ALU_ADD`
- 参数值应使用有意义的常量，避免魔法数字

### 3. 注释要求

#### 3.1 模块注释
- 每个模块应包含以下注释：
  - 模块功能描述
  - 输入输出端口说明
  - 设计考虑和约束

#### 3.2 信号注释
- 关键信号定义应包含简要注释说明其用途
- 复杂信号或特殊处理应有详细说明

#### 3.3 代码逻辑注释
- 复杂逻辑块应添加说明性注释
- always块、case语句、条件判断等关键结构应说明其目的
- 特殊处理或技巧应详细注释

### 4. 符号化常量定义

#### 4.1 指令编码
- 指令类型应使用参数定义，如：
```verilog
parameter R_TYPE     = 7'b0110011;
parameter I_TYPE_ALU = 7'b0010011;
```

#### 4.2 操作码
- ALU操作码、控制信号等应使用参数定义：
```verilog
parameter ALU_ADD = 4'b0000;
parameter ALU_SUB = 4'b0001;
```

### 5. 代码格式规范

#### 5.1 缩进
- 统一使用4个空格缩进
- 嵌套结构应保持清晰的缩进层次

#### 5.2 空行
- 模块之间用空行分隔
- 功能块之间用空行分隔
- 相关的变量声明可以不用空行

#### 5.3 对齐
- 端口声明应垂直对齐
- 赋值语句应适当对齐，提高可读性

### 6. 外设接口规范

#### 6.1 按键接口
- 按键信号应进行去抖处理
- 明确定义按键功能及对应效果

#### 6.2 显示接口
- LED和数码管接口应定义清晰
- 定义显示内容与CPU内部状态的对应关系

#### 6.3 IO地址映射
- IO设备地址映射应明确定义
- 避免使用lab提供的默认地址，自行指定地址

## 测试场景

本CPU设计支持两个基本测试场景：

### 测试场景1（实现相对简单，占测试场景分值的20%）
- 使用按键输入和LED输出测试基本功能
- 支持多种操作的比较测试，如beq、blt、bltu等指令

### 测试场景2（实现相对复杂，占测试场景分值的80%）
- 支持数据存储、读取和处理
- 支持浮点数输入和处理
- 实现CRC校验等复杂功能

## 团队信息

- 项目名称：单周期CPU设计
- 开发时间：2025年春季学期
- 课程：计算机设计与实践
- 学校：南方科技大学 



## 其他信息

### 5.8 - CPU 设计修改：JAL/JALR/LUI/AUIPC 指令处理优化

> 冯俊铭 5.8

**目标：** 确保 JAL, JALR, LUI, 和 AUIPC 指令能够正确执行，并将预期结果写回目标寄存器。本次修改的核心思想是将所有寄存器的写回数据选择逻辑集中在 `mem_or_io` 模块中，通过 `control_unit` 产生新的控制信号进行协调。

**主要修改模块：**

1.  `control_unit.v`
2.  `mem_or_io.v`
3.  `top.v`

---

#### `control_unit.v` 的修改

**新增输出端口：**

*   `output reg alu_src_1;`: 用于为 AUIPC 指令选择 ALU 的第一个输入源。
    *   `0`: 选择 `reg_data1` (默认)
    *   `1`: 选择 `PC`
*   `output reg [1:0] wb_select;`: 用于指示 `mem_or_io` 模块选择哪个数据源写回寄存器。
    *   `2'b00`: ALU 计算结果
    *   `2'b01`: 从数据内存或 IO 设备读取的数据
    *   `2'b10`: `PC + 4`
    *   `2'b11`: 立即数 (主要用于 LUI)

**主要逻辑修改 (`always @(*)`块内)：**

*   **JAL 和 JALR 指令 (`opcode == 7'b1101111` 或 `7'b1100111`)**:
    *   `reg_write_en = 1'b1;`
    *   `jump = 1'b1;`
    *   `wb_select = 2'b10;` (选择 `PC + 4` 进行写回)
    *   对于 JALR，`alu_src_2 = 1'b1;` 以便 ALU 计算 `rs1 + imm` 作为下一个 PC 值（注意：这个ALU计算结果不用于写回 `rd`）。
    *   `alu_op` 对于 JALR 的 `rd` 写回路径不关键，对于 JAL 的 `rd` 写回路径也不关键。

*   **LUI 指令 (`opcode == 7'b0110111`)**:
    *   `reg_write_en = 1'b1;`
    *   `wb_select = 2'b11;` (选择立即数 `imm` 进行写回)。
    *   `alu_src_1`, `alu_src_2`, `alu_op` 对于 LUI 指令写回 `rd` 的路径不是必需的，因为结果直接来自立即数。

*   **AUIPC 指令 (`opcode == 7'b0010111`)**:
    *   `reg_write_en = 1'b1;`
    *   `alu_src_1 = 1'b1;` (ALU 的第一个输入选择 `PC`)。
    *   `alu_src_2 = 1'b1;` (ALU 的第二个输入选择 `imm`)。
    *   `alu_op = 2'b00;` (使 `alu_control` 模块产生 ALU 加法操作)。
    *   `wb_select = 2'b00;` (选择 ALU 的计算结果 `PC + imm` 进行写回)。

*   **其他指令类型的 `wb_select` 设置**:
    *   R-type 和 I-type 算术/逻辑指令: `wb_select = 2'b00;` (写回 ALU 结果)。
    *   Load 指令: `wb_select = 2'b01;` (写回从内存/IO 读取的数据)。
    *   Store 和 Branch 指令: 不写回寄存器，`reg_write_en = 1'b0;`，`wb_select` 为默认值或不关心。

---

#### `mem_or_io.v` 的修改

**新增输入端口：**

*   `input wire [31:0] pc_plus4;`: 从 `top.v` 传入 `PC + 4` 的值。
*   `input wire [31:0] imm;`: 从 `top.v` 传入由 `immediate_gen` 生成的立即数。
*   `input wire [1:0] wb_select;`: 从 `control_unit.v` 传入的写回数据源选择信号。

**主要逻辑修改 (`always @(*)`块内)：**

*   **核心写回选择逻辑**:
    *   一个 `case (wb_select)` 语句根据 `wb_select` 的值，选择以下数据源之一赋给 `output reg [31:0] r_wdata`：
        *   `2'b00`: `addr_in` (即 ALU 的计算结果)
        *   `2'b01`: `data_from_mem_or_io_source` (从数据内存或 IO 设备读取的数据，此内部信号逻辑保持不变)
        *   `2'b10`: `pc_plus4` (传入的 `PC + 4` 值)
        *   `2'b11`: `imm` (传入的立即数值)
*   `r_wdata` 作为模块的输出，将直接连接到寄存器堆的写数据端口。

---

#### `top.v` 的修改

**主要连接和逻辑调整：**

*   **控制信号传递**：
    *   `control_unit` 输出的 `alu_src_1` 和 `wb_select` 信号被正确连接。
*   **ALU 输入1 的选择**：
    *   增加了一个 `mux_alu_input` 实例 (`umux_alu_input1`)。
    *   该 MUX 根据 `alu_src_1` 的值选择 `reg_data1` 或 `pc` 作为 ALU 的第一个输入 (`alu_input1`)。这主要服务于 AUIPC 指令。
*   **数据传递到 `mem_or_io`**：
    *   `ifetch` 模块输出的 `pc_plus4` 值连接到 `mem_or_io` 模块的 `pc_plus4` 输入。
    *   `immediate_gen` 模块输出的 `imm` 值连接到 `mem_or_io` 模块的 `imm` 输入。
*   **写回数据路径**：
    *   `mem_or_io` 模块输出的 `r_wdata` 直接连接到 `register_file` 模块的 `write_data` 输入端口。
    *   不再需要在 `top.v` 中实例化一个独立的4选1写回MUX。

