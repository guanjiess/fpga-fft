`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Guan Shixun
// Create Date: 2023/10/24 

`timescale 1ns / 1ps
module fft_16(
	input				clk,
	input				rst,
	input				start16,
	input				end16,
	input	[32-1:0]	A_real,
	input	[32-1:0]	A_img,
	output	[32-1:0]	out_real_16,
	output	[32-1:0]	out_img_16,
	output				start8,
	output				end8
);

/*****************<-------Control Registers and state machine------->*********************/
	parameter			PERIOD				=	16;
	parameter			HALT_FOR_NEXT_LAYER	=	6 + (PERIOD)/2;
	parameter			STATE_IDLE			=	3'd0;
	parameter			STATE_START			=	3'd1;
	parameter			STATE_PROCESSING	=	3'd2;
	parameter			STATE_END			=	3'd3;
	reg		[2:0]		r_state_16			=	0;
	reg					butterfly_enable	=	0;
	reg					S16					;
	reg		[2:0]		S16_counter			= 1;
	reg		[4:0]		start8_counter		= 0;
	wire	[32-1:0]	w_out_real_16			;
	wire	[32-1:0]	w_out_img_16			;



	always@(posedge clk) begin
		if(rst == 1)begin
			r_state_16	<=	STATE_IDLE;
		end else begin
			case(r_state_16)
				STATE_IDLE:begin
					if(start16 == 1)begin
						r_state_16	<=	STATE_START;
					end else begin
						r_state_16	<=	r_state_16;
					end
				end
				STATE_START:begin
					r_state_16	<=	STATE_PROCESSING;
				end
				STATE_PROCESSING:begin
					if(end16 == 1)begin
						r_state_16	<=	STATE_END;
					end else begin
						r_state_16	<=	r_state_16;
					end
				end
				STATE_END:begin
					r_state_16	<=	STATE_IDLE;
				end
				default:r_state_16 = STATE_IDLE;
			endcase
		end
	end

/*****************<-------butterfly control------>************************/

	always@(posedge clk) begin
		if(rst == 1)begin
			butterfly_enable	<=	0;
		end else begin
			if(r_state_16 == STATE_START | r_state_16 == STATE_PROCESSING | start16 == 1) begin
				butterfly_enable	<=	1;
			end else if (r_state_16== STATE_END) begin
				butterfly_enable	<=	0;
			end else begin
				butterfly_enable	<=	butterfly_enable;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			S16_counter	<=	0;
		end else begin
			if(r_state_16 == STATE_START | r_state_16 == STATE_PROCESSING) begin
				S16_counter	<=	S16_counter + 1;
			end else begin
				S16_counter	<=	S16_counter;
			end
		end
	end

	always@(posedge clk) begin
		if(rst == 1)begin
			S16	<=	1;
		end else begin
			if(start16 == 1) begin
				S16			<=	0;
			end else if (S16_counter == PERIOD/2-1 | S16_counter == PERIOD-1)begin
				S16			<=	~S16;
			end else if (end16 == 1)begin
				S16			<=	1;
			end else begin
				S16			<=	S16;
			end
		end
	end

/*****************<-------next layer control------>***********************/
	reg				r_start8;
	always@(posedge clk) begin
		if(rst == 1)begin
			r_start8	<=	0;
		end else begin
			//if(start8_counter == HALT_FOR_NEXT_LAYER-2) begin
			//HALT_FOR_NEXT_LAYER-2 is used for anlogic version
			//HALT_FOR_NEXT_LAYER-3 is used for vivado version
			if(start8_counter == HALT_FOR_NEXT_LAYER-3) begin
				r_start8	<=	1;
			end else begin
				r_start8	<=	0;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			start8_counter	<=	0;
		end else begin
			if(r_state_16 == STATE_START | r_state_16 == STATE_PROCESSING)begin
				if(start8_counter == 15)begin
					start8_counter <= start8_counter;
				end else begin
					start8_counter <= start8_counter + 1;
				end
			end
		end
	end
	assign start8 = r_start8;
