clc;
clear all;

origin_img = imread('test.jpg');         %è¯»å??????
[v,h,N] = size(origin_img);                 %?·å??¾ç??å°ºå??[é«?åº?ï¼?å®½åº¦ï¼?ç»´åº¦]
RGB_ij = uint64(zeros(v,h));                %å®?ä¹?32ä½?å®½ç??RGB????

fid = fopen('origin_img.txt','w');          %??å¼???ä»?
for i = 1:v
    for j = 1:h
        R = double(origin_img(i,j,1));
        G = double(origin_img(i,j,2));
        B = double(origin_img(i,j,3));
        RGB          = R*(2^16) + G*(2^8) + B;
        RGB_ij(i,j)  = RGB;
        RGB_hex      = dec2hex(RGB);
        fprintf(fid,'%s\n',RGB_hex);        %å°?å­?ç¬?å­???txt??ä»?
    end
end
fclose(fid); %?³é????ä»?

imshow(origin_img),title('origin');     %?¾ç¤º????