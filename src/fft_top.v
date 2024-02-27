`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Guan Shixun
// Create Date: 2023/10/18

`timescale 1ns / 1ps
module fft_top(
	input				clk,
	input				rst,
	input				start,
	input				over,
	input	[3:0]		data_config,
	input	[32-1:0]	data_real,
	input	[32-1:0]	data_img,
	output	[32-1:0]	out_real,
	output	[32-1:0]	out_img,
	output				out_first,
	output				out_last
);

	wire	[32-1:0]	w_out_real_16k;
	wire	[32-1:0]	w_out_img_16k;
	wire				w_start_8k;
	wire				w_end_8k;
	fft_16k fft_16k(
		.clk				(		clk			),
		.rst				(		rst			),
		.start				(		start		),
		.over				(		over		),
		.data_in_real		(		data_real	),
		.data_in_img		(		data_img	),
		.data_out_real		(		w_out_real_16k),
		.data_out_img		(		w_out_img_16k),
		.start_next			(		w_start_8k	),
		.end_next			(		w_end_8k	)
	);

	wire	[32-1:0]	w_out_real_8k;
	wire	[32-1:0]	w_out_img_8k;
	wire				w_start_4k;
	wire				w_end_4k;
	fft_8k fft_8k(
		.clk				(		clk			),
		.rst				(		rst			),
		.start				(		w_start_8k	),
		.over				(		0		),
		.data_in_real		(		w_out_real_16k	),
		.data_in_img		(		w_out_img_16k	),
		.data_out_real		(		w_out_real_8k),
		.data_out_img		(		w_out_img_8k),
		.start_next			(		w_start_4k	),
		.end_next			(		w_end_4k	)
	);


	wire	[32-1:0]	w_out_real_4k;
	wire	[32-1:0]	w_out_img_4k;
	wire				w_start_2k;
	wire				w_end_2k;
	fft_4k fft_4k(
		.clk				(		clk			),
		.rst				(		rst			),
		.start				(		w_start_4k	),
		.over				(		0			),
		.data_in_real		(		w_out_real_8k),
		.data_in_img		(		w_out_img_8k),
		.data_out_real		(		w_out_real_4k),
		.data_out_img		(		w_out_img_4k),
		.start_next			(		w_start_2k	),
		.end_next			(		w_end_2k	)
	);

	wire	[32-1:0]	w_out_real_2k;
	wire	[32-1:0]	w_out_img_2k;
	wire				w_start_1k;
	wire				w_end_1k;
	fft_2k fft_2k(
		.clk				(		clk			),
		.rst				(		rst			),
		.start				(		w_start_2k		),
		.over				(		0		),
		.data_in_real		(		w_out_real_4k	),
		.data_in_img		(		w_out_img_4k	),
		.data_out_real		(		w_out_real_2k),
		.data_out_img		(		w_out_img_2k),
		.start_next			(		w_start_1k	),
		.end_next			(		w_end_1k	)
	);

	wire	[32-1:0]	w_out_real_1k;
	wire	[32-1:0]	w_out_img_1k;
	wire				w_start_512;
	wire				w_end_512;
	fft_1k fft_1k(
		.clk				(		clk			),
		.rst				(		rst			),
		.start				(		w_start_1k	),
		.over				(		0	),
		.data_in_real		(		w_out_real_2k),
		.data_in_img		(		w_out_img_2k),
		.data_out_real		(		w_out_real_1k),
		.data_out_img		(		w_out_img_1k),
		.start_next			(		w_start_512	),
		.end_next			(		w_end_512	)
	);

	wire	[32-1:0]	w_out_real_512;
	wire	[32-1:0]	w_out_img_512;
	wire				w_start_256;
	wire				w_end_256;
	fft_512 fft_512(
		.clk				(		clk			),
		.rst				(		rst			),
		.start				(		w_start_512	),
		.over				(		0	),
		.data_in_real		(		w_out_real_1k),
		.data_in_img		(		w_out_img_1k),
		.data_out_real		(		w_out_real_512),
		.data_out_img		(		w_out_img_512),
		.start_next			(		w_start_256	),
		.end_next			(		w_end_256	)
	);


	wire	[32-1:0]	w_out_real_256;
	wire	[32-1:0]	w_out_img_256;
	wire				w_start_128;
	wire				w_end_128;
	fft_256 fft_256(
		.clk				(		clk			),
		.rst				(		rst			),
		.start				(		w_start_256	),
		.over				(		0	),
		.data_in_real		(		w_out_real_512	),
		.data_in_img		(		w_out_img_512	),
		.data_out_real		(		w_out_real_256),
		.data_out_img		(		w_out_img_256),
		.start_next			(		w_start_128	),
		.end_next			(		w_end_128	)
	);


	wire	[32-1:0]	w_out_real_128;
	wire	[32-1:0]	w_out_img_128;
	wire				w_start_64;
	wire				w_end_64;
	fft_128 fft_128(
		.clk				(		clk			),
		.rst				(		rst			),
		.start				(		w_start_128	),
		.over				(		0	),
		.data_in_real		(		w_out_real_256),
		.data_in_img		(		w_out_img_256),
		.data_out_real		(		w_out_real_128),
		.data_out_img		(		w_out_img_128),
		.start_next			(		w_start_64	),
		.end_next			(		w_end_64	)
	);

	wire	[32-1:0]	w_out_real_64;
	wire	[32-1:0]	w_out_img_64;
	wire				w_start32;
	wire				w_end32;
	fft_64 fft_64(
		.clk				(		clk			),
		.rst				(		rst			),
		.start				(		w_start_64	),
		.over				(		0	),
		.data_in_real		(		w_out_real_128),
		.data_in_img		(		w_out_img_128),
		.data_out_real		(		w_out_real_64),
		.data_out_img		(		w_out_img_64),
		.start_next			(		w_start32	),
		.end_next			(		w_end32		)
	);

	wire	[32-1:0]	w_out_real_32;
	wire	[32-1:0]	w_out_img_32;
	wire				w_start16;
	wire				w_end16;
	fft_32 fft_32(
		.clk				(		clk			),
		.rst				(		rst			),
		.start				(		w_start32	),
		.over				(		0	),
		.data_in_real		(		w_out_real_64),
		.data_in_img		(		w_out_img_64),
		.data_out_real		(		w_out_real_32),
		.data_out_img		(		w_out_img_32),
		.start_next			(		w_start16	),
		.end_next			(		w_end16		)
	);

	wire	[32-1:0]	w_out_real_16;
	wire	[32-1:0]	w_out_img_16;
	wire				w_start8;
	wire				w_end8;
	fft_16 fft_16(
		.clk			(		clk		),
		.rst			(		rst		),
		.start16		(		w_start16	),
		.end16			(		0),
		.A_real			(		w_out_real_32),
		.A_img			(		w_out_img_32),
		.out_real_16	(		w_out_real_16),
		.out_img_16		(		w_out_img_16),
		.start8			(		w_start8),
		.end8			(		w_end8)
	);

	wire	[32-1:0]	w_out_real8;
	wire	[32-1:0]	w_out_img8;
	wire				w_start4;
	wire				w_end4;
	fft_8 fft_8(
		.clk		(		clk		),
		.rst		(		rst		),
		.start8		(		w_start8	),
		.end8		(		w_end8),
		.A_real		(		w_out_real_16),
		.A_img		(		w_out_img_16),
		.out_real8	(		w_out_real8),
		.out_img8	(		w_out_img8),
		.start4		(		w_start4),
		.end4		(		w_end4)
	);

	wire	[32-1:0]	w_out_real4;
	wire	[32-1:0]	w_out_img4;
	wire				w_start2;
	wire				w_end2;


	fft_4 fft_4(
		.clk		(		clk		),
		.rst		(		rst		),
		.start4		(		w_start4),
		.end4		(		w_end4),
		.A_real		(		w_out_real8),
		.A_img		(		w_out_img8),
		.out_real4	(		w_out_real4),
		.out_img4	(		w_out_img4),
		.start2		(		w_start2),
		.end2		(		w_end2)
	);

	wire	[32-1:0]	w_out_real2;
	wire	[32-1:0]	w_out_img2;
	wire				w_out_start;
	fft_2 fft_2(
		.clk		(		clk		),
		.rst		(		rst		),
		.A_real		(		w_out_real4),
		.A_img		(		w_out_img4),
		.start2		(		w_start2),
		.end2		(		w_end2),
		.out_real2	(		w_out_real2),
		.out_img2	(		w_out_img2),
		.out_start	(		w_out_start)
	);

	assign	out_real = w_out_real2;
	assign	out_img = w_out_img2;
	assign	out_first = w_out_start;

endmodule