## 顶层模块

### 内部模块

![1697624146755](.\design-document.assets\1697624146755.png)

包括：每一级各包含数个模块

### 接口设计

| 接口     | 类型 | 功能描述 | 注                                       |
| -------- | ---- | -------- | ---------------------------------------- |
| clk      | in   | 时钟     |                                          |
| rst      | in   | 复位     |                                          |
| data_in  | in   | 输入数据 | <font size=2>分实部、虚部两路输出</font> |
| config   | in   | 配置级数 | <font size=2>条件不成熟</font>           |
| start    | in   | fft启动  |                                          |
| data_out | out  | fft结果  |                                          |
| first    | out  | 首个输出 |                                          |
| last     | out  | 最后输出 |                                          |

**可参考**

<img src=".\design-document.assets\1697630478348.png" alt="1697630478348" style="zoom:67%;" />

IP手册：[手册](./pg109-xfft.pdf)

### 时序

<img src=".\fft-design-document.assets\1699883524968.png" alt="1699883524968" style="zoom:67%;" />

## FFT子模块

### fft2

接口、时序

### fft4

接口

时序

### fft8

接口

时序

==注意==：2、4、8点fft逻辑比较简单，不需要使用大量的RAM进行时延操作，但是核心时序和较高层次的模块之间时相同的。

###fft16及高层模块

| 功能子模块需求    | 功能                               |
| ----------------- | ---------------------------------- |
| butterfly_general | 进行蝶形运算，输出蝶形运算后的结果 |
| butterfly         | 进行运算的子模块                   |
| Rotator           | 输出FFT需要的旋转因子              |
| Delay             | 对数据做时延                       |
| Multiplier        | 将时延的数据和旋转因子相乘         |



![1699886206322](E:\master2\coding_notes\fpga\fft-design-document.assets\1699886206322.png)

==fft32之后的模块组成==

1. **接口**

```verilog
module fft_32(
	input				clk,
	input				rst,
	input				start,
	input				over,
	input	[32-1:0]	data_in_real,
	input	[32-1:0]	data_in_img,
	output	[32-1:0]	data_out_real,
	output	[32-1:0]	data_out_img,
	output				start_next,
	output				end_next
);
```

2. 内部子模块包括

- butterfly_general
- Rotator_address以及两个存储旋转因子的rom，分别存储实部、虚部，如`rotator_32_real`，Rotator_address生成地址，从rom里读出数据
- multiplier，乘法器模块，将butterfly_general的输出与rom输出的旋转因子相乘，得到最终输出结果。
- 各子模块接口设计如下

```verilog
module butterfly_general #(parameter layer = 5)(
	input				clk,
	input				rst,
	input				data_in_start,
	input				data_in_end,
	input	[31:0]		A_real,
	input	[31:0]		A_img,
	output				next_level_start,
	output	[31:0]		D_real,
	output	[31:0]		D_img,
	output				data_out_first,
	output				data_out_last,
	output				rotator_valid
);
    
module Rotator_address #(parameter layer = 5)(
	input			clk,
	input			rst,
	input			rotator_valid,
	output	[12:0]	rotator_addr,
	output			select
);
```







## 功能子模块

### butterfly

接口

```verilog
module butterfly(
	input			clk			,
	input			rst			,
	input			S			,
	input			enable		,
	input[32-1:0]	A_real		,
	input[32-1:0]	A_img		,
	input[32-1:0]	C_real,
	input[32-1:0]	C_img,
	output[32-1:0]	B_real,
	output[32-1:0]	B_img,
	output[32-1:0]	D_real,
	output[32-1:0]	D_img
 );
```

时序，见上图2-5

**已完成**

### Rotator

功能描述：用于存储傅里叶变换需要的旋转因子，实部、虚部需要用两个的coe文件初始化两个ROM。

**接口**

```verilog
module Rotator #(parameter layer = 1)(
	input				clk,
	input				rst,
	input				rotator_valid,
	output		[31:0]	dout_real,
	output		[31:0]	dout_img，
	output				out_first，
	output				out_last
);
```

注：

1. xilinx的rom IP读数据时有2个clk的延时，在移植到安路或者其他平台时，需要先对rom读取数据的时间做验证。
2. 需要在fft模块对rotator_valid输入的时序做调整，使旋转因子的输出和蝶形运算模块的输出对齐
3. 输入的rotator_valid必须持续若干个数据帧长，比如做16点的FFT，rotator_valid维持的时钟数量应该是16的整数倍。数据帧长不够则补零。

**时序**

![1699930992779](.\fft-design-document.assets\1699930992779.png)

以16点fft为例。

### Delay

接口

```verilog
module delay #(parameter layer = 1)(
	input				clk,
	input				rst,
	input		[31:0]	din_real,
	input		[31:0]	din_img,
	input				wea,
	output		[31:0]	dout_real,
	output		[31:0]	dout_img，
	output		[31:0]	out_first，
	output		[31:0]	out_last
);
```

时序如下

![1699521145053](.\fft-design-document.assets\1699521145053.png)

端口描述

- wea=1时，写入的数据才有效
- 输出的第一个数据会伴随着一个out_first脉冲；最后一个数据有out_last脉冲
- 延时量可配置，对于n级layer，其==输出的数据较输入数据延时2^n-1^-1个时钟==
- 应该确认上图中箭头两端的数据一致

时序设计可能不太合理。

### Multiplier

做复数乘法。

### Reverse

对最终的输出结果进行倒序操作，还没有具体的思路。

## tb





##提示

如果要快速弄明白这套程序，你应该

1. 看这个文档
2. 把程序涉及的算法推导一遍
3. 动手画一画4点、8点FFT时序
4. 跑一下仿真，熟悉一下算法的时序，逐个信号地去看时序。
5. 开始coding debug