`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/20 20:15:23
// Design Name: 
// Module Name: fft_general_tb
//////////////////////////////////////////////////////////////////////////////////
module butterfly_general_tb();

	reg				clk;
	reg				rst;
	wire			valid;
	wire[32-1:0]	w_data_in_real;
	wire[32-1:0]	w_data_in_img;
	wire[32-1:0]	w_data_out_real;
	wire[32-1:0]	w_data_out_img;
	wire			w_start;
	wire			w_end;
	wire			w_start_next_level;
	wire			w_end_next_level;
	wire			w_rotator_valid;

	parameter period = 10;
	initial begin
		clk = 1;
		rst = 1;
		#30
		rst = 0;
	end
	always #(period/2) clk = ~clk;


butterfly_general #(.layer(12))
butterfly_general_2k(
	.clk				(		clk			),
	.rst				(		rst			),
	.data_in_start		(		w_start		),
	.data_in_end		(		w_end		),
	.A_real				(		w_data_in_real),
	.A_img				(		w_data_in_img),
	.next_level_start	(		w_start_next_level),
	.D_real				(		w_data_out_real),
	.D_img				(		w_data_out_img),
	.data_out_first		(					),
	.data_out_last		(					),
	.rotator_valid		(		w_rotator_valid)
);
data_gen #(.layer (12))
data_gen(
	.clk		(clk),
	.rst		(rst),
	.data_real	(w_data_in_real),
	.data_img	(w_data_in_img),
	.valid		(valid),
	.start		(w_start),
	.over		(w_end)
	);

endmodule