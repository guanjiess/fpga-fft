`timescale 1ns / 1ps
module rom_tb ();

	reg			[8:0]	r_addrb		;
	reg			[8:0]	r_addra		;
	wire		[17:0]	w_rom_out;
	reg					clk;
	reg					rst;
	reg			[17:0]	test1 = -25079;
	reg			[17:0]	test2 = -46340;
	reg			[17:0]	test3 = -60547;


	parameter period = 10;
	initial begin
		clk = 1;
		rst = 1;
		#30
		rst = 0;
	end
	always #(period/2) clk = ~clk;

	always@(posedge clk) begin
		if(rst) begin
			r_addrb <= 0;
		end else begin
			if(r_addrb == 7) begin
				r_addrb <= 0;
			end else begin
				r_addrb <= r_addrb + 1;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst) begin
			r_addra <= 0;
		end else begin
			if(r_addra == 7) begin
				r_addra <= 0;
			end else begin
				r_addra <= r_addra + 1;
			end
		end
	end


/* ram_rotator Rotator16(
	.doa			(		w_rom_out),
	.addra			(		r_addrb			),
	.ocea			(		1),
	.clka			(		clk),
	.rsta			(		0)
); */




ram_rotator Rotator16( 
	dia		(	test1), 
	addra	(	addra), 
	cea		(	0), 
	clka	(	clk),
	dob		(	w_rom_out), 
	addrb	(	addrb), 
	ceb		(	1), 
	clkb	(	clk)
);


endmodule
