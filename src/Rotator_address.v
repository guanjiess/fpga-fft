`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  SEU
// Engineer:  GSX
// Create Date: 2023/11/21 11:23
// Module Name: Rotators
module Rotator_address #(parameter layer = 5)(
	input			clk,
	input			rst,
	input			rotator_valid,
	output	[12:0]	rotator_addr,
	output			select
);

parameter			MAX_ADDR = 1 << (layer-1);
reg			[12:0]	r_addra		;
reg					select_1d	;
reg					select_2d	;
wire		[17:0]	w_rotator_real_tmp;
wire		[17:0]	w_rotator_img_tmp;

always@(posedge clk) begin
	if(rst) begin
		r_addra <= 0;
	end else begin
		if(rotator_valid) begin
			r_addra		<=	r_addra + 1;;
		end else begin
			r_addra		<=	0;
		end
	end
end

always@(posedge clk)begin
	if(rst) begin
		select_1d	<=	0;
		select_2d	<=	0;
	end else begin
		select_1d	<=	r_addra[layer-1];
		select_2d	<=	select_1d		;
	end
end

	assign	select				=	select_2d			;
	assign	rotator_addr		=	r_addra[layer-1:0]	;

endmodule
