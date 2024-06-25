clc;
clear all;

origin_img = imread('test.jpg');         %读�??????
[v,h,N] = size(origin_img);                 %?��??��??尺�??[�?�?�?宽度�?维度]
RGB_ij = uint64(zeros(v,h));                %�?�?32�?宽�??RGB????

fid = fopen('origin_img.txt','w');          %??�???�?
for i = 1:v
    for j = 1:h
        R = double(origin_img(i,j,1));
        G = double(origin_img(i,j,2));
        B = double(origin_img(i,j,3));
        RGB          = R*(2^16) + G*(2^8) + B;
        RGB_ij(i,j)  = RGB;
        RGB_hex      = dec2hex(RGB);
        fprintf(fid,'%s\n',RGB_hex);        %�?�?�?�???txt??�?
    end
end
fclose(fid); %?��????�?

imshow(origin_img),title('origin');     %?�示????