clc;
clear all;

pre_img = imread('test.png'); 
[v,h] = size(pre_img); 
fix_seg_img = uint8(zeros(v,h));
adp_seg_img = uint8(zeros(v,h));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('fix_seg.txt','r');
for i=1:v
    for j=1:h
        fix_seg_img(i,j) = fscanf(fid,'%x',1); 
    end
end
fclose(fid); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('adp_seg.txt','r'); 
for i=1:v
    for j=1:h
        adp_seg_img(i,j) = fscanf(fid,'%x',1); 
    end 
end
fclose(fid); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(221);imshow(pre_img    ),title('pre'    )
subplot(222);imshow(fix_seg_img),title('fix_seg')
subplot(223);imshow(adp_seg_img),title('adp_seg')

imwrite(fix_seg_img,'fix_seg.png');
imwrite(adp_seg_img,'adp_seg.png');