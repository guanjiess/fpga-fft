`timescale 1ns / 1ps
module Rotator16 (
	input			clk,
	input			rst,
	input			rotator_valid,
	output	[17:0]	rotator_real,
	output	[17:0]	rotator_img
);

reg			[3:0]	r_addra		;
reg					select_1d	;
reg					select_2d	;
wire		[17:0]	w_rotator_real_tmp;
wire		[17:0]	w_rotator_img_tmp;

always@(posedge clk) begin
	if(rst) begin
		r_addra <= 0;
	end else begin
		if(rotator_valid) begin
			r_addra		<= r_addra + 1;
		end else begin
			r_addra		<= 0;
		end
	end
end

always@(posedge clk)begin
	if(rst) begin
		select_1d	<=	0;
		select_2d	<=	0;
	end else begin
		select_1d	<=	r_addra[3];
		select_2d	<=	select_1d;
	end
end


	assign rotator_real	= select_2d? 1<<16:w_rotator_real_tmp;
	assign rotator_img	= select_2d? 0:w_rotator_img_tmp;


/* rotator_16_real rotator_16_real(
	.doa			(		w_rotator_real_tmp),
	.addra			(		r_addra			),
	.ocea			(		1),
	.clka			(		clk),
	.rsta			(		0)
);
rotator_16_img rotator_16_img
(
	.doa			(		w_rotator_img_tmp),
	.addra			(		r_addrb			),
	.ocea			(		1),
	.clka			(		clk),
	.rsta			(		0)
);
 */

rotator_16_real rotator_16_real (
	.clka			(clk),            // input wire clka
	.addra			(r_addra),          // input wire [8 : 0] addra
	.douta			(w_rotator_real_tmp)         // output wire [17 : 0] douta
);

rotator_16_img rotator_16_img (
	.clka			(clk),            // input wire clka
	.addra			(r_addra),          // input wire [8 : 0] addra
	.douta			(w_rotator_img_tmp)          // output wire [17 : 0] douta
);

endmodule
