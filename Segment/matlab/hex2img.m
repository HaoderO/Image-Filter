clc;
clear all;

pre_img = imread('test.png'); 
[v,h] = size(pre_img); 
fix_seg_img = uint8(zeros(v,h));
glb_seg_img = uint8(zeros(v,h));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('fix_seg.txt','r');
for i=1:v
    for j=1:h
        fix_seg_img(i,j) = fscanf(fid,'%x',1); 
    end
end
fclose(fid); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('glb_seg.txt','r'); 
for i=1:v
    for j=1:h
        glb_seg_img(i,j) = fscanf(fid,'%x',1); 
    end 
end
fclose(fid); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(131);imshow(pre_img),title('pre')
subplot(132);imshow(fix_seg_img),title('fix_seg')
subplot(133);imshow(glb_seg_img),title('glb_seg')

imwrite(fix_seg_img,'fix_seg.jpg');
imwrite(glb_seg_img,'glb_seg.jpg');