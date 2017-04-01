clc;
close all;
clear all;
Y=imread('testimage.jpg');
figure;
imshow(Y);
title('Original image');
I=Y;
level = graythresh(I);
Ibin = im2bw(I,level);
meanI=mean2(I)
stdI=std2(I)

h=[1 2 1;0 0 0;-1 -2 -1];
v=[1 0 -1;2 0 -2;1 0 -1];
Ih=conv2(I,h);
Iv=conv2(I,v);
[m n]=size(I);
temp=0;
for i=1:m
    for j=1:n
        x=Ih(i,j)^2+Iv(i,j)^2;
        temp=temp+x;
        G(i,j)=sqrt(x);
    end
end
H=zeros(m,n);
th=sqrt((4*temp)/(m*n));
th1=th/max(max(G));
max_G=max(max(G));
for i=1:m
    for j=1:n
if ((G(i,j)/max_G)>=th1 &&(G(i,j)>=th));
    E(i,j)=1;
else 
    E(i,j)=0;
end 
    end
end
     
% figure;
% imshow(E);
% title('Edge image');

 k=0;l=0;
 q=20;
 w=q;
 h=q;
 F=zeros(m,n);

for l=0:q:n-q-1
    for k=0:q:m-q-1
        
        sum=0;    
 for i=k+1:k+w
     for j=l+1:l+h
         
         if (G(i,j)-th1)>=0
             Th1=1;
         else
             Th1=0;
         end
        
         if (E(i,j)-1)>=0
             Th2=1;
         else
             Th2=0;
         end
        
         F1=(Th1*Th2);
                 sum=sum+(G(i,j)*F1);
                 sum=sum/(w*h);
                 F(i,j)=sum;
     end
     end
      
 end
 end
%  figure;
%  imshow(F);
 
meanF=mean2(F)
stdF=std2(F)
 
%k value changes for images between 0 to 1  
  %K=0.1 ;
   F_max=max(max(F))
   F_min=min(min(F))
   %th3=K*(F_max-F_min)
g1=[-1 1];
g2=g1';
g1F=conv2(E,g1);
g2F=conv2(E,g2);
sumT=0;
sumS=0;
for i=1:m
    for j=1:n
       S(i,j)=min(g1F(i,j),g2F(i,j));
       sumS=sumS+S(i,j);
       sumT=sumT+(F(i,j)*S(i,j));
    end
end
T=sumT/sumS;
if(stdF>0.25)
    th2=T+0.1
elseif(stdF>0.15 && stdF<0.25)
    th2=T-0.25
else
    th2=T-0.3
end

Final=zeros(m,n);

           for i=1:m
                 for j=1:n
        if (F(i,j)>th2)
            Final(i,j)=1;
                 else
            Final(i,j)=0;
        end
            end
           end
             figure;
 imshow(Final);
 title('Removing non text regions using adaptive threshold value');

H=zeros(m,n);
for i=2:m-1
    for j=2:n-1
       X=[Final(i,j)-2 Final(i-1,j+1)-2 Final(i-1,j)-3 Final(i,j-1)];
       H(i,j)=min(X);
    end
end

for i=2:m-1
    for j=2:n-1
       X=[H(i,j)+2 H(i+1,j+1)+2 H(i+1,j)+3 H(i,j+1)];
       M(i,j)=max(X);
    end
end

figure;
imshow(M);
title('Image after dilation and erotion');


morp=bwmorph(M,'close');
morp1=bwmorph(morp,'clean');
 Hline=[1 1];
 morp2=imdilate(morp1,Hline);
 Vline=[1;1];
 morp3=imdilate(morp2,Vline);
H=bwareaopen(morp3,10);
figure;
imshow(H);
title('Removing very small objects');

L=bwlabel(H);
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
 allarea=[Regions.Area];
 idx = find(([Regions.Area]<(8*avg_area)&([Regions.Area] >(avg_area/8))));
 NImage = ismember(L,idx);
 
figure;
imshow(NImage);
title('removing large areas and small areas');

Z=zeros(size(NImage));
B=bwlabel(NImage);
S=regionprops(B,'all');
 BB=[S.BoundingBox];
 for i=1:length(S)
     width(i)=BB((i*4)-1);
     height(i)=BB(i*4);
 end
 
 
 
 sumH=0;
 sumV=0;

 
 for i=1:length(S)
     sumH=sumH+height(i);
     sumV=sumV+width(i);
 end
 
  avgH=sumH/length(S);
  avgV=sumV/length(S);
 for i=1:length(S)
 if (height(i)>(0.9*avgH))&&(height(i)<(4*avgH))
 x=S(i).PixelList(:,1);
 y=S(i).PixelList(:,2);
 Z(y,x)=NImage(y,x);
 end
 end
 
 for i=1:length(S)
 if (width(i)>(0.9*avgV))&&(width(i)<(4*avgV))
 x=S(i).PixelList(:,1);
 y=S(i).PixelList(:,2);
 Z(y,x)=NImage(y,x);
 end
end


 figure;
 imshow(Z);
 title('Removing long lines');
 
  for i=1:length(S)
  if ((width(i)/height(i)>0.1)&&(width(i)/height(i)<2.2))
 x=S(i).PixelList(:,1);
 y=S(i).PixelList(:,2);
 P(y,x)=Z(y,x);
 end
 end
%  figure;
% imshow(P);


newim=P;
title('Final edge of the text');
for i=x+1:m
    for j=y+1:n
        newim(i,j)=0;
    end
end

 [Ilabel num] = bwlabel(newim); 
 disp(num);
 Iprops = regionprops(Ilabel,'all'); 
Mask=zeros(m,n);
for i=1:num
 x=Iprops(i).PixelList(:,1);
 y=Iprops(i).PixelList(:,2);
 Mask(y,x)=1;
end
p=Iprops(1).Centroid;
q=round(p);
if(Ibin(q(1),q(2))==1)
 FinalImage=immultiply(Mask,Ibin);
 figure;
 imshow(FinalImage);
else
    FinalImage=immultiply(Mask,~Ibin);
 figure;
 imshow(FinalImage);
end
se=[0 1 0;1 1 1;0 1 0];
Result=imerode(FinalImage,se);
figure;
imshow(Result);
title('Extracted text regions');
%d = {'img70','meanF','stdF','F_max','K','th3','th2';1 meanF stdF F_max K th3 th2};
%xlswrite('testdata.xls', d, 1, 'A51')
%xlswrite('testdata.xls',[meanF stdF K th3 th2]);