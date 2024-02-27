`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: This is used for xilinx version
// Engineer: 

module multiplier_tb();

reg		[31:0]		a;
reg		[31:0]		b;
reg		[17:0]		c;
reg					clk;
reg		[17:0]		d;
reg					rstn = 1;
reg					ceabcd = 1;
wire	[50-1:0]	w_data_img;
wire	[50-1:0]	w_data_real;
wire	[32-1:0]	w_data_real_trunc;
wire	[32-1:0]	w_data_img_trunc;



//Clock process
parameter PERIOD = 10;
always #(PERIOD/2) clk = ~clk;


//Unit Instantiate
multiplier multiplier(
	.a(a),
	.b(b),
	.c(c),
	.d(d),
	.clk(clk),
	.rstn(1),
	.data_img(w_data_img),
	.data_real(w_data_real),
	.data_real_trunc(w_data_real_trunc),
	.data_img_trunc(w_data_img_trunc)
);

//Stimulus process
initial begin
	clk = 1;
	a = 0;
	b = 0; 
	c = 0;
	d = 0;
end

initial begin
	#30
	a = 1;
	b = 0; 
	c = 1;
	d = 0;
	#10
	a = 2;
	b = 0; 
	c = 2;
	d = 0;
	#10
	a = 1;
	b = 1; 
	c = 1;
	d = 1;
	#10
	a = 3;
	b = 1; 
	c = 1;
	d = -1;
	#10
	a = 13;
	b = 11; 
	c = 12;
	d = -1; 
end


endmodule
