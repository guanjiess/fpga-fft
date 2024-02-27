`timescale 1ns / 1ps
module fft_4(
	input				clk,
	input				rst,
	input				start4,
	input				end4,
	input	[32-1:0]	A_real,
	input	[32-1:0]	A_img,
	output	[32-1:0]	out_real4,
	output	[32-1:0]	out_img4,
	output				start2,
	output				end2
);

/*****************<-------Control Registers and state machine------->*********************/
	parameter	PERIOD				=	4;
	parameter	HALT_FOR_NEXT_LAYER		=	6 + (PERIOD)/2;
	parameter	STATE_IDLE			=	3'd0;
	parameter	STATE_START			=	3'd1;
	parameter	STATE_PROCESSING	=	3'd2;
	parameter	STATE_END			=	3'd3;
	reg	[2:0]	r_state4			=	0;
	reg			butterfly_enable	=	0;
	reg			S4				= 0;
	reg	[1:0]	S4_counter		= 1;
	reg	[4:0]	start2_counter		= 0;


	always@(posedge clk) begin
		if(rst == 1)begin
			r_state4	<=	STATE_IDLE;
		end else begin
			case(r_state4)
				STATE_IDLE:begin
					if(start4 == 1)begin
						r_state4	<=	STATE_START;
					end else begin
						r_state4	<=	r_state4;
					end
				end
				STATE_START:begin
					r_state4	<=	STATE_PROCESSING;
				end
				STATE_PROCESSING:begin
					if(end4 == 1)begin
						r_state4	<=	STATE_END;
					end else begin
						r_state4	<=	r_state4;
					end
				end
				STATE_END:begin
					r_state4	<=	STATE_IDLE;
				end
				default:r_state4 = STATE_IDLE;
			endcase
		end
	end

/*****************<-------butterfly control------>*********************/

	always@(posedge clk) begin
		if(rst == 1)begin
			butterfly_enable	<=	0;
		end else begin
			if(r_state4 == STATE_START | r_state4 == STATE_PROCESSING | start4 == 1) begin
				butterfly_enable	<=	1;
			end else if (r_state4== STATE_END) begin
				butterfly_enable	<=	0;
			end else begin
				butterfly_enable	<=	butterfly_enable;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			S4_counter	<=	0;
		end else begin
			if(r_state4 == STATE_START | r_state4 == STATE_PROCESSING) begin
				S4_counter	<=	S4_counter + 1;
			end else begin
				S4_counter	<=	S4_counter;
			end
		end
	end

	always@(posedge clk) begin
		if(rst == 1)begin
			S4	<=	1;
		end else begin
			if(start4 == 1) begin
				S4			<=	0;
			end else if (S4_counter == PERIOD/2-1 | S4_counter == PERIOD-1)begin
				S4			<=	~S4;
			end else if (end4 == 1)begin
				S4			<=	1;
			end else begin
				S4			<=	S4;
			end
		end
	end



/*****************<-------next layer control------>***********************/
	reg		[3:0]	counter_start2;
	reg				r_start2;
	always@(posedge clk) begin
		if(rst == 1)begin
			r_start2	<=	0;
		end else begin
			//if(start2_counter == HALT_FOR_NEXT_LAYER-2) begin
			//anlogic version, use above.
			if(start2_counter == HALT_FOR_NEXT_LAYER-3) begin
				r_start2	<=	1;
			end else begin
				r_start2	<=	0;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			start2_counter	<=	0;
		end else begin
			if(r_state4 == STATE_START | r_state4 == STATE_PROCESSING)begin
				if(start2_counter == 15)begin
					start2_counter <= start2_counter;
				end else begin
					start2_counter <= start2_counter + 1;
				end
			end
		end
	end


/*****************<-------Temporary Registers------->*********************/
//rotator，只�?1�?-j两个
//其实不需�?
	parameter [18-1:0]	m_one = 18'b11_1111_1111_1111_1111;
	parameter			frame_length = 4;

	wire	[32-1:0]	w_B_real;
	wire	[32-1:0]	w_B_img;
	wire	[32-1:0]	w_D_real_tmp;
	wire	[32-1:0]	w_D_img_tmp;
	wire	[32-1:0]	w_out_real4;
	wire	[32-1:0]	w_out_img4;
	wire	[32-1:0]	B_real;
	wire	[32-1:0]	B_img;
	reg		[32-1:0]	r_C_real;
	reg		[32-1:0]	r_C_img;
	wire	[32-1:0]	w_C_real;
	wire	[32-1:0]	w_C_img;

/*****************<-------延时单元，简单，不用ram------->***************/

//第二级延时两个clk，减去加法运算消耗，只需要延�?1�?
	always@(posedge clk) begin
		if(rst == 1)begin
			r_C_real<= 0;
			r_C_img	<= 0;
		end else begin
			r_C_real	<= w_B_real;
			r_C_img		<= w_B_img;
		end
	end


/*****************<-------Rotators------->*********************/
	reg					counter;
	reg		[18-1:0]	r_rorator_real;
	reg		[18-1:0]	r_rorator_img;
	/**real	: 1 1 1 0*/
	/**img	: 0 0 0 -1*/
	/**rotator left shift 16 bits to finish fix-point calculation*/
	always@(posedge clk) begin
		if(rst == 1)begin
			r_rorator_real	<=	1<<16;
			//r_rorator_real	<=	1;
			r_rorator_img	<=	0;
		end else begin
			if(counter == 1) begin
				r_rorator_real	<=	0;
				r_rorator_img	<=	-1<<16;
				//r_rorator_img	<=	1;
			end else begin
				r_rorator_real	<=	1<<16;
				//r_rorator_real	<=	1;
				r_rorator_img	<=	0;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			counter	<=	0;
		end else begin
			if(S4 == 0) begin
				counter	<=	counter + 1;
			end else begin
				counter <= counter;
			end
			
		end
	end

	assign	w_C_real = r_C_real;
	assign	w_C_img = r_C_img;
	assign	out_img4	 =	w_out_img4;
	assign	out_real4	 =	w_out_real4;
	assign	start2		 =	r_start2;

//蝶形运算单元
butterfly butterfly4(
	.clk			(	clk),
	.rst			(	rst),
	.S				(	S4),
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

multiplier multiplier(
	.a				(	w_D_real_tmp),
	.b				(	w_D_img_tmp),
	.c				(	r_rorator_real),
	.d				(	r_rorator_img),
	.clk			(	clk),
	.rstn			(	~rst),
	.data_real		(	),
	.data_img		(	),
	.data_real_trunc(	w_out_real4),
	.data_img_trunc	(	w_out_img4)
);

endmodule
