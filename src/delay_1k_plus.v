`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/28 17:00:11
module delay_1k_plus #(parameter layer = 11)(
	input				clk,
	input				rst,
	input		[31:0]	din_real,
	input		[31:0]	din_img,
	input				wea,
	output		[31:0]	dout_real,
	output		[31:0]	dout_img,
	output				out_first,
	output				out_last
);

/*********************<			registers			>***********************/
//	reg			[15:0]		DELAY_TIME	= 1<<(layer-1);
//	reg			[15:0]		required_delay_in_machine = DELAY_TIME - 5;
	parameter				DELAY_TIME	= 1<<(layer-1);
	parameter				required_delay_in_state_machine = DELAY_TIME - 1 -3 - 1;
	reg						r_enable;
	reg			[12:0]		r_halt;
	reg			[12:0]		r_addra;
	reg			[12:0]		r_addrb;
	reg						r_wea_1d;
	reg						r_write_trig;
	//不再写入数据后，继续输出读地址，直到把所有写入的数据输出完毕
	reg			[8:0]		r_tail_cnt;
	reg			[15:0]		r_delay_cnt;
	wire		[32 -1 :0]	w_dout_real;
	wire		[32 -1 :0]	w_dout_img;
	//debug用
	reg						r_out_first;
	reg						r_out_first_1d;
	reg						r_out_first_2d;
	reg						r_out_last;
	reg						r_out_last_1d;

/*********************<			state machine			>***********************/
	reg			[2:0]		r_delay_state				;
	parameter				STATE_IDLE			=3'd0	;
	parameter				STATE_DELAY			=3'd1	;
	parameter				STATE_OUT			=3'd2	;
	parameter				STATE_TAIL			=3'd3	;
	parameter				STATE_END			=3'd4	;

	always@(posedge clk) begin
		if(rst == 1)begin
			r_delay_state	<=	STATE_IDLE;
		end else begin
			case(r_delay_state)
				STATE_IDLE:begin
					if(r_write_trig == 1)begin
						r_delay_state	<=	STATE_DELAY;
					end else begin
						r_delay_state	<=	r_delay_state;
					end
				end
				STATE_DELAY:begin
					if(r_delay_cnt == required_delay_in_state_machine)begin
						r_delay_state	<=	STATE_OUT;
					end else begin
						r_delay_state	<=	r_delay_state;
					end
				end
				STATE_OUT:begin
					if(r_write_trig == 1)begin
						r_delay_state	<=	STATE_TAIL;
					end else begin
						r_delay_state	<=	r_delay_state;
					end
				end
				
				STATE_TAIL:begin
					if(r_tail_cnt == required_delay_in_state_machine)begin
						r_delay_state	<=	STATE_END;
					end else begin
						r_delay_state	<=	r_delay_state;
					end
				end

				STATE_END:begin
					r_delay_state	<=	STATE_IDLE;
				end
				default:r_delay_state = STATE_IDLE;
			endcase
		end
	end

/*********************<			generate address			>***********************/
	always@(posedge clk)begin
		if(rst) begin
			r_addra	<=	0;
		end else begin
			if(wea) begin
				r_addra	<=	r_addra + 1;
			end else begin
				r_addra	<=	0;
			end
		end
	end

	always@(posedge clk)begin
		if(rst) begin
			r_wea_1d <=	0;
		end else begin
			r_wea_1d <=	wea;
		end
	end
	
	always@(posedge clk)begin
		if(rst) begin
			r_write_trig	<= 0;
		end else begin
			r_write_trig	<= r_wea_1d ^ wea;
		end
	end

	always@(posedge clk)begin
		if(rst) begin
			r_delay_cnt	<= 0;
		end else begin
			if(r_delay_state == STATE_DELAY) begin
				r_delay_cnt	<= r_delay_cnt + 1;
			end else begin
				r_delay_cnt	<= 0;
			end
		end
	end
	
	always@(posedge clk)begin
		if(rst) begin
			r_tail_cnt	<= 0;
		end else begin
			if(r_delay_state == STATE_TAIL) begin
				r_tail_cnt	<= r_tail_cnt + 1;
			end else begin
				r_tail_cnt	<= 0;
			end
		end
	end

	always@(posedge clk) begin
		if(rst) begin
			r_addrb	<= 0;
		end else begin
			if(r_delay_state == STATE_OUT | r_delay_state == STATE_TAIL) begin
				r_addrb	<=	r_addrb + 1;
			end else begin
				r_addrb	<= 0;
			end
		end
	end

/*********************<			used for debug			>***********************/
	always@(posedge clk)begin
		if(rst) begin
			r_out_first	<= 0;
		end else begin
			if(r_delay_state == STATE_DELAY && r_delay_cnt == required_delay_in_state_machine) begin
				r_out_first	<= 1;
			end else begin
				r_out_first	<= 0;
			end
		end
	end
	
	always@(posedge clk)begin
		if(rst) begin
			r_out_last	<= 0;
		end else begin
			if(r_delay_state == STATE_TAIL && r_tail_cnt == required_delay_in_state_machine ) begin
				r_out_last	<= 1;
			end else begin
				r_out_last	<= 0;
			end
		end
	end
	always@(posedge clk) begin
		if(rst)begin
			r_out_first_1d	<= 0;
			r_out_first_2d	<= 0;
			r_out_last_1d	<= 0;
		end else begin
			r_out_first_1d	<= r_out_first;
			r_out_first_2d	<= r_out_first_1d;
			r_out_last_1d	<= r_out_last;
		end
	end
	assign	out_first = r_out_first_2d;
	assign	out_last = r_out_last_1d;

/*********************<			use ram to delay			>***********************/
//Delay is a ram
//2 versions, one for anlogic and one for xilinx
//the ram ip name is set the same, both are called Delay
//anlogic version ram
/* Delay delay_real(
		.dia	(		din_real	),
		.addra	(		r_addra		), 
		.clk	(		clk			),
		.cea	(		1			),

		.ceb	(		1			),
		.dob	(		w_dout_real	), 
		.addrb	(		r_addrb		),
		.clk	(		clk			)
);

Delay delay_img(
		.dia	(		din_img		),
		.addra	(		r_addrb		), 
		.clk	(		clk			),
		.cea	(		1			),

		.ceb	(		1			),
		.dob	(		w_dout_img	), 
		.addrb	(		r_addrb		),
		.clk	(		clk			)
); */


//xilinx version ram
Delay delay_real (
	.clka		(		clk			),    // input wire clk
	.wea		(		1			),      // input wire [0 : 0] wea
	.addra		(		r_addra		),  // input wire [8 : 0] addra
	.dina		(		din_real	),    // input wire [17 : 0] dina
	.clkb		(		clk			),    // input wire clk
	.enb		(		1			),
	.addrb		(		r_addrb		),  // input wire [8 : 0] addrb
	.doutb		(		w_dout_real	)  // output wire [17 : 0] doutb
);

Delay delay_img (		
	.clka		(		clk			),    // input wire clk
	.wea		(		1			),      // input wire [0 : 0] wea
	.addra		(		r_addra		),  // input wire [8 : 0] addra
	.dina		(		din_img		),    // input wire [17 : 0] dina
	.clkb		(		clk			),    // input wire clk
	.enb		(		1			),
	.addrb		(		r_addrb		),  // input wire [8 : 0] addrb
	.doutb		(		w_dout_img	)  // output wire [17 : 0] doutb
);

	assign dout_real		= w_dout_real;
	assign dout_img		= w_dout_img;

endmodule
