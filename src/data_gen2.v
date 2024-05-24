`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 2023/11/28 11:13:23


`timescale 1ns / 1ps
module FFT_test2();


reg clk;
reg rst_n;
reg data_finish_flag;

wire              fft_s_config_tready;

reg signed [63:0] fft_s_data_tdata;
reg               fft_s_data_tvalid;
wire              fft_s_data_tready;
reg               fft_s_data_tlast;

wire signed [63:0] fft_m_data_tdata;
wire signed [7:0]  fft_m_data_tuser;
wire               fft_m_data_tvalid;
reg                fft_m_data_tready;
wire               fft_m_data_tlast;

wire          fft_event_frame_started;
wire          fft_event_tlast_unexpected;
wire          fft_event_tlast_missing;
wire          fft_event_status_channel_halt;
wire          fft_event_data_in_channel_halt;
wire          fft_event_data_out_channel_halt;


reg signed [31:0] fft_i_out;
reg signed [31:0] fft_q_out;
reg signed [63:0] fft_abs;

// 存储待仿真验证的数据
reg signed [31:0] Time_data_I[16383:0];  
parameter Process_time = 32957;
parameter Data_length = 16384;
parameter Data_width = 14;
reg [15:0]   count1;

reg [1:0]     data_type ;
localparam DATA1 = 2'b00;
localparam DATA2 = 2'b01;
localparam DATA3 = 2'b10;
localparam DATA4 = 2'b11;

initial begin
     $readmemb("E:/0codes/vivado_project/Cos1.txt",Time_data_I);  
end

initial begin
    clk = 1'b1;
    rst_n = 1'b0;
    fft_m_data_tready = 1'b1;
end

always #5 clk = ~clk;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fft_s_data_tvalid <= 1'b0;
        fft_s_data_tdata  <= 64'd0;
        fft_s_data_tlast  <= 1'b0;
        data_finish_flag  <= 1'b0;
        count1 <= 0;
        data_type = DATA1;
        rst_n = 1'b1;
    end
    
    else if (fft_s_data_tready) begin 
        if( count1== Data_length-1 ) begin
            fft_s_data_tvalid <= 1'b1;
            fft_s_data_tlast  <= 1'b1;
            fft_s_data_tdata  <= {Time_data_I[  count1 ],32'd0};
            data_finish_flag <= 1'b1;
            count1 <= count1 + 1'b1;
            //data_type <= data_type + 1'b1;
        end
        else if (count1 <  Data_length-1 ) begin
            fft_s_data_tvalid <= 1'b1;
            fft_s_data_tlast  <= 1'b0;
            fft_s_data_tdata  <= {Time_data_I[   count1   ] , 32'd0};   //
            count1 <= count1 + 1'b1;
        end
        else if( count1> Data_length -1) begin
            count1 <= count1 + 1'b1;
            fft_s_data_tvalid <= 1'b0;
            fft_s_data_tlast <= 1'b0;
            fft_s_data_tdata <= fft_s_data_tdata;
            data_finish_flag <= 1'b0;
        end
    end
end



// 生成状态机
always@( posedge fft_m_data_tlast ) begin
    
    count1 <= 0;
    case(data_type)
        DATA1: begin
            $readmemb("E:/0codes/vivado_project/Cos1.txt",Time_data_I);
            data_type <= DATA2;
       end
        DATA2: begin
             $readmemb("E:/0codes/vivado_project/Cos2.txt",Time_data_I);
             data_type <= DATA3;
       end 
       DATA3: begin
             $readmemb("E:/0codes/vivado_project/Cos3.txt",Time_data_I);
             data_type <= DATA4;
       end
       DATA4: begin
             $readmemb("E:/0codes/vivado_project/Cos4.txt",Time_data_I);
             data_type <= DATA1;
       end
        default: begin
                data_type <= DATA1;
        end
    endcase
end
 
endmodule


