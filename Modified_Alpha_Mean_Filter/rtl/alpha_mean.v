module alpha_mean
#(
    parameter H_DISP        = 12'd480           ,   //图像宽度
    parameter V_DISP        = 12'd272               //图像高度
)
(
    input   wire            clk                 ,   //时钟
    input   wire            rst_n               ,   //复位
    input   wire            Y_hsync             ,   //Y分量行同步
    input   wire            Y_vsync             ,   //Y分量场同步
    input   wire    [ 7:0]  Y_data              ,   //Y分量数据
    input   wire            Y_de                ,   //Y分量数据使能

    output  wire            mean_hsync        ,   //mean行同步
    output  wire            mean_vsync        ,   //mean场同步
    output  reg     [ 7:0]  mean_data         ,   //mean数据
    output  wire            mean_de               //mean数据使能
);

parameter DLY_CYCLE = 5 ;


wire     [ 7:0]      matrix_11,matrix_12,matrix_13,matrix_14,matrix_15;
wire     [ 7:0]      matrix_21,matrix_22,matrix_23,matrix_24,matrix_25;
wire     [ 7:0]      matrix_31,matrix_32,matrix_33,matrix_34,matrix_35;
wire     [ 7:0]      matrix_41,matrix_42,matrix_43,matrix_44,matrix_45;
wire     [ 7:0]      matrix_51,matrix_52,matrix_53,matrix_54,matrix_55;  

wire     [ 7:0]      matrix_11_d2,matrix_12_d2,matrix_13_d2,matrix_14_d2,matrix_15_d2;
wire     [ 7:0]      matrix_21_d2,matrix_22_d2,matrix_23_d2,matrix_24_d2,matrix_25_d2;
wire     [ 7:0]      matrix_31_d2,matrix_32_d2,matrix_33_d2,matrix_34_d2,matrix_35_d2;
wire     [ 7:0]      matrix_41_d2,matrix_42_d2,matrix_43_d2,matrix_44_d2,matrix_45_d2;
wire     [ 7:0]      matrix_51_d2,matrix_52_d2,matrix_53_d2,matrix_54_d2,matrix_55_d2;

reg     [ 7:0]      matrix_11_d3,matrix_12_d3,matrix_13_d3,matrix_14_d3,matrix_15_d3;
reg     [ 7:0]      matrix_21_d3,matrix_22_d3,matrix_23_d3,matrix_24_d3,matrix_25_d3;
reg     [ 7:0]      matrix_31_d3,matrix_32_d3,matrix_33_d3,matrix_34_d3,matrix_35_d3;
reg     [ 7:0]      matrix_41_d3,matrix_42_d3,matrix_43_d3,matrix_44_d3,matrix_45_d3;
reg     [ 7:0]      matrix_51_d3,matrix_52_d3,matrix_53_d3,matrix_54_d3,matrix_55_d3;

//同步 
reg     [DLY_CYCLE-1:0]      Y_de_d                  ;
reg     [DLY_CYCLE-1:0]      Y_hsync_d               ;
reg     [DLY_CYCLE-1:0]      Y_vsync_d               ;
reg      [ 7:0]      Y_data_d1,Y_data_d2;

    //中值滤波，耗费3clk
//每行像素降序排列，clk1
//第1列

parameter DW = 8                    ; //数据位宽
parameter DN = 25                   ; //数据个数
parameter DW_sequence = $clog2(DN)  ; //序号位宽

//--------------------------------------------
//端口定义
//--------------------------------------------    
wire                         sort_sig          ;
wire    [DW*DN-1:0]          data_unsort       ;
wire    [DW_sequence*DN-1:0] sequence_sorted   ;
wire                         sort_finish       ;
// sequence_sorted_0到sequence_sorted_24的值分别为
// matrix_11到matrix_55经过排序之后的序号
// 0到24 => 从小到大
wire    [DW_sequence-1:0]    sequence_sorted_0 ;
wire    [DW_sequence-1:0]    sequence_sorted_1 ;
wire    [DW_sequence-1:0]    sequence_sorted_2 ;
wire    [DW_sequence-1:0]    sequence_sorted_3 ;
wire    [DW_sequence-1:0]    sequence_sorted_4 ;
wire    [DW_sequence-1:0]    sequence_sorted_5 ;
wire    [DW_sequence-1:0]    sequence_sorted_6 ;
wire    [DW_sequence-1:0]    sequence_sorted_7 ;
wire    [DW_sequence-1:0]    sequence_sorted_8 ;
wire    [DW_sequence-1:0]    sequence_sorted_9 ;
wire    [DW_sequence-1:0]    sequence_sorted_10;
wire    [DW_sequence-1:0]    sequence_sorted_11;
wire    [DW_sequence-1:0]    sequence_sorted_12;
wire    [DW_sequence-1:0]    sequence_sorted_13;
wire    [DW_sequence-1:0]    sequence_sorted_14;
wire    [DW_sequence-1:0]    sequence_sorted_15;
wire    [DW_sequence-1:0]    sequence_sorted_16;
wire    [DW_sequence-1:0]    sequence_sorted_17;
wire    [DW_sequence-1:0]    sequence_sorted_18;
wire    [DW_sequence-1:0]    sequence_sorted_19;
wire    [DW_sequence-1:0]    sequence_sorted_20;
wire    [DW_sequence-1:0]    sequence_sorted_21;
wire    [DW_sequence-1:0]    sequence_sorted_22;
wire    [DW_sequence-1:0]    sequence_sorted_23;
wire    [DW_sequence-1:0]    sequence_sorted_24;

