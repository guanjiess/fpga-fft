`timescale 1ns / 1ps
module RotatorMemory8 (
	input			clk,
	input			rst,
	input			rotator_valid,
	output	[17:0]	rotator_real,
	output	[17:0]	rotator_img
);

reg		[2:0]	counter = 0		;
reg		[17:0]	rotator_real_tmp = 0;
reg		[17:0]	rotator_img_tmp = 0;
//rotator的实部虚部在0~1之间，扩大65536倍
//硬件不支持小数运算
//cos45 65536倍量化后为46341
parameter	[18-1:0]	cos45_18		= 18'b0_0_1011_0101_0000_0101;
parameter	[18-1:0]	m_cos45_18		= 18'b1_1_0100_1010_1111_1100;
parameter	[18-1:0]	one				= 18'b0_1_0000_0000_0000_0000;
parameter				WAIT_FOR_ROTATOR = 5;


parameter W0_real = one;
parameter W0_img = 0;
parameter W1_real = cos45_18;
parameter W1_img = m_cos45_18;
parameter W2_real = 0;
parameter W2_img = -65536;
parameter W3_real = m_cos45_18;
parameter W3_img = m_cos45_18;

always@(posedge clk) begin
	if(rst) begin
		counter <= 0;
	end else begin
		if(rotator_valid) begin
			counter <= counter + 1;
		end else begin
			counter <= 0;
		end
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		//复位时,数据寄存器清零
		rotator_real_tmp <= 1<<16;
		rotator_img_tmp <= 0;
	end else begin
	// 根据选择信号选择要输出的数据
		if(rotator_valid) begin 
			case (counter)
				3'b000: begin 
					rotator_real_tmp <= W0_real;
					rotator_img_tmp <= W0_img;
				end
				3'b001: begin 
					rotator_real_tmp <= W1_real;
					rotator_img_tmp <= W1_img;
				end
				3'b010: begin 
					rotator_real_tmp <= W2_real;
					rotator_img_tmp <= W2_img;
				end
				3'b011: begin 
					rotator_real_tmp <= W3_real;
					rotator_img_tmp <= W3_img;
				end
				default: begin
					rotator_real_tmp <= 1<<16; // 默认情况
					rotator_img_tmp <= 16'h0; // 默认情况
				end 
			endcase
		end else begin
			rotator_real_tmp <= 1<<16;
			rotator_img_tmp <= 0;
		end
	end
end

	assign rotator_real = rotator_real_tmp;
	assign rotator_img = rotator_img_tmp;

endmodule
