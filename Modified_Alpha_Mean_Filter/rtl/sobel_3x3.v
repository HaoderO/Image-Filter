module sobel_3x3 #
(
    parameter H_DISP            = 12'd640       ,   //图像宽度
    parameter V_DISP            = 12'd480           //图像高度
)
(
    input   wire                clk             ,
    input   wire                rst_n           ,
    input   wire                Y_de            ,   //Y分量行同步
    input   wire                Y_hsync         ,   //Y分量场同步
    input   wire                Y_vsync         ,   //Y分量数据
    input   wire    [ 7:0]      Y_data          ,   //Y分量数据使能
//    input   wire    [ 7:0]      value           ,   //sobel阈值

    output  wire                sobel_de        ,   //输出数据行同步
    output  wire                sobel_hsync     ,   //输出数据场同步
    output  wire                sobel_vsync     ,   //输出数据
    output  wire    [ 7:0]      sobel_data          //输出数据使能
);

parameter DLY_CYCLE = 6;

wire    [ 7:0]      matrix_11,matrix_12,matrix_13               ;
wire    [ 7:0]      matrix_21,matrix_22,matrix_23               ;
wire    [ 7:0]      matrix_31,matrix_32,matrix_33               ;

//reg     [ 9:0]      Gx1,Gx3,Gy1,Gy3,Gx,Gy   ;
reg     [ 9:0]      G_0_a  , G_0_b  , G_180_a , G_180_b ,
                    G_45_a , G_45_b , G_225_a , G_225_b ,
                    G_90_a , G_90_b , G_270_a, G_270_b,
                    G_135_a, G_135_b, G_315_a, G_315_b;
reg     [10:0]      G_0  , G_180  , G_45  , G_225 ,
                    G_90 , G_270 , G_135 , G_315;

reg     [ 7:0]      sobel_data_d;

reg     [10:0]      max_0_45,max_90_135,max_180_225,max_270_315,
                    max_0_45_90_135,max_180_225_270_315;

reg     [10:0]      G,Med,Med_d1,Med_d2,Med_d3,Med_d4,Med_d5,Med_d6;

reg     [DLY_CYCLE-1:0]      Y_de_r                  ;
reg     [DLY_CYCLE-1:0]      Y_hsync_r               ;
reg     [DLY_CYCLE-1:0]      Y_vsync_r               ;

//************************************************************//
// clk1
matrix_3x3_8bit #
(
    .H_DISP                 (H_DISP             ),
    .V_DISP                 (V_DISP             )
)
u_matrix_3x3_8bit
(
    .clk                    (clk                ),
    .rst_n                  (rst_n              ),
    .din_vld                (Y_de               ),
    .din                    (Y_data             ),

    .matrix_11(matrix_11),.matrix_12(matrix_12),.matrix_13(matrix_13),
    .matrix_21(matrix_21),.matrix_22(matrix_22),.matrix_23(matrix_23),
    .matrix_31(matrix_31),.matrix_32(matrix_32),.matrix_33(matrix_33)
);
//************************************************************//

//************************************************************//
// clk2
// 自适应阈值Med
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        Med <= 11'd0;
    else 
        Med <= (matrix_11 + matrix_12 + matrix_13 + 
                matrix_21             + matrix_23 + 
                matrix_31 + matrix_32 + matrix_33 ) >> 3;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Med_d1 <= 11'd0;
        Med_d2 <= 11'd0;
        Med_d3 <= 11'd0;
        Med_d4 <= 11'd0;
        Med_d5 <= 11'd0;
        Med_d6 <= 11'd0;
    end
    else begin
        Med_d1 <= Med;
        Med_d2 <= Med_d1;
        Med_d3 <= Med_d2;
        Med_d4 <= Med_d3;
        Med_d5 <= Med_d4;
        Med_d6 <= Med_d5;
    end
end
// clk2
// 0
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_0_a <= 10'd0;
        G_0_b <= 10'd0;
    end
    else begin
        G_0_a <= matrix_11 + (matrix_12 << 1) + matrix_13;
        G_0_b <= matrix_31 + (matrix_32 << 1) + matrix_33;
    end
end
// 45
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_45_a <= 10'd0;
        G_45_b <= 10'd0;
    end
    else begin
        G_45_a <= matrix_11 + (matrix_12 << 1) + matrix_21;
        G_45_b <= matrix_23 + (matrix_33 << 1) + matrix_32;
    end
end
// 90
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_90_a <= 10'd0;
        G_90_b <= 10'd0;
    end
    else begin
        G_90_a <= matrix_11 + (matrix_21 << 1) + matrix_21;
        G_90_b <= matrix_13 + (matrix_23 << 1) + matrix_33;
    end
end
// 135
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_135_a <= 10'd0;
        G_135_b <= 10'd0;
    end
    else begin
        G_135_a <= matrix_21 + (matrix_31 << 2) + matrix_32;
        G_135_b <= matrix_12 + (matrix_13 << 2) + matrix_23;
    end
end
// 180
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_180_a <= 10'd0;
        G_180_b <= 10'd0;
    end
    else begin
        G_180_a <= matrix_31 + (matrix_32 << 2) + matrix_33;
        G_180_b <= matrix_11 + (matrix_12 << 2) + matrix_13;
    end
