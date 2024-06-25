`timescale 1 ns/1 ns

module top #
(
    parameter               H_DISP = 640        ,   //图像宽度
    parameter               V_DISP = 480            //图像高度
)
(
    input   wire            clk                 ,
    input   wire            rst_n               ,

    output  wire            VGA_hsync           ,   //VGA行同步
    output  wire            VGA_vsync           ,   //VGA场同步
    output  wire    [23:0]  VGA_data            ,   //VGA数据
    output  wire            VGA_de                  //VGA数据使能
);

    wire                    RGB_hsync           ;   //RGB行同步
    wire                    RGB_vsync           ;   //RGB场同步
    wire    [23:0]          RGB_data            ;   //RGB数据
    wire                    RGB_de              ;   //RGB数据使能

    wire                    Y_hsync             ;   //灰度数据行同步
    wire                    Y_vsync             ;   //灰度数据场同步
    wire    [ 7:0]          Y_data              ;   //灰度数据
    wire                    Y_de                ;   //灰度数据使能

    wire                    mean_hsync          ;   //灰度数据行同步
    wire                    mean_vsync          ;   //灰度数据场同步
    wire    [ 7:0]          mean_data           ;   //灰度数据
    wire                    mean_de             ;   //灰度数据使能

    wire    [ 7:0]          sobel_data          ;   //灰度数据

img_gen # 
(
    .H_DISP         (H_DISP         ),
    .V_DISP         (V_DISP         )
)
u_img_gen
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),

    .img_hsync      (RGB_hsync      ),
    .img_vsync      (RGB_vsync      ),
    .img_data       (RGB_data       ),
    .img_de         (RGB_de         )
);

rgb2ycbcr  u_rgb2ycbcr 
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .RGB_hsync      (RGB_hsync      ),
    .RGB_vsync      (RGB_vsync      ),
    .RGB_data       (RGB_data       ),
    .RGB_de         (RGB_de         ),

    .Y_hsync        (Y_hsync        ),
    .Y_vsync        (Y_vsync        ),
    .Y_data         (Y_data         ),
    .Y_de           (Y_de           )
);

alpha_mean # 
(
    .H_DISP         (H_DISP         ),
    .V_DISP         (V_DISP         )
)
u_alpha_mean 
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .Y_hsync        (Y_hsync        ),
    .Y_vsync        (Y_vsync        ),
    .Y_data         (Y_data         ),
    .Y_de           (Y_de           ),

    .mean_hsync     (mean_hsync     ),
    .mean_vsync     (mean_vsync     ),
    .mean_data      (mean_data      ),
    .mean_de        (mean_de        )

//    .mean_de        (VGA_de         ),
//    .mean_hsync     (VGA_hsync      ),
//    .mean_vsync     (VGA_vsync      ),
//    .mean_data      (sobel_data     )
);

sobel #
//sobel_3x3 #
//sobel_5x5 # 
(
    .H_DISP         (H_DISP         ),
    .V_DISP         (V_DISP         )
)
u_sobel 
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .Y_de           (mean_de        ),
    .Y_hsync        (mean_hsync     ),
    .Y_vsync        (mean_vsync     ),
    .Y_data         (mean_data      ),

    .value          (25),

    .sobel_de       (VGA_de         ),
    .sobel_hsync    (VGA_hsync      ),
    .sobel_vsync    (VGA_vsync      ),
    .sobel_data     (sobel_data     )
);

assign VGA_data = {sobel_data,sobel_data,sobel_data};

endmodule