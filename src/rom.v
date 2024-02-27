`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/01 21:57:59
// Design Name: 
// Module Name: rom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module rom(
	
	input   wire           clk,
	input   wire           rst_n,
	output   wire     [7:0]    q
	);
	
	wire     [9:0]      addr;
	
	addr_ctrl addr_ctrl_inst(
	
	.clk      (clk),
	.rst_n      (rst_n),
	.addr      (addr)  
	);
	
	blk_mem_gen_0 blk_mem_gen_0_inst (
		.clka(clk),    // input wire clka
		.addra(addr),  // input wire [9 : 0] addra
		.douta(q)  // output wire [7 : 0] douta
	);
	
	endmodule
