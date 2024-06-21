module fix_segment #
(
    parameter THRESHOLD         = 8'd100        ,   //阈值
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

parameter DLY_CYCLE = 1 ;

reg     [DLY_CYCLE-1:0]      Y_de_d                  ;
reg     [DLY_CYCLE-1:0]      Y_hsync_d               ;
reg     [DLY_CYCLE-1:0]      Y_vsync_d               ;

// clk7
// 阈值分割
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        segment_data <= 8'h00;
    end
    else if(Y_de == 1'b1) begin  
        segment_data <= (Y_data > THRESHOLD) ? 8'hff : 8'h00;
    end
end

// 信号同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Y_de_d    <= {(DLY_CYCLE){1'b0}};
        Y_hsync_d <= {(DLY_CYCLE){1'b0}};
        Y_vsync_d <= {(DLY_CYCLE){1'b0}};
    end
//    else begin  
//        Y_de_d    <= {Y_de_d   [(DLY_CYCLE-2):0],    Y_de};
//        Y_hsync_d <= {Y_hsync_d[(DLY_CYCLE-2):0], Y_hsync};
//        Y_vsync_d <= {Y_vsync_d[(DLY_CYCLE-2):0], Y_vsync};
//    end
    else begin  
        Y_de_d    <=    Y_de;
        Y_hsync_d <= Y_hsync;
        Y_vsync_d <= Y_vsync;
    end
end

assign segment_de    = Y_de_d   [DLY_CYCLE-1];
assign segment_hsync = Y_hsync_d[DLY_CYCLE-1];
assign segment_vsync = Y_vsync_d[DLY_CYCLE-1];
    
endmodule