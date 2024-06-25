module sobel_5x5 #
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

parameter DLY_CYCLE = 6 ;

wire     [ 7:0]      matrix_11,matrix_12,matrix_13,matrix_14,matrix_15;
wire     [ 7:0]      matrix_21,matrix_22,matrix_23,matrix_24,matrix_25;
wire     [ 7:0]      matrix_31,matrix_32,matrix_33,matrix_34,matrix_35;
wire     [ 7:0]      matrix_41,matrix_42,matrix_43,matrix_44,matrix_45;
wire     [ 7:0]      matrix_51,matrix_52,matrix_53,matrix_54,matrix_55;

reg     [ 7:0]      sobel_data_d;
reg     [ 9:0]      G_0_a  , G_0_b  , G_22p5_a , G_22p5_b ,
                    G_45_a , G_45_b , G_67p5_a , G_67p5_b ,
                    G_90_a , G_90_b , G_112p5_a, G_112p5_b,
                    G_135_a, G_135_b, G_157p5_a, G_157p5_b;
reg     [10:0]      G_0  , G_22p5  , G_45  , G_67p5 ,
                    G_90 , G_112p5 , G_135 , G_157p5;

reg     [10:0]      max_0_22p5,max_45_67p5,max_90_112p5,max_135_157p5,
                    max_0_22p5_45_67p5,max_90_112p5_135_157p5;
reg     [10:0]      G,Med,Med_d1,Med_d2,Med_d3,Med_d4,Med_d5,Med_d6;

reg     [DLY_CYCLE-1:0]      Y_de_r                  ;
reg     [DLY_CYCLE-1:0]      Y_hsync_r               ;
reg     [DLY_CYCLE-1:0]      Y_vsync_r               ;

//************************************************************//
// clk1
matrix_5x5_8bit # 
(
    .H_DISP     (H_DISP         ),
    .V_DISP     (V_DISP         )
)
matrix_5x5_8bit_inst 
(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .din_vld    (Y_de           ),
    .din        (Y_data         ),

    .matrix_11(matrix_11),.matrix_12(matrix_12),.matrix_13(matrix_13),.matrix_14(matrix_14),.matrix_15(matrix_15),
    .matrix_21(matrix_21),.matrix_22(matrix_22),.matrix_23(matrix_23),.matrix_24(matrix_24),.matrix_25(matrix_25),
    .matrix_31(matrix_31),.matrix_32(matrix_32),.matrix_33(matrix_33),.matrix_34(matrix_34),.matrix_35(matrix_35),
    .matrix_41(matrix_41),.matrix_42(matrix_42),.matrix_43(matrix_43),.matrix_44(matrix_44),.matrix_45(matrix_45),
    .matrix_51(matrix_51),.matrix_52(matrix_52),.matrix_53(matrix_53),.matrix_54(matrix_54),.matrix_55(matrix_55)
);
//************************************************************//

//************************************************************//
// clk2
// 自适应阈值Med
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        Med <= 11'd0;
    else 
        Med <= (matrix_11 + matrix_12 + matrix_13 + matrix_14 + matrix_15 +
                matrix_21 + matrix_22 + matrix_23 + matrix_24 + matrix_25 +
                matrix_31 + matrix_32 + matrix_33 + matrix_34 + matrix_35 +
                matrix_41 + matrix_42 + matrix_43 + matrix_44 + matrix_45 +
                matrix_51 + matrix_52 + matrix_53 + matrix_54 + matrix_55) / 25;
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
        G_0_a <= matrix_21 + (matrix_22 << 1) + (matrix_23 << 2) + (matrix_24 << 1) + matrix_25;
        G_0_b <= matrix_41 + (matrix_42 << 1) + (matrix_43 << 2) + (matrix_44 << 1) + matrix_45;
    end
end
// 22.5
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_22p5_a <= 10'd0;
        G_22p5_b <= 10'd0;
    end
    else begin
        G_22p5_a <= (matrix_22 << 1) + (matrix_23 << 2) + (matrix_24 << 1) + matrix_31 + (matrix_32 << 2);
        G_22p5_b <= (matrix_42 << 1) + (matrix_43 << 2) + (matrix_44 << 1) + matrix_35 + (matrix_34 << 2);
    end
end
// 45
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_45_a <= 10'd0;
        G_45_b <= 10'd0;
    end
    else begin
        G_45_a <= matrix_14 + (matrix_22 << 1) + (matrix_23 << 2) + (matrix_32 << 2) + matrix_41;
        G_45_b <= matrix_25 + (matrix_34 << 1) + (matrix_43 << 2) + (matrix_44 << 1) + matrix_52;
    end
end
// 67.5
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_67p5_a <= 10'd0;
        G_67p5_b <= 10'd0;
    end
    else begin
        G_67p5_a <= matrix_13 + (matrix_22 << 1) + (matrix_23 << 2) + (matrix_32 << 2) + (matrix_42 << 1);
        G_67p5_b <= (matrix_24 << 1) + (matrix_34 << 2) + (matrix_43 << 2) + (matrix_44 << 1) + matrix_53;
    end
