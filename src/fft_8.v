`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Guan Shixun
// Create Date: 2023/09/11
// Modefied Data: 2023/10/17 

`timescale 1ns / 1ps
module fft_8(
	input				clk,
	input				rst,
	input				start8,
	input				end8,
	input	[32-1:0]	A_real,
	input	[32-1:0]	A_img,
	output	[32-1:0]	out_real8,
	output	[32-1:0]	out_img8,
	output				start4,
	output				end4
);

/*****************<-------Control Registers and state machine------->*********************/
	parameter			PERIOD				=	8;
	parameter			HALT_FOR_NEXT_LAYER	=	6 + (PERIOD)/2;
	parameter			STATE_IDLE			=	3'd0;
	parameter			STATE_START			=	3'd1;
	parameter			STATE_PROCESSING	=	3'd2;
	parameter			STATE_END			=	3'd3;
	reg		[2:0]		r_state8			=	0;
	reg					butterfly_enable	=	0;
	reg					S8					= 0;
	reg		[2:0]		S8_counter			= 1;
	reg		[4:0]		start4_counter		= 0;
	wire	[32-1:0]	w_out_real8			;
	wire	[32-1:0]	w_out_img8			;



	always@(posedge clk) begin
		if(rst == 1)begin
			r_state8	<=	STATE_IDLE;
		end else begin
			case(r_state8)
				STATE_IDLE:begin
					if(start8 == 1)begin
						r_state8	<=	STATE_START;
					end else begin
						r_state8	<=	r_state8;
					end
				end
				STATE_START:begin
					r_state8	<=	STATE_PROCESSING;
				end
				STATE_PROCESSING:begin
					if(end8 == 1)begin
						r_state8	<=	STATE_END;
					end else begin
						r_state8	<=	r_state8;
					end
				end
				STATE_END:begin
					r_state8	<=	STATE_IDLE;
				end
				default:r_state8 = STATE_IDLE;
			endcase
		end
	end

/*****************<-------butterfly control------>************************/

	always@(posedge clk) begin
		if(rst == 1)begin
			butterfly_enable	<=	0;
		end else begin
			if(r_state8 == STATE_START | r_state8 == STATE_PROCESSING | start8 == 1) begin
				butterfly_enable	<=	1;
			end else if (r_state8== STATE_END) begin
				butterfly_enable	<=	0;
			end else begin
				butterfly_enable	<=	butterfly_enable;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			S8_counter	<=	0;
		end else begin
			if(r_state8 == STATE_START | r_state8 == STATE_PROCESSING) begin
				S8_counter	<=	S8_counter + 1;
			end else begin
				S8_counter	<=	S8_counter;
			end
		end
	end

	always@(posedge clk) begin
		if(rst == 1)begin
			S8	<=	1;
		end else begin
			if(start8 == 1) begin
				S8			<=	0;
			end else if (S8_counter == PERIOD/2-1 | S8_counter == PERIOD-1)begin
				S8			<=	~S8;
			end else if (end4 == 1)begin
				S8			<=	1;
			end else begin
				S8			<=	S8;
			end
		end
	end

/*****************<-------next layer control------>***********************/
	reg				r_start4;
	always@(posedge clk) begin
		if(rst == 1)begin
			r_start4	<=	0;
		end else begin
			//if(start4_counter == HALT_FOR_NEXT_LAYER-2) begin
			//anlogic version, use above one.
			if(start4_counter == HALT_FOR_NEXT_LAYER-3) begin
				r_start4	<=	1;
			end else begin
				r_start4	<=	0;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			start4_counter	<=	0;
		end else begin
			if(r_state8 == STATE_START | r_state8 == STATE_PROCESSING)begin
				if(start4_counter == 15)begin
					start4_counter <= start4_counter;
				end else begin
					start4_counter <= start4_counter + 1;
				end
			end
		end
	end
	assign start4 = r_start4;
/*****************<-------延时单元，简单，不用ram------->*****************/
	reg		[32-1:0]	C_real;
	reg		[32-1:0]	C_img;
	wire	[32-1:0]	w_C_real;
	wire	[32-1:0]	w_C_img;
	wire	[32-1:0]	w_B_real;
	wire	[32-1:0]	w_B_img;
	wire	[32-1:0]	w_D_real_tmp;
	wire	[32-1:0]	w_D_img_tmp;
	reg		[32-1:0]	D_real_tmp;
	reg		[32-1:0]	D_img_tmp;
	reg		[32-1:0]	B_real_1d = 0;
	reg		[32-1:0]	B_real_2d = 0;
	reg		[32-1:0]	B_img_1d = 0;
	reg		[32-1:0]	B_img_2d = 0;

	// generate C, 4D latch of B.
	always@(posedge clk) begin
		if(rst == 1) begin
			B_real_1d	<=	0;
			B_real_2d	<=	0;
			C_real		<=	0;
		end else begin
			B_real_1d	<= w_B_real;
			B_real_2d	<= B_real_1d;
			C_real		<= B_real_2d;
		end	
	end
	
	always@(posedge clk) begin
		if(rst == 1) begin
			B_img_1d	<=	0;
			B_img_2d	<=	0;
			C_img		<=	0;
		end else begin
			B_img_1d	<= w_B_img;
			B_img_2d	<= B_img_1d;
			C_img		<= B_img_2d;
		end	
	end
	assign	w_C_real = C_real;
	assign	w_C_img = C_img;

/*****************<-------Rotators------->********************************/
	parameter				WAIT_FOR_ROTATOR = 7;
	reg			[3:0]		r_count_rotator;
	wire		[18-1:0]	w_rotator_real;
	wire		[18-1:0]	w_rotator_img;
	reg			[18-1:0]	r_rotator_real;
	reg			[18-1:0]	r_rotator_img;
	reg						r_rotator_valid;

	always@(posedge clk) begin
		if(rst == 1) begin
			r_count_rotator		<=	0;
		end else begin
			if(r_state8 == STATE_START | r_state8 == STATE_PROCESSING)begin
				if(r_count_rotator == WAIT_FOR_ROTATOR)begin
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
			r_rotator_valid	<=	0;
		end else begin
			if(r_count_rotator == WAIT_FOR_ROTATOR) begin
				r_rotator_valid <= 1;
			end else begin
				r_rotator_valid <= 0;
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


	RotatorMemory8 RotatorMemory8 (
		.clk			(	clk),
		.rst			(	rst),
		.rotator_valid	(	r_rotator_valid),
		.rotator_real	(	w_rotator_real),
		.rotator_img	(	w_rotator_img)
	);

/*****************<-------Butterfly------->*******************************/
butterfly butterfly8(
	.clk			(	clk),
	.rst			(	rst),
	.S				(	S8),
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


multiplier multiplier8(
	.a				(	w_D_real_tmp),
	.b				(	w_D_img_tmp),
	//.ceabcd			(	1),
	.c				(	w_rotator_real),
	.d				(	w_rotator_img),
	.clk			(	clk),
	.rstn			(	~rst),
	.data_real		(	),
	.data_img		(	),
	.data_real_trunc(	w_out_real8),
	.data_img_trunc	(	w_out_img8)
);

	assign	out_real8 = w_out_real8;
	assign	out_img8 = w_out_img8;
	assign	end4 = 0;

endmodule
