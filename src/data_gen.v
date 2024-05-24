`timescale 1ns / 1ps
module data_gen #(parameter layer = 1)(
	input				clk,
	input				rst,
	output	[32-1:0]	data_real,
	output	[32-1:0]	data_img,
	output				valid,
	output				start,
	output				over
	);
	
	parameter			WAIT_CLK_NUM = 1<<layer;
	parameter			DATA_NUM = 1<<(layer+2);
	reg		[15:0]		PERIOD = 1<<layer;
	reg		[15-1:0]	data_real_tmp;
	reg		[15-1:0]	data_img_tmp;
	reg					valid_tmp;
	reg		[15:0]		counter_for_valid;
	reg		[15:0]		counter;
	reg					r_start;
	reg					r_ending;
	
	 always@(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			valid_tmp	<=	'd0;
		end else begin
			if(counter_for_valid == (PERIOD)/2-1)begin
				valid_tmp	<=	~valid_tmp;
			end else if (counter_for_valid == PERIOD-1)begin
				valid_tmp	<=	~valid_tmp;
			end else begin
				valid_tmp	<=	valid_tmp;
			end
		end
	end 

	 always@(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			counter_for_valid	<=	'd0;
		end else begin
			if(counter_for_valid == PERIOD-1)begin
				counter_for_valid	<=	0;
			end else begin
				counter_for_valid	<=	counter_for_valid+1;
			end
		end
	end 

	 always@(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			counter	<=	'd0;
		end else begin
			if(counter == DATA_NUM-1)begin
				counter	<=	0;
			end else begin
				counter	<=	counter+1;
			end
		end
	end 


	 always@(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			r_start	<=	'd0;
		end else begin
			if(counter == WAIT_CLK_NUM-1 - 1)begin
				r_start	<=	1;
			end else begin
				r_start	<=	0;
			end
		end
	end 

	 always@(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
				r_ending<=	'd0;
		end else begin
			if(counter == DATA_NUM-2)begin
				r_ending	<=	1;
			end else begin
				r_ending	<=	0;
			end
		end
	end 


	always@(posedge clk) begin
		if(rst == 1)begin
			data_real_tmp <= 0;
		end else begin
			if(data_real_tmp == PERIOD-1)begin
				data_real_tmp <= 0;
			end else begin
				data_real_tmp <= data_real_tmp + 1;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst == 1)begin
			data_img_tmp <= 0;
		end else begin
			if(data_img_tmp == 7)begin
				data_img_tmp <= 0;
			end else begin
				data_img_tmp <= data_img_tmp + 1;
			end
		end
	end

//fixed point number with 15 integer and 16 fraction part
	/* assign	data_real = {{1'b0},data_real_tmp,{16{1'b0}}}; */
	//assign	data_real = data_real_tmp << 16;
	assign	data_real = data_real_tmp;
	assign	data_img = 0;
	assign	valid = valid_tmp;
	assign	start = r_start;
	assign	over = r_ending;

endmodule