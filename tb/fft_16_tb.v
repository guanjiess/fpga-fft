`timescale 1ns / 1ps
module fft_16_tb();

	reg				clk;
	reg				rst;
	wire			valid;
	wire[32-1:0]	data_real;
	wire[32-1:0]	data_img;
	wire[32-1:0]	out_real_16;
	wire[32-1:0]	out_img_16;
	wire			w_start_16;
	wire			w_ending_16;
	wire			w_start8;
	wire			w_ending8;

	parameter period = 10;
	initial begin
		clk = 1;
		rst = 1;
		#30
		rst = 0;
	end
	always #(period/2) clk = ~clk;

fft_16 fft_16(
	.clk			(	clk		),
	.rst			(	rst		),
	.start16		(	w_start_16),
	.end16			(	w_ending_16),
	.A_real			(	data_real),
	.A_img			(	data_img),
	.out_real_16	(	out_real_16),
	.out_img_16		(	out_img_16),
	.start8			(	w_start8),
	.end8			(	w_ending8)
);

data_gen #(.layer (4))
data_gen_16(
	.clk		(clk),
	.rst		(rst),
	.data_real	(data_real),
	.data_img	(data_img),
	.valid		(valid),
	.start		(w_start_16),
	.over		(w_ending_16)
	);

endmodule