end
// 225
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_225_a <= 10'd0;
        G_225_b <= 10'd0;
    end
    else begin
        G_225_a <= matrix_32 + (matrix_33 << 1) + matrix_23;
        G_225_b <= matrix_11 + (matrix_12 << 2) + matrix_21;
    end
end
// 270
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_270_a <= 10'd0;
        G_270_b <= 10'd0;
    end
    else begin
        G_270_a <= matrix_13 + (matrix_23 << 2) + matrix_33;
        G_270_b <= matrix_11 + (matrix_21 << 2) + matrix_31;
    end
end
// 315
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_315_a <= 10'd0;
        G_315_b <= 10'd0;
    end
    else begin
        G_315_a <= matrix_12 + (matrix_13 << 2) + matrix_23;
        G_315_b <= matrix_21 + (matrix_31 << 2) + matrix_32;
    end
end
//************************************************************//

//************************************************************//
// clk3
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_0   <= 11'd0;
        G_45  <= 11'd0;
        G_90  <= 11'd0;
        G_135 <= 11'd0;
        G_180 <= 11'd0;
        G_225 <= 11'd0;
        G_270 <= 11'd0;
        G_315 <= 11'd0;
    end
    else begin
        G_0   <= (G_0_a   > G_0_b  ) ? (G_0_a   - G_0_b  ) : (G_0_b   - G_0_a  );
        G_45  <= (G_45_a  > G_45_b ) ? (G_45_a  - G_45_b ) : (G_45_b  - G_45_a );
        G_90  <= (G_90_a  > G_90_b ) ? (G_90_a  - G_90_b ) : (G_90_b  - G_90_a );
        G_135 <= (G_135_a > G_135_b) ? (G_135_a - G_135_b) : (G_135_b - G_135_a);
        G_180 <= (G_180_a > G_180_b) ? (G_180_a - G_180_b) : (G_180_b - G_180_a);
        G_225 <= (G_225_a > G_225_b) ? (G_225_a - G_225_b) : (G_225_b - G_225_a);
        G_270 <= (G_270_a > G_270_b) ? (G_270_a - G_270_b) : (G_270_b - G_270_a);
        G_315 <= (G_315_a > G_315_b) ? (G_315_a - G_315_b) : (G_315_b - G_315_a);
    end
end
//************************************************************//

//************************************************************//
// clk4 M∞
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_0_45 <= 11'd0;
    else if(G_0 > G_45)
        max_0_45 <= G_0;
    else
        max_0_45 <= G_45;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_90_135 <= 11'd0;
    else if(G_90 > G_135)
        max_90_135 <= G_90;
    else
        max_90_135 <= G_135;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_180_225 <= 11'd0;
    else if(G_180 > G_225)
        max_180_225 <= G_180;
    else
        max_180_225 <= G_225;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_270_315 <= 11'd0;
    else if(G_270 > G_315)
        max_270_315 <= G_270;
    else
        max_270_315 <= G_315;
end
// clk5 M∞
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_0_45_90_135 <= 11'd0;
    else if(max_0_45 > max_90_135)
        max_0_45_90_135 <= max_0_45;
    else
        max_0_45_90_135 <= max_90_135;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_180_225_270_315 <= 11'd0;
    else if(max_180_225 > max_270_315)
        max_180_225_270_315 <= max_180_225;
    else
        max_180_225_270_315 <= max_270_315;
end
// clk6 M∞
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        G <= 11'd0;
    else if(max_0_45_90_135 > max_180_225_270_315)
        G <= max_0_45_90_135;
    else
        G <= max_180_225_270_315;
end
// clk7
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) 
//        sobel_data <= 8'h00;
//    else if(G >= Med_d5)
//        sobel_data <= 8'hff;
//    else if(G <= (Med_d5/2))
//        sobel_data <= 8'h00;    
//    else if((Med_d5/2) < G <Med_d5) begin
//        if(sobel_data_d == 8'hff)
//            sobel_data <= 8'hff;
//        else
//            sobel_data <= 8'h00;            
//    end
//end

//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) 
//        sobel_data_d <= 8'h00;
//    else
//        sobel_data_d <= sobel_data;
//end

assign sobel_data = (G > 100) ? 8'hff : 8'h00;

//  信号同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Y_de_r    <= {DLY_CYCLE{1'b0}};
        Y_hsync_r <= {DLY_CYCLE{1'b0}};
        Y_vsync_r <= {DLY_CYCLE{1'b0}};
    end
    else begin  
        Y_de_r    <= {Y_de_r   [(DLY_CYCLE-2):0],    Y_de};
        Y_hsync_r <= {Y_hsync_r[(DLY_CYCLE-2):0], Y_hsync};
        Y_vsync_r <= {Y_vsync_r[(DLY_CYCLE-2):0], Y_vsync};
    end
end

assign sobel_de    = Y_de_r   [DLY_CYCLE-1];
assign sobel_hsync = Y_hsync_r[DLY_CYCLE-1];
assign sobel_vsync = Y_vsync_r[DLY_CYCLE-1];
    
endmodule