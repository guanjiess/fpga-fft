`timescale 1ns / 1ps
module RotatorMemory8_tb();

	reg				clk;            // 时钟信号
	reg				rst;            // 复位信号
	reg				S;
	wire	[18-1:0]	rotator_real;
	wire	[18-1:0]	rotator_img;

	parameter period = 10;
	always #5 clk = ~clk;
	


	initial begin
		clk = 0;
		rst = 0;
		S = 0;
		#40
		S = 1;
		#40
		S = 0;
		#40
		S = 1;
		#40
		S = 0;
		#40
		S = 1;
	end


 RotatorMemory8 RotatorMemory8(
	.clk			(clk),
	.rst			(rst),
	.S				(S),
	.rotator_real	(rotator_real),
	.rotator_img	(rotator_img)
);

endmodule