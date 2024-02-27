`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/21 11:14:19
//////////////////////////////////////////////////////////////////////////////////

module fft_general_tb( );
	reg				clk;
reg                rst;
wire            valid;
wire[32-1:0]    data_real;
wire[32-1:0]    data_img;
wire[32-1:0]    out_real;
wire[32-1:0]    out_img;
wire            w_start;
wire            w_ending;
wire            w_start;
wire            w_ending;

parameter period = 10;
initial begin
    clk = 1;
    rst = 1;
    #30
    rst = 0;
end
always #(period/2) clk = ~clk;

fft_32 fft_32(
.clk            (    clk        ),
.rst            (    rst        ),
.start            (    w_start),
.over            (    w_ending),
.data_in_real    (    data_real),
.data_in_img    (    data_img),
.data_out_real    (    out_real),
.data_out_img    (    out_img),
.start_next        (    w_start),
.end_next        (    w_ending)
);


data_gen #(.layer (5))
data_gen_16(
.clk        (clk),
.rst        (rst),
.data_real    (data_real),
.data_img    (data_img),
.valid        (valid),
.start        (w_start),
.over        (w_ending)
);

endmodule
