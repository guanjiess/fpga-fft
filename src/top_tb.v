`timescale 1ns / 1ps
module top_tb();

	parameter	period = 10;
	parameter	FIRST_WIDTH = 16;
	parameter	SECOND_WIDTH = 18;
	reg			clk;
	reg			rst;
	wire		valid;
	wire[32-1:0]	data_real;
	wire[32-1:0]	data_img;
	wire[32-1:0]	d_real;
	wire[32-1:0]	d_img;
	wire[18-1:0]	rotator_real;
	wire[18-1:0]	rotator_img;
	wire[50-1:0]	w_data_out_real;
	wire[50-1:0]	w_data_out_img;
	wire[32-1:0]	w_data_out_real_trunc;
	wire[32-1:0]	w_data_out_img_trunc;


	initial begin
		clk = 1;
		rst = 1;
		#25
		rst = 0;
	end
	always #(period/2) clk = ~clk;

	data8 uut(
		.clk		(clk),
		.rst		(rst),
		.data_real	(data_real),
		.data_img	(data_img),
		.valid		(valid)
		);

	fft_8 fft1(
	.clk			(clk),
	.rst			(rst),
	.A_real			(data_real),
	.A_img			(data_img),
	.S				(valid),
	.D_real			(d_real),
	.D_img			(d_img)
    );

	RotatorMemory8 RotatorMemory8(
	.clk			(clk),
	.rst			(rst),
	.S				(valid),
	.rotator_real	(rotator_real),
	.rotator_img	(rotator_img)
	);
	

/* 
	reg	[FIRST_WIDTH1-1:0] r_d_real;
	reg	[FIRST_WIDTH1-1:0] r_d_img;
	reg	[SECOND_WIDTH-1:0] r_rotator_real;
	reg	[SECOND_WIDTH-1:0] r_rotator_img; */

    multiplier multiplier(
	.a					(d_real)	,
	.b					(d_img)	,
	.c					(rotator_real)	,
	.d					(rotator_img)	,
	.clk				(clk)	,
	.rstn				(~rst)	,
	.data_real			(w_data_out_real)	,
	.data_img			(w_data_out_img)	,
	.data_real_trunc	(w_data_out_real_trunc)	,
	.data_img_trunc		(w_data_out_img_trunc)	,
	.ceabcd				(1)
	);
	
	butterfly	but1(
	.clk		()		,
	.rst		()		,
	.x			()		,
	.x_delay	()		,
	.x_added	()		,
	.x_subtract	()			
 );



endmodule