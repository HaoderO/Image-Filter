module matrix_5x5_8bit
#(
    parameter H_DISP            = 12'd640       ,   //图像宽度
    parameter V_DISP            = 12'd480           //图像高度
)
(
    input   wire                clk             ,
    input   wire                rst_n           ,
    input   wire                din_vld         ,
    input   wire    [ 7:0]      din             ,

    output  reg                 out_vld         ,
    output  reg     [ 7:0]      matrix_11       ,
    output  reg     [ 7:0]      matrix_12       ,
    output  reg     [ 7:0]      matrix_13       ,
    output  reg     [ 7:0]      matrix_14       ,
    output  reg     [ 7:0]      matrix_15       ,
    output  reg     [ 7:0]      matrix_21       ,
    output  reg     [ 7:0]      matrix_22       ,
    output  reg     [ 7:0]      matrix_23       ,
    output  reg     [ 7:0]      matrix_24       ,
    output  reg     [ 7:0]      matrix_25       ,
    output  reg     [ 7:0]      matrix_31       ,
    output  reg     [ 7:0]      matrix_32       ,
    output  reg     [ 7:0]      matrix_33       ,
    output  reg     [ 7:0]      matrix_34       ,
    output  reg     [ 7:0]      matrix_35       ,
    output  reg     [ 7:0]      matrix_41       ,
    output  reg     [ 7:0]      matrix_42       ,
    output  reg     [ 7:0]      matrix_43       ,
    output  reg     [ 7:0]      matrix_44       ,
    output  reg     [ 7:0]      matrix_45       ,
    output  reg     [ 7:0]      matrix_51       ,
    output  reg     [ 7:0]      matrix_52       ,
    output  reg     [ 7:0]      matrix_53       ,
    output  reg     [ 7:0]      matrix_54       ,
    output  reg     [ 7:0]      matrix_55       
);

    reg     [11:0]              cnt_col         ;
    wire                        add_cnt_col     ;
    wire                        end_cnt_col     ;
    reg     [11:0]              cnt_row         ;
    wire                        add_cnt_row     ;
    wire                        end_cnt_row     ;
    wire                        wr_en_1         ;
    wire                        wr_en_2         ;
    wire                        wr_en_3         ;
    wire                        wr_en_4         ;
    wire                        rd_en_1         ;
    wire                        rd_en_2         ;
    wire                        rd_en_3         ;
    wire                        rd_en_4         ;
    wire    [ 7:0]              q_1             ;
    wire    [ 7:0]              q_2             ;
    wire    [ 7:0]              q_3             ;
    wire    [ 7:0]              q_4             ;
    wire    [ 7:0]              row_1           ;
    wire    [ 7:0]              row_2           ;
    wire    [ 7:0]              row_3           ;
    wire    [ 7:0]              row_4           ;
    wire    [ 7:0]              row_5           ;

fifo_show_2048x8 u1
(
    .clock                  (clk                ),
    .data                   (din                ),
    .wrreq                  (wr_en_1            ),
    .rdreq                  (rd_en_1            ),
    .q                      (q_1                )
);

fifo_show_2048x8 u2
(
    .clock                  (clk                ),
    .data                   (din                ),
    .wrreq                  (wr_en_2            ),
    .rdreq                  (rd_en_2            ),
    .q                      (q_2                )
);

fifo_show_2048x8 u3
(
    .clock                  (clk                ),
    .data                   (din                ),
    .wrreq                  (wr_en_3            ),
    .rdreq                  (rd_en_3            ),
    .q                      (q_3                )
);