// clk1
// 生成矩阵 耗费1clk
matrix_5x5_8bit # 
(
    .H_DISP   (H_DISP   ),
    .V_DISP   (V_DISP   )
)
u_matrix_5x5_8bit 
(
    .clk      (clk      ),
    .rst_n    (rst_n    ),
    .din_vld  (Y_de     ),
    .din      (Y_data   ),

    .out_vld  (sort_sig ),
    .matrix_11(matrix_11),.matrix_12(matrix_12),.matrix_13(matrix_13),.matrix_14(matrix_14),.matrix_15(matrix_15),
    .matrix_21(matrix_21),.matrix_22(matrix_22),.matrix_23(matrix_23),.matrix_24(matrix_24),.matrix_25(matrix_25),
    .matrix_31(matrix_31),.matrix_32(matrix_32),.matrix_33(matrix_33),.matrix_34(matrix_34),.matrix_35(matrix_35),
    .matrix_41(matrix_41),.matrix_42(matrix_42),.matrix_43(matrix_43),.matrix_44(matrix_44),.matrix_45(matrix_45),
    .matrix_51(matrix_51),.matrix_52(matrix_52),.matrix_53(matrix_53),.matrix_54(matrix_54),.matrix_55(matrix_55)
);

assign data_unsort = {matrix_11,matrix_12,matrix_13,matrix_14,matrix_15,
                      matrix_21,matrix_22,matrix_23,matrix_24,matrix_25,
                      matrix_31,matrix_32,matrix_33,matrix_34,matrix_35,
                      matrix_41,matrix_42,matrix_43,matrix_44,matrix_45,
                      matrix_51,matrix_52,matrix_53,matrix_54,matrix_55};

// clk2 ~ clk3
// 并行全排序 耗费2clk
parallel_sort # 
(
    .DN                 (DN             ),
    .DW                 (DW             )
)   
parallel_sort_inst  
(   
    .clk                (clk            ),
    .rst_n              (rst_n          ),
    .sort_sig           (sort_sig       ),
    .data_unsort        (data_unsort    ),

    .sequence_sorted    (sequence_sorted),
    .sort_finish        (sort_finish    )
);

assign sequence_sorted_0  = sequence_sorted[ 0*DW_sequence+:DW_sequence];
assign sequence_sorted_1  = sequence_sorted[ 1*DW_sequence+:DW_sequence];
assign sequence_sorted_2  = sequence_sorted[ 2*DW_sequence+:DW_sequence];
assign sequence_sorted_3  = sequence_sorted[ 3*DW_sequence+:DW_sequence];
assign sequence_sorted_4  = sequence_sorted[ 4*DW_sequence+:DW_sequence];
assign sequence_sorted_5  = sequence_sorted[ 5*DW_sequence+:DW_sequence];
assign sequence_sorted_6  = sequence_sorted[ 6*DW_sequence+:DW_sequence];
assign sequence_sorted_7  = sequence_sorted[ 7*DW_sequence+:DW_sequence];
assign sequence_sorted_8  = sequence_sorted[ 8*DW_sequence+:DW_sequence];
assign sequence_sorted_9  = sequence_sorted[ 9*DW_sequence+:DW_sequence];
assign sequence_sorted_10 = sequence_sorted[10*DW_sequence+:DW_sequence];
assign sequence_sorted_11 = sequence_sorted[11*DW_sequence+:DW_sequence];
assign sequence_sorted_12 = sequence_sorted[12*DW_sequence+:DW_sequence];
assign sequence_sorted_13 = sequence_sorted[13*DW_sequence+:DW_sequence];
assign sequence_sorted_14 = sequence_sorted[14*DW_sequence+:DW_sequence];
assign sequence_sorted_15 = sequence_sorted[15*DW_sequence+:DW_sequence];
assign sequence_sorted_16 = sequence_sorted[16*DW_sequence+:DW_sequence];
assign sequence_sorted_17 = sequence_sorted[17*DW_sequence+:DW_sequence];
assign sequence_sorted_18 = sequence_sorted[18*DW_sequence+:DW_sequence];
assign sequence_sorted_19 = sequence_sorted[19*DW_sequence+:DW_sequence];
assign sequence_sorted_20 = sequence_sorted[20*DW_sequence+:DW_sequence];
assign sequence_sorted_21 = sequence_sorted[21*DW_sequence+:DW_sequence];
assign sequence_sorted_22 = sequence_sorted[22*DW_sequence+:DW_sequence];
assign sequence_sorted_23 = sequence_sorted[23*DW_sequence+:DW_sequence];
assign sequence_sorted_24 = sequence_sorted[24*DW_sequence+:DW_sequence];

