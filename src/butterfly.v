
module butterfly(
	input			clk			,
	input			rst			,
	input			S			,
	input			enable		,
	input[32-1:0]	A_real		,
	input[32-1:0]	A_img		,
	input[32-1:0]	C_real,
	input[32-1:0]	C_img,
	output[32-1:0]	B_real,
	output[32-1:0]	B_img,
	output[32-1:0]	D_real,
	output[32-1:0]	D_img
 );

	reg	[32-1:0]		r_x_added_real = 0;
	reg	[32-1:0]		r_x_added_img = 0;
	reg	[32-1:0]		r_x_subtracted_real = 0;
	reg	[32-1:0]		r_x_subtracted_img = 0;
	reg	[32-1:0]		r_B_real = 0;
	reg	[32-1:0]		r_B_img = 0;
	reg	[32-1:0]		r_A_real_1d = 0;
	reg	[32-1:0]		r_A_img_1d = 0;
	reg	[32-1:0]		r_C_real_1d = 0;
	reg	[32-1:0]		r_C_img_1d = 0;
	reg					S_1d = 0;


//加减运算�?要一个时钟，�?以需要对A  \ C的数据留�?个备�?
	always@(posedge clk) begin
		if(rst == 1) begin
			r_A_real_1d		<= 0;
			r_A_img_1d		<= 0;
		end else begin
			r_A_real_1d		<= A_real;
			r_A_img_1d		<= A_img;
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1) begin
			r_C_real_1d		<= 0;
			r_C_img_1d		<= 0;
		end else begin
			r_C_real_1d		<= C_real;
			r_C_img_1d		<= C_img;
		end
	end

	always@(posedge clk) begin
		if(rst == 1) begin
			S_1d	<= 0;
		end else begin
			S_1d	<= S;
		end
	end



	always@(posedge clk)begin
		if(rst==1)begin
			r_x_added_real	<=	0;
		end else begin
			if(S == 1 && enable) begin
				r_x_added_real	<=	A_real + C_real;
			end else begin
				r_x_added_real	<=	r_x_added_real;
			end
		end
	end

	always@(posedge clk)begin
		if(rst==1)begin
			r_x_added_img	<=	0;
		end else begin
			if(S == 1 && enable) begin
				r_x_added_img	<=	A_img + C_img;
			end else begin
				r_x_added_img	<=	r_x_added_img;
			end
		end
	end

	always@(posedge clk)begin
		if(rst==1)begin
			r_x_subtracted_real	<=	0;
		end else begin
			if(S == 1 && enable)begin
				r_x_subtracted_real	<=	C_real - A_real;
			end else begin
				r_x_subtracted_real	<=	r_x_subtracted_real;
			end
		end
	end

	always@(posedge clk)begin
		if(rst==1)begin
			r_x_subtracted_img	<=	0;
		end else begin
			if(S == 1 && enable)begin
				r_x_subtracted_img	<=	C_img - A_img;
			end else begin
				r_x_subtracted_img	<=	r_x_subtracted_img;
			end
		end
	end


	assign B_real			=	(S_1d)? r_x_subtracted_real:r_A_real_1d;
	assign B_img				=	(S_1d)? r_x_subtracted_img :r_A_img_1d;
	assign D_real			=	(S_1d)? r_x_added_real : r_C_real_1d;
	assign D_img				=	(S_1d)? r_x_added_img : r_C_img_1d;

endmodule
