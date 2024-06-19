clc        %清除命令窗口的内容
close all  %关闭所有的Figure窗口
clear all  %清除工作空间的所有变量
 
%% median_filtered_gray_302.bmp  中值滤波以后的图片     1.png   原图片

origin_ima=imread('post.jpg');
hist1=imhist(origin_ima); 

subplot(2,2,1);imshow(origin_ima);title('原图像');
subplot(2,2,2);stem(hist1,'.');title('原图直方图');


% 读取图像
origin_ima = imread('post.jpg');
hist1=imhist(origin_ima); 
subplot(2,2,1);imshow(origin_ima);title('原图像');
subplot(2,2,2);stem(hist1,'.');title('原图直方图');


% 如果图像是彩色的，转换为灰度图像
if size(origin_ima, 3) == 3
    gray_ima = rgb2gray(origin_ima);
else
    gray_ima = origin_ima;
end

% 设置阈值
threshold_value = 70;

% 应用阈值处理
% 创建与灰度图像大小相同的二值图像
binary_ima = zeros(size(gray_ima));

% 比较每个像素的灰度值与阈值
for i = 1:size(gray_ima, 1)
    for j = 1:size(gray_ima, 2)
        if gray_ima(i, j) > threshold_value
            binary_ima(i, j) = 1; % 设置为白色
        end
    end
end

% 显示原始图像和二值化图像

subplot(2, 2, 3);
imshow(binary_ima);
title('Binary Image');

hist2=imhist(binary_ima); 
subplot(2,2,4);stem(hist2,'.');title('原图直方图');

