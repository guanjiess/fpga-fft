`timescale 1ns / 1ps
module fft_8_tb();

	reg				clk;
	reg				rst;
	wire			valid;
	wire[32-1:0]	data_real;
	wire[32-1:0]	data_img;
	wire[32-1:0]	out_real8;
	wire[32-1:0]	out_img8;
	wire			w_start8;
	wire			w_ending8;
	wire			w_start4;
	wire			w_ending4;

	parameter period = 10;
	initial begin
		clk = 1;
		rst = 1;
		#30
		rst = 0;
	end
	always #(period/2) clk = ~clk;

fft_8 fft_8(
	.clk		(	clk		),
	.rst		(	rst		),
	.start8		(	w_start8),
	.end8		(	w_ending8),
	.A_real		(	data_real),
	.A_img		(	data_img),
	.out_real8	(	out_real8),
	.out_img8	(	out_img8),
	.start4		(	w_start4),
	.end4		(	w_ending4)
);


data_gen #(.layer (3))
data_gen8(
	.clk		(clk),
	.rst		(rst),
	.data_real	(data_real),
	.data_img	(data_img),
	.valid		(valid),
	.start		(w_start8),
	.over		(w_ending8)
	);

endmodule