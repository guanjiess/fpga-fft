`timescale 1ns / 1ps
module fft_2_tb();

	reg				clk;
	reg				rst;
	wire			valid;
	wire[32-1:0]	data_real;
	wire[32-1:0]	data_img;
	wire[32-1:0]	out_real2;
	wire[32-1:0]	out_img2;
	wire			w_start2;
	wire			w_end2;

	parameter period = 10;
	initial begin
		clk = 1;
		rst = 1;
		#30
		rst = 0;
	end
	always #(period/2) clk = ~clk;

fft_2 fft_2(
	.clk		(	clk),
	.rst		(	rst),
	.A_real		(	data_real),
	.A_img		(	data_img),
	.start2		(w_start2),
	.end2		(w_end2),
	.out_real2	(	out_real2),
	.out_img2	(	out_img2),
	.out_start	()
);


data_gen #(.layer (3))
data_gen4(
	.clk		(clk),
	.rst		(rst),
	.data_real	(data_real),
	.data_img	(data_img),
	.valid		(valid),
	.start		(w_start2),
	.over		(w_end2)
	);


endmodule