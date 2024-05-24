`timescale 1ns / 1ps
module data_gen_tb();

	reg			clk;
	reg			rst;
	wire		valid;
	wire[32-1:0]	data_real;
	wire[32-1:0]	data_img;


	parameter period = 10;

	initial begin
		clk = 1;
		rst = 1;
		#10
		rst = 0;
	end

	always #(period/2) clk = ~clk;


	data_gen #(.layer (4))
	uut(
		.clk	(clk),
		.rst	(rst),
		.data_real	(data_real),
		.data_img	(data_img),
		.valid	(valid)
		);


endmodule