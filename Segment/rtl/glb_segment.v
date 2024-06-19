// 消耗三帧

module glb_segment #
(
    parameter H_DISP            = 12'd640       ,   //图像宽度
    parameter V_DISP            = 12'd480           //图像高度
)
(
    input   wire                clk             ,
    input   wire                rst_n           ,
    input   wire                Y_hsync         ,   //Y分量场同步
    input   wire                Y_vsync         ,   //Y分量数据
    input   wire    [ 7:0]      Y_data          ,   //Y分量数据使能
    input   wire                Y_de            ,   //Y分量行同步

//    input   wire    [ 7:0]      value           ,   //sobel阈值

    output  wire                segment_hsync     ,   //输出数据场同步
    output  wire                segment_vsync     ,   //输出数据
    output  reg     [ 7:0]      segment_data      ,   //输出数据使能
    output  wire                segment_de            //输出数据行同步

);

reg     [31:0]      sum_pixel;
wire    [31:0]      divisor = H_DISP*V_DISP;

//wire                mean_pixel_vld,m1_vld ,m2_vld ;//
//wire    [63:0]      div_out1,div_out2,div_out3;//
reg     [ 7:0]      mean_pixel=8'd0;// 
reg     [ 7:0]      m1_data,m2_data;// 
reg     [31:0]      under_sum,over_sum;
reg     [23:0]      under_sum_cnt,over_sum_cnt;
reg     [ 7:0]      threshold;

//************************************************************//
// 信号同步
parameter DLY_CYCLE = 2 ;

reg     [DLY_CYCLE-1:0]      Y_de_d                  ;
reg     [DLY_CYCLE-1:0]      Y_hsync_d               ;
reg     [DLY_CYCLE-1:0]      Y_vsync_d               ;

wire Y_vsync_pedge;
wire Y_vsync_nedge;