fifo_show_2048x8 u4
(
    .clock                  (clk                ),
    .data                   (din                ),
    .wrreq                  (wr_en_4            ),
    .rdreq                  (rd_en_4            ),
    .q                      (q_4                )
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_col <= 12'd0;
    else if(add_cnt_col) begin
        if(end_cnt_col)
            cnt_col <= 12'd0;
        else
            cnt_col <= cnt_col + 12'd1;
    end
end

assign add_cnt_col = din_vld;
assign end_cnt_col = add_cnt_col && cnt_col== H_DISP-12'd1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_row <= 12'd0;
    else if(add_cnt_row) begin
        if(end_cnt_row)
            cnt_row <= 12'd0;
        else
            cnt_row <= cnt_row + 12'd1;
    end
end

assign add_cnt_row = end_cnt_col;
assign end_cnt_row = add_cnt_row && cnt_row== V_DISP-12'd1;

//  fifo 读写
assign wr_en_1 = (cnt_row < V_DISP - 12'd1) ? din_vld : 1'd0; //不写最后1行
assign rd_en_1 = (cnt_row > 12'd0         ) ? din_vld : 1'd0; //从第1行开始读
assign wr_en_2 = (cnt_row < V_DISP - 12'd2) ? din_vld : 1'd0; //不写最后2行
assign rd_en_2 = (cnt_row > 12'd1         ) ? din_vld : 1'd0; //从第2行开始读
assign wr_en_3 = (cnt_row < V_DISP - 12'd3) ? din_vld : 1'd0; //不写最后3行
assign rd_en_3 = (cnt_row > 12'd2         ) ? din_vld : 1'd0; //从第3行开始读
assign wr_en_4 = (cnt_row < V_DISP - 12'd4) ? din_vld : 1'd0; //不写最后4行
assign rd_en_4 = (cnt_row > 12'd3         ) ? din_vld : 1'd0; //从第4行开始读
//  形成 5x5 矩阵，边界采用像素复制
assign row_1 = q_4;
assign row_2 = q_3;
assign row_3 = q_2;
assign row_4 = q_1;
assign row_5 = din;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
        {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
        {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
        {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
        {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
    end
    else if(cnt_row == 12'd0) begin
        if(cnt_col == 12'd0) begin          //第1个矩阵
            {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {row_5, row_5, row_5, row_5, row_5};
            {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {row_5, row_5, row_5, row_5, row_5};
            {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {row_5, row_5, row_5, row_5, row_5};
            {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {row_5, row_5, row_5, row_5, row_5};
            {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {row_5, row_5, row_5, row_5, row_5};
        end
        else begin                          //剩余矩阵
            {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {matrix_12, matrix_13, matrix_14, matrix_15, row_5};
            {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {matrix_22, matrix_23, matrix_24, matrix_25, row_5};
            {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {matrix_32, matrix_33, matrix_34, matrix_35, row_5};
            {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {matrix_42, matrix_43, matrix_44, matrix_45, row_5};
            {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {matrix_52, matrix_53, matrix_54, matrix_55, row_5};
        end
    end
    else if(cnt_row == 12'd1) begin
        if(cnt_col == 12'd0) begin          //第1个矩阵
            {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {row_4, row_4, row_4, row_4, row_4};
            {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {row_4, row_4, row_4, row_4, row_4};
            {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {row_4, row_4, row_4, row_4, row_4};
            {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {row_4, row_4, row_4, row_4, row_4};
            {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {row_5, row_5, row_5, row_5, row_5};
        end
        else begin                          //剩余矩阵
            {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {matrix_12, matrix_13, matrix_14, matrix_15, row_4};
            {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {matrix_22, matrix_23, matrix_24, matrix_25, row_4};
            {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {matrix_32, matrix_33, matrix_34, matrix_35, row_4};
            {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {matrix_42, matrix_43, matrix_44, matrix_45, row_4};
            {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {matrix_52, matrix_53, matrix_54, matrix_55, row_5};
        end
    end
    else if(cnt_row == 12'd2) begin
        if(cnt_col == 12'd0) begin          //第1个矩阵
            {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {row_3, row_3, row_3, row_3, row_3};
            {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {row_3, row_3, row_3, row_3, row_3};
            {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {row_3, row_3, row_3, row_3, row_3};
            {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {row_4, row_4, row_4, row_4, row_4};
            {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {row_5, row_5, row_5, row_5, row_5};
        end
        else begin                          //剩余矩阵
            {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {matrix_12, matrix_13, matrix_14, matrix_15, row_3};
            {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {matrix_22, matrix_23, matrix_24, matrix_25, row_3};
            {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {matrix_32, matrix_33, matrix_34, matrix_35, row_3};
            {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {matrix_42, matrix_43, matrix_44, matrix_45, row_4};
            {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {matrix_52, matrix_53, matrix_54, matrix_55, row_5};
        end
    end
    else if(cnt_row == 12'd3) begin
        if(cnt_col == 12'd0) begin          //第1个矩阵
            {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {row_2, row_2, row_2, row_2, row_2};
            {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {row_2, row_2, row_2, row_2, row_2};
            {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {row_3, row_3, row_3, row_3, row_3};
            {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {row_4, row_4, row_4, row_4, row_4};
            {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {row_5, row_5, row_5, row_5, row_5};
        end
        else begin                          //剩余矩阵
            {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {matrix_12, matrix_13, matrix_14, matrix_15, row_2};
            {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {matrix_22, matrix_23, matrix_24, matrix_25, row_2};
            {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {matrix_32, matrix_33, matrix_34, matrix_35, row_3};
            {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {matrix_42, matrix_43, matrix_44, matrix_45, row_4};
            {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {matrix_52, matrix_53, matrix_54, matrix_55, row_5};
        end
    end
    else begin
        if(cnt_col == 12'd0) begin          //第1个矩阵
            {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {row_1, row_1, row_1, row_1, row_1};
            {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {row_2, row_2, row_2, row_2, row_2};
            {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {row_3, row_3, row_3, row_3, row_3};
            {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {row_4, row_4, row_4, row_4, row_4};
            {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {row_5, row_5, row_5, row_5, row_5};
        end
        else begin                          //剩余矩阵
            {matrix_11, matrix_12, matrix_13, matrix_14, matrix_15} <= {matrix_12, matrix_13, matrix_14, matrix_15, row_1};
            {matrix_21, matrix_22, matrix_23, matrix_24, matrix_25} <= {matrix_22, matrix_23, matrix_24, matrix_25, row_2};
            {matrix_31, matrix_32, matrix_33, matrix_34, matrix_35} <= {matrix_32, matrix_33, matrix_34, matrix_35, row_3};
            {matrix_41, matrix_42, matrix_43, matrix_44, matrix_45} <= {matrix_42, matrix_43, matrix_44, matrix_45, row_4};
            {matrix_51, matrix_52, matrix_53, matrix_54, matrix_55} <= {matrix_52, matrix_53, matrix_54, matrix_55, row_5};
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_vld <= 1'd0;
    else
        out_vld <= din_vld;
end


endmodule