/*****************<-------延时单元，用ram------->*****************/
	reg		[32-1:0]	C_real;
	reg		[32-1:0]	C_img;
	wire	[32-1:0]	w_C_real;
	wire	[32-1:0]	w_C_img;
	wire	[32-1:0]	w_B_real;
	wire	[32-1:0]	w_B_img;
	wire	[32-1:0]	w_D_real_tmp;
	wire	[32-1:0]	w_D_img_tmp;
	wire				w_delay_out_first;
	wire				w_delay_out_last;
	reg					r_wea;
	
	always@(posedge clk) begin
		if(rst) begin
			r_wea <= 0;
		end else begin
			if(start16 | r_state_16 == STATE_START | r_state_16 == STATE_PROCESSING | start16 == 1)begin
				r_wea <= 1;
			end else begin
				r_wea <= 0;
			end
		end
	end


delay #(.layer(4))
delay8(
		.clk			(		clk				),
		.rst			(		rst				),
		.din_real		(		w_B_real		),
		.din_img		(		w_B_img			),
		.wea			(		r_wea			),
		.dout_real		(		w_C_real		),
		.dout_img		(		w_C_img			),
		.out_first		(		w_delay_out_first		),
		.out_last		(		w_delay_out_last		)
	);

/*****************<-------Rotators------->********************************/
	parameter				WAIT_FOR_ROTATOR = PERIOD - 1;
	reg			[3:0]		r_count_rotator;
	wire		[18-1:0]	w_rotator_real;
	wire		[18-1:0]	w_rotator_img;
	reg			[18-1:0]	r_rotator_real;
	reg			[18-1:0]	r_rotator_img;
	reg						r_rotator_valid;
	reg						rotator_triger;

	always@(posedge clk) begin
		if(rst == 1) begin
			r_count_rotator		<=	0;
		end else begin
			if(r_state_16 == STATE_START | r_state_16 == STATE_PROCESSING)begin
				if(r_count_rotator == WAIT_FOR_ROTATOR - 1)begin
					r_count_rotator <= r_count_rotator;
				end else begin
					r_count_rotator <= r_count_rotator + 1;
				end
			end else begin
				r_count_rotator <= 0;
			end
		end	
	end

	always@(posedge clk)begin
		if(rst == 1)begin
			r_rotator_real	<=	0;
			r_rotator_img	<=	0;
		end else begin
			r_rotator_real	<=	w_rotator_real;
			r_rotator_img	<=	w_rotator_img;
		end
	end

	always@(posedge clk)begin
		if(rst == 1)begin
			r_rotator_valid	<=	0;
		end else begin
			if(r_count_rotator == WAIT_FOR_ROTATOR - 1) begin
				r_rotator_valid <= 1;
			end else begin
				r_rotator_valid <= 0;
			end
		end
	end

Rotator16 Rotator16 (
	.clk				(		clk				),
	.rst				(		rst				),
	.rotator_valid		(		r_rotator_valid	),
	.rotator_real		(		w_rotator_real	),
	.rotator_img		(		w_rotator_img	)
);

/*****************<-------Butterfly------->*******************************/
butterfly butterfly16(
	.clk			(	clk),
	.rst			(	rst),
	.S				(	S16),
	.enable			(	butterfly_enable),
	.A_real			(	A_real),
	.A_img			(	A_img),
	.C_real			(	w_C_real),
	.C_img			(	w_C_img),
	.B_real			(	w_B_real),
	.B_img			(	w_B_img),
	.D_real			(	w_D_real_tmp),
	.D_img			(	w_D_img_tmp)
 );

/*****************<-------final output------->****************************/
multiplier multiplier16(
	.a				(	w_D_real_tmp),
	.b				(	w_D_img_tmp),
	//.ceabcd			(	1),
	.c				(	w_rotator_real),
	.d				(	w_rotator_img),
	.clk			(	clk),
	.rstn			(	~rst),
	.data_real		(	),
	.data_img		(	),
	.data_real_trunc(	w_out_real_16),
	.data_img_trunc	(	w_out_img_16)
);

	assign	out_real_16 = w_out_real_16;
	assign	out_img_16 = w_out_img_16;

endmodule
