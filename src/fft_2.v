`timescale 1ns / 1ps
module fft_2(
	input				clk,
	input				rst,
	input	[32-1:0]	A_real,
	input	[32-1:0]	A_img,
	input				start2,
	input				end2,
	output	[32-1:0]	out_real2,
	output	[32-1:0]	out_img2,
	output				out_start
);
//rotator，只有一个
//其实不需要
	parameter [18-1:0]	m_one = 18'b11_1111_1111_1111_1111;

	wire	[32-1:0]	w_B_real;
	wire	[32-1:0]	w_B_img;
	wire	[32-1:0]	w_D_real_tmp;
	wire	[32-1:0]	w_D_img_tmp;
	wire	[32-1:0]	B_real;
	wire	[32-1:0]	B_img;
	reg		[32-1:0]	r_C_real;
	reg		[32-1:0]	r_C_img;
	wire	[32-1:0]	w_C_real;
	wire	[32-1:0]	w_C_img;


/*****************<-------Control Registers and state machine------->*********************/
	parameter	PERIOD				=	2;
	parameter	HALT_FOR_NEXT_LAYER	=	6 + (PERIOD)/2;
	parameter	STATE_IDLE			=	3'd0;
	parameter	STATE_START			=	3'd1;
	parameter	STATE_PROCESSING	=	3'd2;
	parameter	STATE_END			=	3'd3;
	reg	[2:0]	r_state2			=	0;
	reg			butterfly_enable	=	0;
	reg			S2					= 0;
	reg	[4:0]	out_start_cnt		= 0;
	reg			r_out_start			= 0;


	always@(posedge clk) begin
		if(rst == 1)begin
			r_state2	<=	STATE_IDLE;
		end else begin
			case(r_state2)
				STATE_IDLE:begin
					if(start2 == 1)begin
						r_state2	<=	STATE_START;
					end else begin
						r_state2	<=	r_state2;
					end
				end
				STATE_START:begin
					r_state2	<=	STATE_PROCESSING;
				end
				STATE_PROCESSING:begin
					if(end2 == 1)begin
						r_state2	<=	STATE_END;
					end else begin
						r_state2	<=	r_state2;
					end
				end
				STATE_END:begin
					r_state2	<=	STATE_IDLE;
				end
				default:r_state2 = STATE_IDLE;
			endcase
		end
	end

/*****************<-------butterfly control------>*********************/

	always@(posedge clk) begin
		if(rst == 1)begin
			butterfly_enable	<=	0;
		end else begin
			if(r_state2 == STATE_START | r_state2 == STATE_PROCESSING | start2 == 1) begin
				butterfly_enable	<=	1;
			end else if (r_state2== STATE_END) begin
				butterfly_enable	<=	0;
			end else begin
				butterfly_enable	<=	butterfly_enable;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			S2	<=	1;
		end else begin
			if(r_state2 == STATE_START | r_state2 == STATE_PROCESSING | start2 == 1) begin
				S2	<=	S2 + 1;
			end else begin
				S2	<=	S2;
			end
		end
	end

	always@(posedge clk) begin
		if(rst == 1)begin
			out_start_cnt	<=	0;
		end else begin
			if(r_state2 == STATE_START | r_state2 == STATE_PROCESSING) begin
				if(out_start_cnt == 5) begin
					out_start_cnt	<=	out_start_cnt;
				end else begin
					out_start_cnt	<=	out_start_cnt + 1;
				end
			end
		end
	end
	
	always@(posedge clk)begin
		if(rst == 1)begin
			r_out_start <= 0;
		end else begin
			if(out_start_cnt == 1) begin
				r_out_start <= 1;
			end else begin
				r_out_start <= 0;
			end
		end
	end
	

//延时单元，比较简单，不用ram

	always@(posedge clk) begin
		if(rst == 1)begin
			r_C_real<= 0;
			r_C_img	<= 0;
		end else begin
			r_C_real	<= w_B_real;
			r_C_img		<= w_B_img;
		end
	end
	assign	w_C_real = r_C_real;
	assign	w_C_img = r_C_img;
	assign	out_real2= w_D_real_tmp;
	assign	out_img2= w_D_img_tmp;
	assign	out_start = r_out_start;


//蝶形运算单元
butterfly butterfly2(
	.clk			(	clk),
	.rst			(	rst),
	.S				(	S2),
	.enable			(	butterfly_enable),
	.A_real			(	A_real),
	.A_img			(	A_img),
	.C_real			(	w_B_real),
	.C_img			(	w_B_img),//这里其实不需要延时，加减运算实质上充当了delay模块
	.B_real			(	w_B_real),
	.B_img			(	w_B_img),
	.D_real			(	w_D_real_tmp),
	.D_img			(	w_D_img_tmp)
 );

endmodule
