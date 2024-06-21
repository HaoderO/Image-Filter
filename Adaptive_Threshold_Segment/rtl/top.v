`timescale 1 ns/1 ns

module top
#(
    parameter               H_DISP = 640        ,   //图像宽度
    parameter               V_DISP = 480            //图像高度
)
(
    input   wire            clk                 ,
    input   wire            rst_n               ,

    output  wire            fixseg_hsync        ,   //VGA行同步
    output  wire            fixseg_vsync        ,   //VGA场同步
    output  wire    [7:0]   fixseg_data         ,   //VGA数据
    output  wire            fixseg_de           ,   //VGA数据使能

    output  wire            adpseg_hsync        ,   //VGA行同步
    output  wire            adpseg_vsync        ,   //VGA场同步
    output  wire    [7:0]   adpseg_data         ,   //VGA数据
    output  wire            adpseg_de               //VGA数据使能
);

    wire                    img_hsync           ;   //待处理数据行同步
    wire                    img_vsync           ;   //待处理数据场同步
    wire    [7:0]           img_data            ;   //待处理数据
    wire                    img_de              ;   //待处理数据使能

    wire                    bina_hsync          ;   //待处理数据行同步
    wire                    bina_vsync          ;   //待处理数据场同步
    wire    [7:0]           bina_data           ;   //待处理数据
    wire                    bina_de             ;   //待处理数据使能

    wire                    erode_hsync         ;   //待处理数据行同步
    wire                    erode_vsync         ;   //待处理数据场同步
    wire    [7:0]           erode_data          ;   //待处理数据
    wire                    erode_de            ;   //待处理数据使能

img_gen #
(
    .H_DISP                 (H_DISP             ),  //图像宽度
    .V_DISP                 (V_DISP             )   //图像高度
)
u_img_gen
(
    .clk                    (clk                ),  //时钟
    .rst_n                  (rst_n              ),  //复位
    
    .img_hsync              (img_hsync          ),  //img行同步
    .img_vsync              (img_vsync          ),  //img场同步
    .img_data               (img_data           ),  //img数据
    .img_de                 (img_de             )   //img数据使能
);

fix_segment #              
(               
    .THRESHOLD              (100                ),
    .H_DISP                 (H_DISP             ),
    .V_DISP                 (V_DISP             )
)           
fix_segment_inst           
(           
    .clk                    (clk                ),
    .rst_n                  (rst_n              ),
    .Y_hsync                (img_hsync          ),
    .Y_vsync                (img_vsync          ),
    .Y_data                 (img_data           ),
    .Y_de                   (img_de             ),

    .segment_hsync          (fixseg_hsync       ),
    .segment_vsync          (fixseg_vsync       ),
    .segment_data           (fixseg_data        ),
    .segment_de             (fixseg_de          )
);

//glb_segment # 
//(
//    .H_DISP                 (H_DISP             ),
//    .V_DISP                 (V_DISP             )
//)
//glb_segment_inst 
//(
//    .clk                    (clk                ),
//    .rst_n                  (rst_n              ),
//    .Y_hsync                (hist_hsync         ),
//    .Y_vsync                (hist_vsync         ),
//    .Y_data                 (hist_data          ),
//    .Y_de                   (hist_de            ),
//
//    .segment_hsync          (adpseg_hsync       ),
//    .segment_vsync          (adpseg_vsync       ),
//    .segment_data           (adpseg_data        ),
//    .segment_de             (adpseg_de          )
//);

   
adp_segment # 
(
    .H_DISP             (H_DISP         ),
    .V_DISP             (V_DISP         )
)
adp_segment_inst 
(
    .clk                (clk            ),
    .rst_n              (rst_n          ),
    .Y_hsync            (img_hsync      ),
    .Y_vsync            (img_vsync      ),
    .Y_data             (img_data       ),
    .Y_de               (img_de         ),

    .segment_hsync      (bina_hsync     ),
    .segment_vsync      (bina_vsync     ),
    .segment_data       (bina_data      ),
    .segment_de         (bina_de        )
);

erode # (
    .H_DISP             (H_DISP         ),
    .V_DISP             (V_DISP         )
)
u_erode 
(
    .clk                (clk            ),
    .rst_n              (rst_n          ),
    .bina_de            (bina_de        ),
    .bina_hsync         (bina_hsync     ),
    .bina_vsync         (bina_vsync     ),
    .bina_data          (bina_data      ),

    .erode_de           (erode_de       ),
    .erode_hsync        (erode_hsync    ),
    .erode_vsync        (erode_vsync    ),
    .erode_data         (erode_data     )
);

// 膨胀
dilate #
(
    .H_DISP             (H_DISP         ),
    .V_DISP             (V_DISP         ) 
)
u_dilate
(
    .clk                (clk            ), 
    .rst_n              (rst_n          ), 
    .bina_hsync         (erode_hsync    ),
    .bina_vsync         (erode_vsync    ),
    .bina_data          (erode_data     ),
    .bina_de            (erode_de       ),

    .dilate_hsync       (adpseg_hsync   ),
    .dilate_vsync       (adpseg_vsync   ),
    .dilate_data        (adpseg_data    ),
    .dilate_de          (adpseg_de      ) 
);

endmodule