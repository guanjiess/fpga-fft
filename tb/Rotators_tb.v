`timescale 1ns / 1ps
module Rotators_tb();

	reg					clk;            // 时钟信号
	reg					rst;            // 复位信号
	reg					S;
	reg					triger;
	wire	[18-1:0]	w_rotator_real;
	wire	[18-1:0]	w_rotator_img;

	parameter period = 10;
	always #(period/2) clk = ~clk;


	initial begin
		clk = 0;
		rst = 1;
		S = 0;
		#80
		rst = 0;
		S = 1;
		#80
		S = 0;
	end
Rotator16 Rotator16 (
	.clk				(		clk				),
	.rst				(		rst				),
	.S					(		S				),
	.triger				(		triger			),
	.rotator_real		(		w_rotator_real	),
	.rotator_img		(		w_rotator_img	)
);

endmodule