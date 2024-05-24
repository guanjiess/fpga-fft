`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//implement complex multiplier with xilinx multiplier IP 
// Design Name: 
////////////////////////////////////////////////////////////////////////////


module multiplier
(
	input	[32-1:0]		a,
	input	[32-1:0]		b,
	input	[18-1:0]		c,
	input	[18-1:0]		d,
	input					clk,
	input					rstn,
	output	[50-1:0]		data_real,
	output	[50-1:0]		data_img,
	output	[32-1:0]		data_real_trunc,
	output	[32-1:0]		data_img_trunc
	);


	reg		[50:0]		r_data_real;
	reg		[50:0]		r_data_img;
	reg		[50:0]		r_data_real_shifted;
	reg		[50:0]		r_data_img_shifted;
	reg		[32-1:0]	r_data_real_trunc;
	reg		[32-1:0]	r_data_img_trunc;
	wire	[50-1:0]	bd			;
	wire	[50-1:0]	ac			;
	wire	[50-1:0]	bc			;
	wire	[50-1:0]	ad			; 



	always@(posedge clk)begin
		if(rstn==0)begin
			r_data_real	<=	0;
			r_data_img	<=	0;
		end else begin
			r_data_real	<=	ac - bd;
			r_data_img	<=	ad + bc;
		end
    end
	

// right shift and truncate
	always@(posedge clk)begin
		if(rstn==0)begin
			r_data_real_shifted	<=	0;
			r_data_img_shifted	<=	0;
		end else begin
			r_data_real_shifted	<= r_data_real>>16;
			r_data_img_shifted	<= r_data_img>>16;
		end
	end

	always@(posedge clk)begin
		if(rstn==0)begin
			r_data_real_trunc	<=	0;
			r_data_img_trunc	<=	0;
		end else begin
			r_data_real_trunc	<= r_data_real_shifted[31:0];
			r_data_img_trunc	<= r_data_img_shifted[31:0];
		end
	end


	mult2 real_bd(
	.CLK		(clk	), 
	.A			(b		), 
	.B			(d		), 
	.P			(bd		)
	);
	
	mult2 real_ac(
	.CLK		(clk	), 
	.A			(a		), 
	.B			(c		),  
	.P			(ac		)
	);
	
	mult2 real_bc(
	.CLK		(clk	), 
	.A			(b		), 
	.B			(c		), 
	.P			(bc		)
	);
	
	mult2 real_ad(
	.CLK		(clk	), 
	.A			(a		), 
	.B			(d		), 
	.P			(ad		) 
	 );

	assign data_real				= r_data_real;
	assign data_img				= r_data_img;
	assign data_real_trunc		=r_data_real_trunc;
	assign data_img_trunc		= r_data_img_trunc;

endmodule
