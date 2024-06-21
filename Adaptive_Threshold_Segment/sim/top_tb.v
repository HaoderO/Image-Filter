`timescale 1ns/1ns          //时间精度
`define    clock_period 20  //时钟周期

module top_tb;
parameter           H_DISP = 1440     ;   //图像宽度
parameter           V_DISP = 1080     ;   //图像高度

reg                 clk               ;
reg                 rst_n             ;

wire                VGA_hsync         ;   //VGA行同步
wire                VGA_vsync         ;   //VGA场同步
wire    [7:0]       VGA_data          ;   //VGA数据
wire                VGA_de            ;   //VGA数据使能

wire                VGA1_hsync        ;   //VGA行同步
wire                VGA1_vsync        ;   //VGA场同步
wire    [7:0]       VGA1_data         ;   //VGA数据
wire                VGA1_de           ;   //VGA数据使能

top # 
(
    .H_DISP         (H_DISP         ),
    .V_DISP         (V_DISP         )
)
u_top 
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),

    .fixseg_hsync   (VGA_hsync      ),
    .fixseg_vsync   (VGA_vsync      ),
    .fixseg_data    (VGA_data       ),
    .fixseg_de      (VGA_de         ),

    .adpseg_hsync   (VGA1_hsync     ),
    .adpseg_vsync   (VGA1_vsync     ),
    .adpseg_data    (VGA1_data      ),
    .adpseg_de      (VGA1_de        )
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

//  新建txt文件用以存储modelsim仿真数据
integer processed_img_txt;
integer processed1_img_txt;

initial begin
//    processed_img_txt  = $fopen("D:/User/Desktop/Segment_Vivado_cosim/matlab/fix_seg.txt");
//    processed1_img_txt = $fopen("C:/Users/28049/Desktop/FPGA_sample/Simulation_integrated/erzhihua02_img/erzhi01.txt");   //�޸ĵ�
    processed_img_txt  = $fopen("D:/User/Desktop/Global_segment/adap_segment/matlab/fix_seg.txt");
    processed1_img_txt = $fopen("D:/User/Desktop/Global_segment/adap_segment/matlab/adp_seg.txt");
end

//  将仿真数据写入txt
reg [21:0] pixel_cnt;
reg [21:0] pixel_cnt1;

always @(posedge clk) begin
    if(!rst_n) begin
        pixel_cnt <= 0;
    end
    else if(VGA_de) begin
            pixel_cnt = pixel_cnt + 1;
        $fdisplay(processed_img_txt,"%d",VGA_data);
        
        if(pixel_cnt == H_DISP*V_DISP)
            $fclose(processed_img_txt);
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        pixel_cnt1 <= 0;
    end
//    else if(VGA1_de && VGA_vld) begin
    else if(VGA1_de) begin
            pixel_cnt1 = pixel_cnt1 + 1;
        $fdisplay(processed1_img_txt,"%d",VGA1_data);
        
        if(pixel_cnt1 == H_DISP*V_DISP) begin
            $fclose(processed1_img_txt);
            $stop;            
        end
    end
end

endmodule