`timescale 1ns/1ns          //时间精度
`define    clock_period 20  //时钟周期

module top_tb;
parameter           H_DISP = 500        ;   //图像宽度
parameter           V_DISP = 500        ;   //图像高度
reg                 clk                 ;   
reg                 rst_n               ;   

wire                VGA_hsync           ;   //VGA行同步
wire                VGA_vsync           ;   //VGA场同步
wire    [23:0]      VGA_data            ;   //VGA数据
wire                VGA_de              ;   //VGA数据使能

top #
(
    .H_DISP         (H_DISP             ), 
    .V_DISP         (V_DISP             )  
)
u_top
(
    .clk            (clk                ),  
    .rst_n          (rst_n              ),  
    
    .VGA_hsync      (VGA_hsync          ),
    .VGA_vsync      (VGA_vsync          ),
    .VGA_data       (VGA_data           ),
    .VGA_de         (VGA_de             ) 
);

initial begin
    clk = 1;
    forever
        #(`clock_period/2) clk = ~clk;
end

initial begin
    rst_n = 0; #(`clock_period*20+1);
    rst_n = 1;
end

// 新建一个post_img.txt文件来存储仿真数据
integer processed_img_txt;

// 将仿真数据写入txt
initial begin
    processed_img_txt = $fopen("./../../matlab/processed_img.txt");
end

reg [20:0] pixel_cnt;

always @(posedge clk) begin
    if(!rst_n) begin
        pixel_cnt <= 0;
    end
    else if(VGA_de) begin
        pixel_cnt = pixel_cnt + 1;
        $fdisplay(processed_img_txt,"%h",VGA_data);
        
        if(pixel_cnt == H_DISP*V_DISP)
            $stop;
    end
end

endmodule