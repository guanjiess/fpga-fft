`timescale 1ns / 1ps
module delay_tb();

	reg				clk;
	reg				rst;
	wire			valid;
	wire[32-1:0]	data_real;
	wire[32-1:0]	data_img;
	wire[32-1:0]	delay_real_16;
	wire[32-1:0]	delay_img_16;
	wire			w_start_16;
	wire			w_ending_16;
	wire			w_out_first;
	wire			w_out_last;
	reg	r_wea = 0;

	parameter period = 10;
	initial begin
		clk = 1;
		rst = 1;
		#30
		rst = 0;
		#300
		r_wea = 1;
		#1000
		r_wea = 0;
	end
	always #(period/2) clk = ~clk;


delay #(.layer(5))
delay_8(
	.clk			(		clk				),
	.rst			(		rst				),
	.din_real		(		data_real		),
	.din_img		(		data_img		),
	.wea			(		r_wea			),
	.dout_real		(		delay_real_16	),
	.dout_img		(		delay_img_16	),
	.out_first		(		w_out_first		),
	.out_last		(		w_out_last		)
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