clc        %�������ڵ�����
close all  %�ر����е�Figure����
clear all  %��������ռ�����б���
 
%% median_filtered_gray_302.bmp  ��ֵ�˲��Ժ��ͼƬ     1.png   ԭͼƬ

origin_ima=imread('post.jpg');
hist1=imhist(origin_ima);
[seg_ima,T]=Global_threshold(origin_ima,1);
hist2=imhist(seg_ima);
 
subplot(2,2,1);imshow(origin_ima);title('origin');
subplot(2,2,2);stem(hist1,'.');title('hist');
subplot(2,2,3);imshow(seg_ima);title('seg_ima');
imwrite(seg_ima, 'b.png'); % �� seg_ima ͼ�񱣴�Ϊ PNG ��ʽ

subplot(2,2,4);stem(hist2,'.');title('ȫ�ַָ�ͼ��ֱ��ͼ');
 
uint8(T)
%% ȫ����ֵ�ָ����det_T0Ϊ�������Ʋ���
function [Result,T0] = Global_threshold(ima,det_T0)  
%%�����������������ima���������ͼ�񣩺� det_T0���������Ʋ����������жϵ�����ʱֹͣ��
%%�����������������Result����ֵ�����ͼ�񣩺� T0������ȷ������ֵ��
[m,n]=size(ima);
Result = zeros(m,n);
%%�����д����ȡ����ͼ�� ima �Ĵ�С������ʼ�����ͼ�� Result�����С������ͼ����ͬ����������ֵ����Ϊ 0��
value=0;
for x=1:m
    for y=1:n
        value=value+double(ima(x,y));
    end
end
T0=value/(m*n); det_T = T0;
%% ��δ����������ͼ�� ima ����������ֵ���ܺͣ��������ʼ��ֵ T0����ͼ���ƽ���Ҷ�ֵ
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
%%��� while ѭ��ʵ���˵�����ֵȷ�����̡���ÿ�ε����У������ݵ�ǰ��ֵ T0 ��ͼ�����ط�Ϊ�����֣����� T0 ��С�ڵ��� T0����Ȼ����������������ص�ƽ���Ҷ�ֵ m1 �� m2��
%%�µ���ֵ T ������Ϊ m1 �� m2 ��ƽ��ֵ�������������У�ֱ����ֵ�ı仯 det_T С�ڵ������Ʋ��� det_T0��
 
for x=1:m
   for y=1:n
        if(ima(x,y)>T0)
            Result(x,y)=1;
        end
   end
end
%%�������ֵ���� T0���� Result ��Ӧλ�õ�����ֵ����Ϊ 1����ɫ�������򱣳�Ϊ 0����ɫ����
end