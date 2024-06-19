clc        %清除命令窗口的内容
close all  %关闭所有的Figure窗口
clear all  %清除工作空间的所有变量
 
%% median_filtered_gray_302.bmp  中值滤波以后的图片     1.png   原图片

origin_ima=imread('post.jpg');
hist1=imhist(origin_ima);
[seg_ima,T]=Global_threshold(origin_ima,1);
hist2=imhist(seg_ima);
 
subplot(2,2,1);imshow(origin_ima);title('origin');
subplot(2,2,2);stem(hist1,'.');title('hist');
subplot(2,2,3);imshow(seg_ima);title('seg_ima');
imwrite(seg_ima, 'b.png'); % 将 seg_ima 图像保存为 PNG 格式

subplot(2,2,4);stem(hist2,'.');title('全局分割图像直方图');
 
uint8(T)
%% 全局阈值分割函数，det_T0为迭代控制参数
function [Result,T0] = Global_threshold(ima,det_T0)  
%%接受两个输入参数：ima（待处理的图像）和 det_T0（迭代控制参数，用于判断迭代何时停止）
%%函数返回两个输出：Result（二值化后的图像）和 T0（最终确定的阈值）
[m,n]=size(ima);
Result = zeros(m,n);
%%这两行代码获取输入图像 ima 的大小，并初始化输出图像 Result，其大小与输入图像相同，所有像素值均设为 0。
value=0;
for x=1:m
    for y=1:n
        value=value+double(ima(x,y));
    end
end
T0=value/(m*n); det_T = T0;
%% 这段代码计算输入图像 ima 的所有像素值的总和，并计算初始阈值 T0，即图像的平均灰度值
while(det_T>det_T0)
    G1=0;G2=0;count1=0;count2=0;
    for x=1:m
        for y=1:n
            if(ima(x,y)>T0)
                G1=G1+double(ima(x,y));
                count1=count1+1;
            else
                G2=G2+double(ima(x,y));
                count2=count2+1;
            end
        end
    end
    m1=G1/count1; m2=G2/count2;
    T=1/2*(m1+m2);
    det_T=T-T0; T0=T;
end
%%这个 while 循环实现了迭代阈值确定过程。在每次迭代中，它根据当前阈值 T0 将图像像素分为两部分（大于 T0 和小于等于 T0），然后计算这两部分像素的平均灰度值 m1 和 m2。
%%新的阈值 T 被设置为 m1 和 m2 的平均值。迭代继续进行，直到阈值的变化 det_T 小于迭代控制参数 det_T0。
 
for x=1:m
   for y=1:n
        if(ima(x,y)>T0)
            Result(x,y)=1;
        end
   end
end
%%如果像素值大于 T0，则 Result 对应位置的像素值设置为 1（白色），否则保持为 0（黑色）。
end