// 像素同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Y_data_d1 <= 8'd0;
        Y_data_d2 <= 8'd0;
    end
    else begin
        Y_data_d1 <= Y_data;
        Y_data_d2 <= Y_data_d1;
    end
end

// 将矩阵数据与排序后的序号对齐
matrix_5x5_8bit # 
(
    .H_DISP   (H_DISP   ),
    .V_DISP   (V_DISP   )
)
u_matrix_5x5_8bit_dly
(
    .clk      (clk      ),
    .rst_n    (rst_n    ),
    .din_vld  (Y_de_d[1]    ),
    .din      (Y_data_d2    ),

    .out_vld  (),
    .matrix_11(matrix_11_d2),.matrix_12(matrix_12_d2),.matrix_13(matrix_13_d2),.matrix_14(matrix_14_d2),.matrix_15(matrix_15_d2),
    .matrix_21(matrix_21_d2),.matrix_22(matrix_22_d2),.matrix_23(matrix_23_d2),.matrix_24(matrix_24_d2),.matrix_25(matrix_25_d2),
    .matrix_31(matrix_31_d2),.matrix_32(matrix_32_d2),.matrix_33(matrix_33_d2),.matrix_34(matrix_34_d2),.matrix_35(matrix_35_d2),
    .matrix_41(matrix_41_d2),.matrix_42(matrix_42_d2),.matrix_43(matrix_43_d2),.matrix_44(matrix_44_d2),.matrix_45(matrix_45_d2),
    .matrix_51(matrix_51_d2),.matrix_52(matrix_52_d2),.matrix_53(matrix_53_d2),.matrix_54(matrix_54_d2),.matrix_55(matrix_55_d2)
);

