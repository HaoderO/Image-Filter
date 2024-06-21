clc;
clear all;

%gray_img = imread('2.bmp');
gray_img = imread('test.png');

[v,h,N] = size(gray_img);

fid=fopen('pre.txt','w');
for i=1:v  
    for j=1:h
        fprintf(fid,'%x\n',gray_img(i,j));
    end   
end
fclose(fid);