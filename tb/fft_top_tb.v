`timescale 1ns / 1ps
module fft_top_tb();


/**************************=======Initialization=======**************************/
	reg				clk;
	reg				rst;
	reg				data_config;
	wire			valid;
	wire[32-1:0]	w_data_real;
	wire[32-1:0]	w_data_img;
	wire[32-1:0]	out_real;
	wire[32-1:0]	out_img;
	wire			w_start;
	wire			w_ending;
	wire			w_out_first;
	wire			w_out_last;
	reg [64-1:0]		fft_abs;

	parameter period = 10;
    always #5 clk = ~clk;
	initial begin
		clk = 1;
		rst = 1;
		data_config = 1;
		#30
		rst = 0;
	end


fft_top fft_top(
	.clk			(	clk				),
	.rst			(	rst				),
	.start			(	w_start			),
	.data_config	(	data_config		),
	.data_real		(	w_data_real		),
	.data_img		(	w_data_img		),
	.out_real		(	out_real		),
	.out_img		(	out_img			),
	.out_first		(	w_out_first		),
	.out_last		(	w_out_last		)
);

/*data_gen #(.layer (3))
data_gen8(
	.clk		(clk),
	.rst		(rst),
	.data_real	(w_data_real),
	.data_img	(w_data_img),
	.valid		(valid),
	.start		(w_start8),
	.over		(w_ending8)
	);*/
data_gen #(.layer (14))
data_gen(
	.clk		(clk),
	.rst		(rst),
	.data_real	(w_data_real),
	.data_img	(w_data_img),
	.valid		(valid),
	.start		(w_start),
	.over		(w_ending)
);

always @ (posedge clk) begin
	fft_abs <= $signed(out_real)* $signed(out_real)+ $signed(out_img)* $signed(out_img);
end

endmodule