// 舍弃前两帧，实际的阈值分割只消耗1clk
// 信号同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Y_de_d    <= {(DLY_CYCLE){1'b0}};
        Y_hsync_d <= {(DLY_CYCLE){1'b0}};
        Y_vsync_d <= {(DLY_CYCLE){1'b0}};
    end
    else begin
        Y_de_d    <= {Y_de_d   [(DLY_CYCLE-2):0],    Y_de};
        Y_hsync_d <= {Y_hsync_d[(DLY_CYCLE-2):0], Y_hsync};
        Y_vsync_d <= {Y_vsync_d[(DLY_CYCLE-2):0], Y_vsync};
    end
end

//assign segment_de    = Y_de_d   [DLY_CYCLE-1];
//assign segment_hsync = Y_hsync_d[DLY_CYCLE-1];
//assign segment_vsync = Y_vsync_d[DLY_CYCLE-1];

assign segment_de    = Y_de_d   [0];
assign segment_hsync = Y_hsync_d[0];
assign segment_vsync = Y_vsync_d[0];

assign Y_vsync_pedge = Y_vsync_d[0] & ~Y_vsync_d[1];
assign Y_vsync_nedge = ~Y_vsync_d[0] & Y_vsync_d[1];

// 要等第3帧才是有效数据
//reg                     glb_vld         ;   //第一帧结束
reg      [1:0]          frame_cnt         ;   //

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        frame_cnt <= 2'd0;
    else if(frame_cnt == 2'd3)
        frame_cnt <= frame_cnt;
    else if(Y_vsync_nedge)
        frame_cnt <= frame_cnt  + 1'b1;
end

//always @(posedge clk) begin
//    if(!rst_n)
//        glb_vld <= 1'b0;
//    else if(frame_cnt == 2'd3)
//        glb_vld <= 1'b1;
//end
//************************************************************//

//************************************************************//
// 计算所有像素值之和，耗费一帧时间
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_pixel <= 32'd0;
    end
    else if(Y_vsync_nedge)begin
        sum_pixel <= 32'd0;
    end
    else if(Y_de && (frame_cnt == 2'd1))begin
        sum_pixel <= sum_pixel + Y_data;
    end
end
// 计算原图灰度平均值，除法耗费一个clk
//div_32bit u1_div_32bit
//(
//    .aclk                   (clk            ),
//    .s_axis_divisor_tvalid  (1'b1           ),
//    .s_axis_divisor_tdata   (divisor        ),
//    .s_axis_dividend_tvalid (Y_vsync_nedge  ),
//    .s_axis_dividend_tdata  (sum_pixel      ),
//
//    .m_axis_dout_tvalid     (mean_pixel_vld ),
//    .m_axis_dout_tdata      (div_out1       )
//);

//div_32bit  div_32bit_inst1
//(
//    .clock      (clk                ),
//    .denom      (divisor            ),// 分母（除数）
//    .numer      (sum_pixel          ),// 分子（被除数）
//
//    .quotient   (div_out1[63:32]    ),// 商
//    .remain     (div_out1[31:0]     ) // 余数
//);
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mean_pixel <= 8'h00;
    end
    else if(Y_vsync_nedge && (frame_cnt == 2'd1))begin  
        mean_pixel <= sum_pixel / divisor;
    end
end
//assign mean_pixel = mean_pixel_vld ? div_out1[39:32] : mean_pixel;
//assign mean_pixel = div_out1[39:32];
// 统计大于均值和小于均值的像素之和以及对应的像素个数，耗费一帧时间
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        under_sum_cnt <= 24'd0;
        over_sum_cnt  <= 24'd0;
    end
    else if(Y_vsync_nedge) begin
        under_sum_cnt <= 24'd0;
        over_sum_cnt  <= 24'd0;
    end
    else if(Y_de && (frame_cnt == 2'd2))begin
        if (Y_data >= mean_pixel)
            over_sum_cnt  <= over_sum_cnt + 1'b1;
        else
            under_sum_cnt <= under_sum_cnt + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        under_sum <= 32'd0;
        over_sum  <= 32'd0;
    end
    else if(Y_de && (frame_cnt == 2'd2))begin
        if (Y_data >= mean_pixel)
            over_sum  <= over_sum + Y_data;
        else
            under_sum <= under_sum + Y_data;
    end
end

// 计算分区之后的两个平均值，除法耗费一个clk
//div_32bit u2_div_32bit
//(
//    .aclk                   (clk            ),
//    .s_axis_divisor_tvalid  (1'b1           ),
//    .s_axis_divisor_tdata   (under_sum_cnt  ),
//    .s_axis_dividend_tvalid (Y_vsync_nedge  ),
//    .s_axis_dividend_tdata  (under_sum      ),
//
//    .m_axis_dout_tvalid     (m1_vld         ),
//    .m_axis_dout_tdata      (div_out2       )
//);

//div_32bit  div_32bit_inst2
//(
//    .clock      (clk                ),
//    .denom      (under_sum_cnt      ),// 分母（除数）
//    .numer      (under_sum          ),// 分子（被除数）
//
//    .quotient   (div_out2[63:32]    ),// 商
//    .remain     (div_out2[31:0]     ) // 余数
//);

//div_32bit u3_div_32bit
//(
//    .aclk                   (clk            ),
//    .s_axis_divisor_tvalid  (1'b1           ),
//    .s_axis_divisor_tdata   (over_sum_cnt   ),
//    .s_axis_dividend_tvalid (Y_vsync_nedge  ),
//    .s_axis_dividend_tdata  (over_sum       ),
//
//    .m_axis_dout_tvalid     (m2_vld         ),
//    .m_axis_dout_tdata      (div_out3       )
//);

//div_32bit  div_32bit_inst3
//(
//    .clock      (clk                ),
//    .denom      (over_sum_cnt       ),// 分母（除数）
//    .numer      (over_sum           ),// 分子（被除数）
//
//    .quotient   (div_out3[63:32]    ),// 商
//    .remain     (div_out3[31:0]     ) // 余数
//);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        m1_data <= 8'h00;
    end
    else if(Y_vsync_nedge && (frame_cnt == 2'd2))begin  
        m1_data <= under_sum / under_sum_cnt;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        m2_data <= 8'h00;
    end
    else if(Y_vsync_nedge && (frame_cnt == 2'd2))begin  
        m2_data <= over_sum / over_sum_cnt;
    end
end

//assign m1_data = m1_vld ? div_out2[39:32] : m1_data;
//assign m2_data = m2_vld ? div_out3[39:32] : m2_data;
//assign m1_data = div_out2[39:32];
//assign m2_data = div_out3[39:32];

// 计算阈值，耗费一个clk
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        threshold <= 8'h00;
    end
//    else if(m1_vld && m2_vld) begin  
    else begin  
        threshold <= (m1_data + m2_data) >> 1;
    end
end

// 阈值分割，消耗一帧
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        segment_data <= 8'h00;
    end
    else if(Y_de && (frame_cnt == 2'd3))begin
        segment_data <= (Y_data > threshold) ? 8'h00 : 8'hff;
    end
end

endmodule