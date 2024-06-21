`timescale 1 ns/1 ns

module img_gen
#(
    parameter H_SYNC        = 96                    ,   //行同步信�?
    parameter H_BACK        = 48                    ,   //行显示后�?
    parameter H_DISP        = 640                   ,   //行有效数�?
    parameter H_FRONT       = 16                    ,   //行显示前�?
//    parameter H_TOTAL       = 800                   ,   //行扫描周�?
    parameter H_TOTAL       = H_SYNC + H_BACK + H_DISP + H_FRONT,   //行扫描周�?

    parameter V_SYNC        = 2                     ,   //场同步信�?
    parameter V_BACK        = 33                    ,   //场显示后�?
    parameter V_DISP        = 480                   ,   //场有效数�?   
    parameter V_FRONT       = 10                    ,   //场显示前�?
//    parameter V_TOTAL       = 525                       //场扫描周�?
    parameter V_TOTAL       = V_SYNC + V_BACK + V_DISP + V_FRONT    //场扫描周�?
)
(
    input   wire            clk                     ,   //时钟
    input   wire            rst_n                   ,   //复位，低电平有效

    output  wire            img_hsync               ,   //img行同�?
    output  wire            img_vsync               ,   //img场同�?
    output  reg     [7:0]   img_data                ,   //img数据
    output  reg             img_de                      //img数据使能
);

    reg     [15:0]          cnt_h                   ;
    wire                    add_cnt_h               ;
    wire                    end_cnt_h               ;
    reg     [15:0]          cnt_v                   ;
    wire                    add_cnt_v               ;
    wire                    end_cnt_v               ;

    reg     [ 7:0]          ram [H_DISP*V_DISP-1:0] ;
    reg     [31:0]          i                       ;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_h <= 0;
    else if(add_cnt_h) begin
        if(end_cnt_h)
            cnt_h <= 0;
        else
            cnt_h <= cnt_h + 1;
    end
end

assign add_cnt_h = 1;
assign end_cnt_h = add_cnt_h && cnt_h==H_TOTAL-1;

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n)
        cnt_v <= 0;
    else if(add_cnt_v) begin
        if(end_cnt_v)
            cnt_v <= 0;
        else
            cnt_v <= cnt_v + 1;
    end
end

assign add_cnt_v = end_cnt_h;
assign end_cnt_v = add_cnt_v && cnt_v==V_TOTAL-1;

assign img_hsync = (cnt_h < H_SYNC) ? 1'b0 : 1'b1;
assign img_vsync = (cnt_v < V_SYNC) ? 1'b0 : 1'b1;

assign img_req = (cnt_h >= H_SYNC + H_BACK - 1) && (cnt_h < H_SYNC + H_BACK + H_DISP - 1) &&
             (cnt_v >= V_SYNC + V_BACK    ) && (cnt_v < V_SYNC + V_BACK + V_DISP    );

//  读取txt中数据到ram,16进制
initial begin
//    $readmemh("C:/Users/28049/Desktop/FPGA_sample/Simulation_integrated/mid_img/mid01.txt", ram);
    $readmemh("D:/User/Desktop/Global_segment/adap_segment/matlab/pre.txt",ram);
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin 
        img_data <= 8'd0;
        i <= 0;
    end
    else if(img_req) begin
        img_data <= ram[i];
        i <= i + 1;
    end
    else if(i==H_DISP*V_DISP) begin
        img_data <= 8'd0;
        i <= 0;
    end
end

always @(posedge clk) begin 
    img_de <= img_req;
end

endmodule