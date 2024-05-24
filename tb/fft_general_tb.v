`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Black Heart Factory
// Engineer: GSX
// 
// Create Date: 2023/11/21 11:14:19
// Design Name: 
// Module Name: fft_general_tb

`timescale 1ns / 1ps
module fft_general_tb();

	reg				clk;
	reg				rst;
	wire			valid;
	wire[32-1:0]	data_real;
	wire[32-1:0]	data_img;
	wire[32-1:0]	out_real;
	wire[32-1:0]	out_img;
	wire			w_ending;
	wire			w_start;
	wire			w_start_next;
	wire			w_end_next;

	parameter period = 10;
	initial begin
		clk = 1;
		rst = 1;
		#30
		rst = 0;
	end
	always #(period/2) clk = ~clk;

fft_1k fft_1k(
	.clk			(	clk		),
	.rst			(	rst		),
	.start			(	w_start),
	.over			(	w_ending),
	.data_in_real	(	data_real),
	.data_in_img	(	data_img),
	.data_out_real	(	out_real),
	.data_out_img	(	out_img),
	.start_next		(	w_start_next),
	.end_next		(	w_end_next)
);


data_gen #(.layer (10))
data_gen(
	.clk		(clk),
	.rst		(rst),
	.data_real	(data_real),
	.data_img	(data_img),
	.valid		(valid),
	.start		(w_start),
	.over		(w_ending)
	);
endmodule
