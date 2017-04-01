
clc;
clear all;
close all;

%Read input image
Y=imread('testimage.jpg');
% Y=rgb2gray(I);
imshow(Y);

% Remove noise using median filter

%B=im2bw(I);
%figure;
%imshow(B)
%YM=medfilt2(Y,[3 3]);
%figure;
%imshow(YM);

[m n]=size(Y);
%Contrast Enhancement if the lighting condition is poor

% min_Y=min(min(Y));
% max_Y=max(max(Y));
% for i=1:m
%     for j=1:n
%        C(i,j) = ((double(Y(i,j))-min_Y)*255)/(max_Y-min_Y);
%     end 
% end
% figure;
% imshow(uint8(C));
%D=histeq(C);
%figure;
%imshow(D);
%define directional kernels
kernel1=[1 1 1;1 -2 1;-1 -1 -1];
kernel2=[1 1 1;1 -2 -1;1 -1 -1];
kernel3=[1 1 -1;1 -2 -2;1 1 -1];
kernel4=[1 -1 -1;1 -2 -1;1 1 1];
kernel5=[-1 -1 -1;1 -2 1;1 1 1];
kernel6=[-1 -1 1;-1 -2 1;1 1 1];
kernel7=[-1 1 1;-1 -2 1;-1 1 1];
kernel8=[1 1 1;-1 -2 1;-1 -1 1];
Y1=conv2(Y,kernel1,'same');
Y2=conv2(Y,kernel2,'same');
Y3=conv2(Y,kernel3,'same');
Y4=conv2(Y,kernel4,'same');
Y5=conv2(Y,kernel5,'same');
Y6=conv2(Y,kernel6,'same');
Y7=conv2(Y,kernel7,'same');
Y8=conv2(Y,kernel8,'same');
A=Y1+Y2+Y3+Y4+Y5+Y6+Y7+Y8;
figure;
imshow(A);%Image showing edge feature

% %extraction using line detection
% line1=[-1 -1 -1;2 2 2;-1 -1 -1];
% line2=[-1 2 -1;-1 2 -1;-1 2 -1];
% line3=[-1 2 -1;-1 2 -1;-1 2 -1];
% line4=[-1 -1 -1;2 2 2;-1 -1 -1];
% Z1=conv2(Y,line1,'same');
% Z2=conv2(Y,line2,'same');
% Z3=conv2(Y,line3,'same');
% Z4=conv2(Y,line4,'same');
% A=Z1+Z2+Z3+Z4;
% figure;
% imshow(A);

sum=0;
 for i=1:m
     for j=1:n
       sum=sum+A(i,j);
     end 
 end
avg=sum/(m*n);
 for i=1:m
     for j=1:n
        if(A(i,j)>(3*avg))
            D(i,j)=0;
        else 
            D(i,j)=1;
        end
     end 
 end
 
 %figure;
 %imshow(D);
 for i=1:m
     for j=1:n
         sume=0;
         for k=0:3
             for l=0:3
                 if((i+k)>m)|((j+l)>n)
                     D(i+k,j+l)=0;
                 end
                 sume=sume+D(i+k,j+l);
                 
             end
         end
         aveg=sume/9;
         if (abs(aveg-D(i,j)))>127.5
             R(i,j)=255-D(i,j);
         else
             R(i,j)=D(i,j);
         end
     end
      end
 %figure;
 %imshow(R);

 %Find Maximum area of different regions
 %Find total area
 %Find Average area
 
 
  B= [0 1 0; 1 1 1; 0 1 0]
  X = imdilate(R,B);
 
 L=bwlabel(X);
   Regions=regionprops(L,'all');
  MaxArea=0;
  total_area=0;
  for r=1:length(Regions)
      Area=Regions(r).Area;
      total_area=total_area+Area;
      if(MaxArea<Area)
          MaxArea=Area;
     end
  end
  avg_area=total_area/length(Regions);
 disp(MaxArea); 
 disp(total_area);
 disp(avg_area);
 
 S=regionprops(L,'area');
 for i=1:length(S)
    idx = find([S.Area] <(0.04*total_area));
   Newimage = ismember(L,idx);
 end

 figure; imshow(Newimage)
 finalimage = bwareaopen(Newimage,100);

 
 
figure, imshow(finalimage);

C=[1 1 1;1 1 1;1 1 1];
eroim=imerode(finalimage,C);
figure,imshow(eroim);

%result=imfill(eroim,'B')
%figure,imshow(result);
 %Imop=imopen(Newimage,B);
 
 %Newimage = imfill(BW,'holes') 
%   for i=1:length(S)
%     idx = find([S.Area] <(8*avg_area));
%     X = ismember(L,idx);
%  end
%  for i=1:length(S)
%     idx = find([S.Area] >(0.15*avg_area));
%     X = ismember(L,idx);
%  end
%  for i=1:length(S)
%     idx = find([S.Area] <(MaxArea/20));
%     X = ismember(L,idx);
%  end
 
%    for r=1:length(Regions)
%        
%       A=Regions(r).Area;
%       if(A<MaxArea/20)
%          X=bwareaopen(R,A);
%       end
%       
%    end

