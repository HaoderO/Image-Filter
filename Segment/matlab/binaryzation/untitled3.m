clc        %清除命令窗口的内容
close all  %关闭所有的Figure窗口
clear all  %清除工作空间的所有变量
 
origin_ima=imread('post.jpg');
hist1=imhist(origin_ima);
 
p=Histogram(origin_ima);
[seg_ima1,T]=Global_threshold(origin_ima,2);
 
[seg_ima,T] = Optimal_threshold(origin_ima,p);
hist2=imhist(seg_ima);
 
subplot(2,2,1);imshow(origin_ima);title('原图像');
subplot(2,2,2);stem(hist1,'.');title('原图直方图');
subplot(2,2,3);imshow(seg_ima1);title('全局分割图像');
subplot(2,2,4);imshow(seg_ima);title('Otsu方法分割图像');
 
T
 
 
 
%% 计算图像概率直方图
function p = Histogram(ima)
[m,n]=size(ima);
p=zeros(256,1);
for x=1:m
    for y=1:n
        p(ima(x,y)+1)=double( p(ima(x,y)+1)+1 );
    end
end
p=p/(m*n);
end
 
%% 进行最优阈值分割，输入原图像和概率直方图，返回分割图像和最优阈值
function [seg_ima,T] = Optimal_threshold(ima,p)
 
mG=0;
for k=0:255
    mG = mG + k*p(k+1);
end
 
P1=zeros(256,1);
for k=0:255
    for j=0:k
        P1(k+1) = P1(k+1)+p(j+1);
    end
end
 
m=zeros(256,1);
for k=0:255
    for j=0:k
        m(k+1) = m(k+1)+j*p(j+1);
    end
end
 
var=zeros(256,1);
for k=1:256
    var(k) = ( mG*P1(k)-m(k) )^2 / ( P1(k)*(1-P1(k)));
end
    
max=0;count=0;T=0;
for k=1:256
    if(var(k))>max
        max=var(k);
    end
end
 
for k=1:256
    if(var(k))==max
        count=count+1;
        T=T+k-1;
    end
end
T=T/count;
 
[a,b]=size(ima);
seg_ima=zeros(256);
for x=1:a
    for y=1:b
        if(ima(x,y)>T)
            seg_ima(x,y)=1;
        end
    end
end
end
 
%% 全局阈值分割函数，det_T0为迭代控制参数
function [Result,T0] = Global_threshold(ima,det_T0)
[m,n]=size(ima);
Result = zeros(m,n);
 
value=0;
for x=1:m
    for y=1:n
        value=value+double(ima(x,y));
    end
end
T0=value/(m*n); det_T = T0;
 
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
 
for x=1:m
   for y=1:n
        if(ima(x,y)>T0)
            Result(x,y)=1;
        end
   end
end
end