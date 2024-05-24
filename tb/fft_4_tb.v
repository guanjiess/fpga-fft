`timescale 1ns / 1ps
module fft_4_tb();

	reg				clk;
	reg				rst;
	wire			valid;
	wire[32-1:0]	data_real;
	wire[32-1:0]	data_img;
	wire[32-1:0]	out_real4;
	wire[32-1:0]	out_img4;
	wire			w_start;
	wire			w_ending;

	parameter period = 10;
	initial begin
		clk = 1;
		rst = 1;
		#30
		rst = 0;
	end
	always #(period/2) clk = ~clk;

fft_4 fft_4(
	.clk		(	clk),
	.rst		(	rst),
	.A_real		(	data_real),
	.A_img		(	data_img),
	.start4		(	w_start),
	.end4		(	w_ending),
	.out_real4	(	out_real4),
	.out_img4	(	out_img4)
);

data_gen #(.layer (3))
data_gen4(
	.clk		(clk),
	.rst		(rst),
	.data_real	(data_real),
	.data_img	(data_img),
	.valid		(valid),
	.start		(w_start),
	.over		(w_ending)
	);

endmodule