end
// 90
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_90_a <= 10'd0;
        G_90_b <= 10'd0;
    end
    else begin
        G_90_a <= matrix_12 + (matrix_22 << 1) + (matrix_32 << 2) + (matrix_42 << 1) + matrix_52;
        G_90_b <= matrix_14 + (matrix_24 << 1) + (matrix_34 << 2) + (matrix_44 << 1) + matrix_54;
    end
end
// 112.5
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_112p5_a <= 10'd0;
        G_112p5_b <= 10'd0;
    end
    else begin
        G_112p5_a <= (matrix_22 << 1) + (matrix_32 << 2) + (matrix_42 << 1) + (matrix_43 << 2) + matrix_53;
        G_112p5_b <= matrix_13 + (matrix_23 << 2) + (matrix_24 << 1) + (matrix_34 << 2) + (matrix_44 << 1);
    end
end
// 135
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_135_a <= 10'd0;
        G_135_b <= 10'd0;
    end
    else begin
        G_135_a <= matrix_21 + (matrix_32 << 2) + (matrix_42 << 1) + (matrix_43 << 2) + matrix_54;
        G_135_b <= matrix_12 + (matrix_23 << 2) + (matrix_24 << 1) + (matrix_34 << 2) + matrix_45;
    end
end
// 157.5
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_157p5_a <= 10'd0;
        G_157p5_b <= 10'd0;
    end
    else begin
        G_157p5_a <= matrix_31 + (matrix_32 << 2) + (matrix_42 << 1) + (matrix_43 << 2) + (matrix_44 << 1);
        G_157p5_b <= (matrix_22 << 1) + (matrix_23 << 2) + (matrix_24 << 1) + (matrix_34 << 2) + matrix_35;
    end
end
//************************************************************//

//************************************************************//
// clk3
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        G_0     <= 11'd0;
        G_22p5  <= 11'd0;
        G_45    <= 11'd0;
        G_67p5  <= 11'd0;
        G_90    <= 11'd0;
        G_112p5 <= 11'd0;
        G_135   <= 11'd0;
        G_157p5 <= 11'd0;
    end
    else begin
        G_0     <= (G_0_a     > G_0_b    ) ? (G_0_a     - G_0_b    ) : (G_0_b     - G_0_a    );
        G_22p5  <= (G_22p5_a  > G_22p5_b ) ? (G_22p5_a  - G_22p5_b ) : (G_22p5_b  - G_22p5_a );
        G_45    <= (G_45_a    > G_45_b   ) ? (G_45_a    - G_45_b   ) : (G_45_b    - G_45_a   );
        G_67p5  <= (G_67p5_a  > G_67p5_b ) ? (G_67p5_a  - G_67p5_b ) : (G_67p5_b  - G_67p5_a );
        G_90    <= (G_90_a    > G_90_b   ) ? (G_90_a    - G_90_b   ) : (G_90_b    - G_90_a   );
        G_112p5 <= (G_112p5_a > G_112p5_b) ? (G_112p5_a - G_112p5_b) : (G_112p5_b - G_112p5_a);
        G_135   <= (G_135_a   > G_135_b  ) ? (G_135_a   - G_135_b  ) : (G_135_b   - G_135_a  );
        G_157p5 <= (G_157p5_a > G_157p5_b) ? (G_157p5_a - G_157p5_b) : (G_157p5_b - G_157p5_a);
    end
end
//************************************************************//

//************************************************************//
// clk4 M∞
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_0_22p5 <= 11'd0;
    else if(G_0 > G_22p5)
        max_0_22p5 <= G_0;
    else
        max_0_22p5 <= G_22p5;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_45_67p5 <= 11'd0;
    else if(G_45 > G_67p5)
        max_45_67p5 <= G_45;
    else
        max_45_67p5 <= G_67p5;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_90_112p5 <= 11'd0;
    else if(G_90 > G_112p5)
        max_90_112p5 <= G_90;
    else
        max_90_112p5 <= G_112p5;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_135_157p5 <= 11'd0;
    else if(G_135 > G_157p5)
        max_135_157p5 <= G_135;
    else
        max_135_157p5 <= G_157p5;
end
// clk5 M∞
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_0_22p5_45_67p5 <= 11'd0;
    else if(max_0_22p5 > max_45_67p5)
        max_0_22p5_45_67p5 <= max_0_22p5;
    else
        max_0_22p5_45_67p5 <= max_45_67p5;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        max_90_112p5_135_157p5 <= 11'd0;
    else if(max_90_112p5 > max_135_157p5)
        max_90_112p5_135_157p5 <= max_90_112p5;
    else
        max_90_112p5_135_157p5 <= max_135_157p5;
end
// clk6 M∞
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        G <= 11'd0;
    else if(max_0_22p5_45_67p5 > max_90_112p5_135_157p5)
        G <= max_0_22p5_45_67p5;
    else
        G <= max_90_112p5_135_157p5;
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
//
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) 
//        sobel_data_d <= 8'h00;
//    else
//        sobel_data_d <= sobel_data;
//end

assign sobel_data = (G >= 'd100) ? 8'hff : 8'h00;

//  信号同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Y_de_r    <= {(DLY_CYCLE){1'b0}};
        Y_hsync_r <= {(DLY_CYCLE){1'b0}};
        Y_vsync_r <= {(DLY_CYCLE){1'b0}};
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