`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Black heart factory
// Engineer:  GSX
// Create Date: 2023/11/20 19:56:39

module butterfly_general #(parameter layer = 5)(
	input				clk,
	input				rst,
	input				data_in_start,
	input				data_in_end,
	input	[31:0]		A_real,
	input	[31:0]		A_img,
	output				next_level_start,
	output	[31:0]		D_real,
	output	[31:0]		D_img,
	output				data_out_first,
	output				data_out_last,
	output				rotator_valid
);

/*****************<-------		state machine		------->**************/
	parameter			current_layer		= layer;
	parameter			PERIOD				=	1<<layer;
	parameter			HALT_FOR_NEXT_LAYER	=	6 + (PERIOD)/2;
	parameter			STATE_IDLE			=	3'd0;
	parameter			STATE_START			=	3'd1;
	parameter			STATE_PROCESSING	=	3'd2;
	parameter			STATE_END			=	3'd3;
	reg		[2:0]		r_state				=	0;
	reg					butterfly_enable	=	0;
	reg					S					;
	reg		[15:0]		S_counter			;
	reg		[13:0]		next_level_start_counter=	 0;

	always@(posedge clk) begin
		if(rst == 1)begin
			r_state	<=	STATE_IDLE;
		end else begin
			case(r_state)
				STATE_IDLE:begin
					if(data_in_start == 1)begin
						r_state	<=	STATE_START;
					end else begin
						r_state	<=	r_state;
					end
				end
				STATE_START:begin
					r_state	<=	STATE_PROCESSING;
				end
				STATE_PROCESSING:begin
					if(data_in_end == 1)begin
						r_state	<=	STATE_END;
					end else begin
						r_state	<=	r_state;
					end
				end
				STATE_END:begin
					r_state	<=	STATE_IDLE;
				end
				default:r_state = STATE_IDLE;
			endcase
		end
	end
/*****************<-------		butterfly control	------->**************/

	always@(posedge clk) begin
		if(rst == 1)begin
			butterfly_enable	<=	0;
		end else begin
			if(r_state == STATE_START | r_state == STATE_PROCESSING | data_in_start == 1) begin
				butterfly_enable	<=	1;
			end else if (r_state== STATE_END) begin
				butterfly_enable	<=	0;
			end else begin
				butterfly_enable	<=	butterfly_enable;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			S_counter	<=	0;
		end else begin
			if(r_state == STATE_START | r_state == STATE_PROCESSING) begin
				if(S_counter == PERIOD-1) begin
					S_counter	<=	0;
				end else begin
					S_counter	<=	S_counter + 1;
				end
			end else begin
				S_counter <= 0;
			end
		end
	end

	always@(posedge clk) begin
		if(rst == 1)begin
			S	<=	1;
		end else begin
			if(data_in_start == 1) begin
				S			<=	0;
			end else if (S_counter == PERIOD/2-1 | S_counter == PERIOD-1)begin
				S			<=	~S;
			end else if (data_in_end == 1)begin
				S			<=	1;
			end else begin
				S			<=	S;
			end
		end
	end

/*****************<-------		next layer control	------->**************/

	reg				r_next_level_start;
	always@(posedge clk) begin
		if(rst == 1)begin
			r_next_level_start	<=	0;
		end else begin
			//if(next_level_start_counter == HALT_FOR_NEXT_LAYER-2) begin
			//HALT_FOR_NEXT_LAYER-2 is used for anlogic version
			//HALT_FOR_NEXT_LAYER-3 is used for vivado version
			if(next_level_start_counter == HALT_FOR_NEXT_LAYER-3) begin
				r_next_level_start	<=	1;
			end else begin
				r_next_level_start	<=	0;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			next_level_start_counter	<=	0;
		end else begin
			if(r_state == STATE_START | r_state == STATE_PROCESSING)begin
				if(next_level_start_counter == HALT_FOR_NEXT_LAYER)begin
					next_level_start_counter <= next_level_start_counter;
				end else begin
					next_level_start_counter <= next_level_start_counter + 1;
				end
			end
		end
	end
	assign next_level_start = r_next_level_start;


/*****************<-------rotator_valid------->**********************/
	parameter				WAIT_FOR_ROTATOR = PERIOD - 2;
	reg			[13:0]		r_count_rotator;
	reg						r_rotator_valid;
	reg						rotator_triger;

	always@(posedge clk) begin
		if(rst == 1) begin
			r_count_rotator		<=	0;
		end else begin
			if(r_state == STATE_START | r_state == STATE_PROCESSING)begin
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
			r_rotator_valid	<=	0;
		end else begin
			if(r_count_rotator == WAIT_FOR_ROTATOR - 1) begin
				r_rotator_valid <= 1;
			end else begin
				r_rotator_valid <= 0;
			end
		end
	end
	assign rotator_valid = r_rotator_valid;
/*****************<-------		delay unit with ram	------->**************/

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
			if(data_in_start | r_state == STATE_START | r_state == STATE_PROCESSING)begin
				r_wea <= 1;
			end else begin
				r_wea <= 0;
			end
		end
	end


delay #(.layer(current_layer))
delay(
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
/*****************<-------		Butterfly			------->**************/

butterfly butterfly(
	.clk			(	clk),
	.rst			(	rst),
	.S				(	S),
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
/*****************<-------		final output		------->**************/
	assign D_real			= w_D_real_tmp;
	assign D_img				= w_D_img_tmp;
	assign data_out_first	= w_delay_out_first;
	assign data_out_last		= w_delay_out_last;

endmodule