// clk4 去除最大的8个数和最小的8个数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_11_d3 <= 8'd0; 
    else if((sequence_sorted_0 < 5'd8) || (sequence_sorted_0 > 5'd15)) matrix_11_d3 <= 8'd0; 
    else matrix_11_d3 <= matrix_11_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_12_d3 <= 8'd0; 
    else if((sequence_sorted_1 < 5'd8) || (sequence_sorted_1 > 5'd15)) matrix_12_d3 <= 8'd0; 
    else matrix_12_d3 <= matrix_12_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_13_d3 <= 8'd0; 
    else if((sequence_sorted_2 < 5'd8) || (sequence_sorted_2 > 5'd15)) matrix_13_d3 <= 8'd0; 
    else matrix_13_d3 <= matrix_13_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_14_d3 <= 8'd0; 
    else if((sequence_sorted_3 < 5'd8) || (sequence_sorted_3 > 5'd15)) matrix_14_d3 <= 8'd0; 
    else matrix_14_d3 <= matrix_14_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_15_d3 <= 8'd0; 
    else if((sequence_sorted_4 < 5'd8) || (sequence_sorted_4 > 5'd15)) matrix_15_d3 <= 8'd0; 
    else matrix_15_d3 <= matrix_15_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_21_d3 <= 8'd0; 
    else if((sequence_sorted_5 < 5'd8) || (sequence_sorted_5 > 5'd15)) matrix_21_d3 <= 8'd0; 
    else matrix_21_d3 <= matrix_21_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_22_d3 <= 8'd0; 
    else if((sequence_sorted_6 < 5'd8) || (sequence_sorted_6 > 5'd15)) matrix_22_d3 <= 8'd0; 
    else matrix_22_d3 <= matrix_22_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_23_d3 <= 8'd0; 
    else if((sequence_sorted_7 < 5'd8) || (sequence_sorted_7 > 5'd15)) matrix_23_d3 <= 8'd0; 
    else matrix_23_d3 <= matrix_23_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_24_d3 <= 8'd0; 
    else if((sequence_sorted_8 < 5'd8) || (sequence_sorted_8 > 5'd15)) matrix_24_d3 <= 8'd0; 
    else matrix_24_d3 <= matrix_24_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_25_d3 <= 8'd0; 
    else if((sequence_sorted_9 < 5'd8) || (sequence_sorted_9 > 5'd15)) matrix_25_d3 <= 8'd0; 
    else matrix_25_d3 <= matrix_25_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_31_d3 <= 8'd0; 
    else if((sequence_sorted_10 < 5'd8) || (sequence_sorted_10 > 5'd15)) matrix_31_d3 <= 8'd0; 
    else matrix_31_d3 <= matrix_31_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_32_d3 <= 8'd0; 
    else if((sequence_sorted_11 < 5'd8) || (sequence_sorted_11 > 5'd15)) matrix_32_d3 <= 8'd0; 
    else matrix_32_d3 <= matrix_32_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_33_d3 <= 8'd0; 
    else if((sequence_sorted_12 < 5'd8) || (sequence_sorted_12 > 5'd15)) matrix_33_d3 <= 8'd0; 
    else matrix_33_d3 <= matrix_33_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_34_d3 <= 8'd0; 
    else if((sequence_sorted_13 < 5'd8) || (sequence_sorted_13 > 5'd15)) matrix_34_d3 <= 8'd0; 
    else matrix_34_d3 <= matrix_34_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_35_d3 <= 8'd0; 
    else if((sequence_sorted_14 < 5'd8) || (sequence_sorted_14 > 5'd15)) matrix_35_d3 <= 8'd0; 
    else matrix_35_d3 <= matrix_35_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_41_d3 <= 8'd0; 
    else if((sequence_sorted_15 < 5'd8) || (sequence_sorted_15 > 5'd15)) matrix_41_d3 <= 8'd0; 
    else matrix_41_d3 <= matrix_41_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_42_d3 <= 8'd0; 
    else if((sequence_sorted_16 < 5'd8) || (sequence_sorted_16 > 5'd15)) matrix_42_d3 <= 8'd0; 
    else matrix_42_d3 <= matrix_42_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_43_d3 <= 8'd0; 
    else if((sequence_sorted_17 < 5'd8) || (sequence_sorted_17 > 5'd15)) matrix_43_d3 <= 8'd0; 
    else matrix_43_d3 <= matrix_43_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_44_d3 <= 8'd0; 
    else if((sequence_sorted_18 < 5'd8) || (sequence_sorted_18 > 5'd15)) matrix_44_d3 <= 8'd0; 
    else matrix_44_d3 <= matrix_44_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_45_d3 <= 8'd0; 
    else if((sequence_sorted_19 < 5'd8) || (sequence_sorted_19 > 5'd15)) matrix_45_d3 <= 8'd0; 
    else matrix_45_d3 <= matrix_45_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_51_d3 <= 8'd0; 
    else if((sequence_sorted_20 < 5'd8) || (sequence_sorted_20 > 5'd15)) matrix_51_d3 <= 8'd0; 
    else matrix_51_d3 <= matrix_51_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_52_d3 <= 8'd0; 
    else if((sequence_sorted_21 < 5'd8) || (sequence_sorted_21 > 5'd15)) matrix_52_d3 <= 8'd0; 
    else matrix_52_d3 <= matrix_52_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_53_d3 <= 8'd0; 
    else if((sequence_sorted_22 < 5'd8) || (sequence_sorted_22 > 5'd15)) matrix_53_d3 <= 8'd0; 
    else matrix_53_d3 <= matrix_53_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_54_d3 <= 8'd0; 
    else if((sequence_sorted_23 < 5'd8) || (sequence_sorted_23 > 5'd15)) matrix_54_d3 <= 8'd0; 
    else matrix_54_d3 <= matrix_54_d2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_55_d3 <= 8'd0; 
    else if((sequence_sorted_24 < 5'd8) || (sequence_sorted_24 > 5'd15)) matrix_55_d3 <= 8'd0; 
    else matrix_55_d3 <= matrix_55_d2;
end

// clk5 中间9个数取均值
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mean_data <= 8'd0; 
    end
    else begin  
        mean_data <= (matrix_11_d3 + matrix_12_d3 + matrix_13_d3 + matrix_14_d3 + matrix_15_d3 +
                      matrix_21_d3 + matrix_22_d3 + matrix_23_d3 + matrix_24_d3 + matrix_25_d3 +
                      matrix_31_d3 + matrix_32_d3 + matrix_33_d3 + matrix_34_d3 + matrix_35_d3 +
                      matrix_41_d3 + matrix_42_d3 + matrix_43_d3 + matrix_44_d3 + matrix_45_d3 +
                      matrix_51_d3 + matrix_52_d3 + matrix_53_d3 + matrix_54_d3 + matrix_55_d3  )/9;
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

assign mean_de    = Y_de_d[DLY_CYCLE-1];
assign mean_hsync = Y_hsync_d[DLY_CYCLE-1];
assign mean_vsync = Y_vsync_d[DLY_CYCLE-1];
    
endmodule