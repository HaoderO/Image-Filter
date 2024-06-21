module adp_segment #
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

parameter DLY_CYCLE = 7 ;

wire     [ 7:0]      matrix_11,matrix_12,matrix_13;
wire     [ 7:0]      matrix_21,matrix_22,matrix_23;
wire     [ 7:0]      matrix_31,matrix_32,matrix_33;

reg      [ 7:0]      Y_data_d1,Y_data_d2,Y_data_d3;
wire     [ 7:0]      matrix_11_d3,matrix_12_d3,matrix_13_d3;
wire     [ 7:0]      matrix_21_d3,matrix_22_d3,matrix_23_d3;
wire     [ 7:0]      matrix_31_d3,matrix_32_d3,matrix_33_d3;

reg     [10:0]      sum_1x,sum_2x,sum_3x;

reg     [12:0]      sum_matrix;

reg     [ 7:0]      mean_matrix;

reg     [7:0]       sub_mean_11,sub_mean_12,sub_mean_13;
reg     [7:0]       sub_mean_21,sub_mean_22,sub_mean_23;
reg     [7:0]       sub_mean_31,sub_mean_32,sub_mean_33;


reg     [20:0]      square_mean_22,square_mean_matrix;

reg     [DLY_CYCLE-1:0]      Y_de_d                  ;
reg     [DLY_CYCLE-1:0]      Y_hsync_d               ;
reg     [DLY_CYCLE-1:0]      Y_vsync_d               ;

//************************************************************//
// clk1
matrix_3x3_8bit # 
(
    .H_DISP     (H_DISP         ),
    .V_DISP     (V_DISP         )
)
matrix_3x3_8bit_inst 
(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .din_vld    (Y_de           ),
    .din        (Y_data         ),

    .matrix_11(matrix_11),.matrix_12(matrix_12),.matrix_13(matrix_13),
    .matrix_21(matrix_21),.matrix_22(matrix_22),.matrix_23(matrix_23),
    .matrix_31(matrix_31),.matrix_32(matrix_32),.matrix_33(matrix_33)
);
//************************************************************//

//************************************************************//
// clk2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_1x <= 11'd0;
        sum_2x <= 11'd0;
        sum_3x <= 11'd0;
    end
    else begin
        sum_1x <= matrix_11 + matrix_12 + matrix_13;
        sum_2x <= matrix_21 + matrix_22 + matrix_23;
        sum_3x <= matrix_31 + matrix_32 + matrix_33;
    end
end
// clk3
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum_matrix <= 13'd0;
    end
    else begin
        sum_matrix <= sum_1x + sum_2x + sum_3x;
    end
end
// clk4
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mean_matrix <= 13'd0;
    end
    else begin
        mean_matrix <= sum_matrix/9;
    end
end
// 像素同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Y_data_d1 <= 8'd0;
        Y_data_d2 <= 8'd0;
        Y_data_d3 <= 8'd0;
    end
    else begin
        Y_data_d1 <= Y_data;
        Y_data_d2 <= Y_data_d1;
        Y_data_d3 <= Y_data_d2;
    end
end

matrix_3x3_8bit # 
(
    .H_DISP     (H_DISP         ),
    .V_DISP     (V_DISP         )
)
matrix_3x3_8bit_syn 
(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .din_vld    (Y_de_d[2]      ), 
    .din        (Y_data_d3      ),

    .matrix_11(matrix_11_d3),.matrix_12(matrix_12_d3),.matrix_13(matrix_13_d3),
    .matrix_21(matrix_21_d3),.matrix_22(matrix_22_d3),.matrix_23(matrix_23_d3),
    .matrix_31(matrix_31_d3),.matrix_32(matrix_32_d3),.matrix_33(matrix_33_d3)
);
// clk5 各像素与均值之差的绝对值
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sub_mean_11 <= 8'd0;
        sub_mean_12 <= 8'd0;
        sub_mean_13 <= 8'd0;
        sub_mean_21 <= 8'd0;
        sub_mean_22 <= 8'd0;
        sub_mean_23 <= 8'd0;
        sub_mean_31 <= 8'd0;
        sub_mean_32 <= 8'd0;
        sub_mean_33 <= 8'd0;
    end
    else begin
        sub_mean_11 <= (matrix_11_d3 > mean_matrix) ? (matrix_11_d3 - mean_matrix) : (mean_matrix - matrix_11_d3);
        sub_mean_12 <= (matrix_12_d3 > mean_matrix) ? (matrix_12_d3 - mean_matrix) : (mean_matrix - matrix_12_d3);
        sub_mean_13 <= (matrix_13_d3 > mean_matrix) ? (matrix_13_d3 - mean_matrix) : (mean_matrix - matrix_13_d3);
        sub_mean_21 <= (matrix_21_d3 > mean_matrix) ? (matrix_21_d3 - mean_matrix) : (mean_matrix - matrix_21_d3);
        sub_mean_22 <= (matrix_22_d3 > mean_matrix) ? (matrix_22_d3 - mean_matrix) : (mean_matrix - matrix_22_d3);
        sub_mean_23 <= (matrix_23_d3 > mean_matrix) ? (matrix_23_d3 - mean_matrix) : (mean_matrix - matrix_23_d3);
        sub_mean_31 <= (matrix_31_d3 > mean_matrix) ? (matrix_31_d3 - mean_matrix) : (mean_matrix - matrix_31_d3);
        sub_mean_32 <= (matrix_32_d3 > mean_matrix) ? (matrix_32_d3 - mean_matrix) : (mean_matrix - matrix_32_d3);
        sub_mean_33 <= (matrix_33_d3 > mean_matrix) ? (matrix_33_d3 - mean_matrix) : (mean_matrix - matrix_33_d3);
    end
end

// clk6 
// 中心像素与均值之差的绝对值的平方x25
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        square_mean_22 <= 21'd0;
    end
    else begin
        square_mean_22 <= (sub_mean_33*sub_mean_33)*25;
    end
end

// 各像素与均值之差的绝对值的平方和
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        square_mean_matrix <= 21'd0;
    end
    else begin
        square_mean_matrix <= (sub_mean_11*sub_mean_11) + (sub_mean_12*sub_mean_12) + (sub_mean_13*sub_mean_13) +
                              (sub_mean_21*sub_mean_21) + (sub_mean_22*sub_mean_22) + (sub_mean_23*sub_mean_23) +
                              (sub_mean_31*sub_mean_31) + (sub_mean_32*sub_mean_32) + (sub_mean_33*sub_mean_33);
    end
end

// clk7
// 阈值分割
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        segment_data <= 8'h00;
    end
    else begin  
        segment_data <= (square_mean_22 > square_mean_matrix) ? 8'hff : 8'h00;
    end
end

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

assign segment_de    = Y_de_d   [DLY_CYCLE-1];
assign segment_hsync = Y_hsync_d[DLY_CYCLE-1];
assign segment_vsync = Y_vsync_d[DLY_CYCLE-1];
    
endmodule