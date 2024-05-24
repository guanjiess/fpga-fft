`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/22 12:05:58
// Design Name: 
// Module Name: fft_256
//////////////////////////////////////////////////////////////////////////////////
module fft_256(
	input				clk,
	input				rst,
	input				start,
	input				over,
	input	[32-1:0]	data_in_real,
	input	[32-1:0]	data_in_img,
	output	[32-1:0]	data_out_real,
	output	[32-1:0]	data_out_img,
	output				start_next,
	output				end_next
);
/*****************<-------control next layer------>***************/
	parameter			current_layer = 8;
	parameter			PERIOD = 1<<current_layer;
	parameter			HALT_FOR_NEXT_LAYER	=	6 + (PERIOD)/2;
	wire				w_next_level_start;
/*****************<-------butterfly------>************************/

	wire	[31:0]		w_D_real;
	wire	[31:0]		w_D_img;
	wire				w_data_out_first;
	wire				w_data_out_last;
	wire				w_rotator_valid;

	butterfly_general #(.layer(current_layer))
	butterfly(
		.clk				(		clk),
		.rst				(		rst),
		.data_in_start		(		start),
		.data_in_end		(		over),
		.A_real				(		data_in_real),
		.A_img				(		data_in_img),
		.next_level_start	(		w_next_level_start),
		.D_real				(		w_D_real),
		.D_img				(		w_D_img),
		.data_out_first		(		w_data_out_first),
		.data_out_last		(		w_data_out_last),
		.rotator_valid		(		w_rotator_valid)
	);
	assign start_next  = w_next_level_start;
/*****************<-------Rotators  ------>************************/

	wire		[12:0]		w_rotator_addr;
	wire		[17:0]		w_rotator_real_tmp;
	wire		[17:0]		w_rotator_img_tmp;
	reg			[17:0]		r_rotator_real;
	reg			[17:0]		r_rotator_img;
	wire					w_select;
	Rotator_address #(.layer(current_layer))
	rotator_address(
		.clk				(		clk	),
		.rst				(		rst	),
		.rotator_valid		(		w_rotator_valid),
		.rotator_addr		(		w_rotator_addr),
		.select				(		w_select)
	);
	
rotator_256_real rotator_256_real (
	.clka			(clk),            // input wire clka
	.addra			(w_rotator_addr),          // input wire [8 : 0] addra
	.douta			(w_rotator_real_tmp)         // output wire [17 : 0] douta
);

rotator_256_img rotator_256_img (
	.clka			(clk),            // input wire clka
	.addra			(w_rotator_addr),          // input wire [8 : 0] addra
	.douta			(w_rotator_img_tmp)         // output wire [17 : 0] douta
);
	always@(posedge clk) begin
		if(rst) begin
			r_rotator_real	<= 1 << 16;
			r_rotator_img 	<=0;
		end else begin
			if(w_rotator_valid) begin
				if(w_select) begin
					r_rotator_real	<= 1 << 16;
					r_rotator_img 	<=0;
				end else begin
					r_rotator_real	<= w_rotator_real_tmp;
					r_rotator_img	<= w_rotator_img_tmp;
				end
			end else begin
				r_rotator_real	<= 1 << 16;
				r_rotator_img 	<=0;
			end
		end
	end

/*****************<-------Multiplier------>************************/
	wire		[31:0]		w_out_real;
	wire		[31:0]		w_out_img;
multiplier multiplier(
	.a				(	w_D_real),
	.b				(	w_D_img),
	//.ceabcd			(	1),
	.c				(	r_rotator_real),
	.d				(	r_rotator_img),
	.clk			(	clk),
	.rstn			(	~rst),
	.data_real		(	),
	.data_img		(	),
	.data_real_trunc(	w_out_real),
	.data_img_trunc	(	w_out_img)
);
/*****************<-------output------>************************/
	assign data_out_real  = w_out_real;
	assign data_out_img  = w_out_img;

endmodule


