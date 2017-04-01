
clc;
clear all, close all
Y=imread('testimage.jpg'); % tmp is an indexed image file using 

% x=rgb2gray(Y); % convert the image into a grayscale image
x=Y;
clear tmp map;

[LL,LH,HL,HH]=dwt2(x,'haar'); % use Haar wavelet to perform 
% scale LH, HL, HH

figure(1), 
subplot(2,2,1),imagesc(LL),colormap('gray'),title('LL');
subplot(2,2,2),imagesc(HL),colormap('gray'),title('LH');
subplot(2,2,3),imagesc(LH),colormap('gray'),title('HL');
subplot(2,2,4),imagesc(HH),colormap('gray'),title('HH');

W=16;
H=16;
l1=16;
l2=16;
[M N]=size(HL);
d1=mod(M-W,l1);
d2=mod(N-H,l2);

w=min(l1-d1,mod(l1-d1,l1));
    h=min(l2-d2,mod(l2-d2,l2));
    LH=[LH zeros(M,w)];
    LH=[LH;zeros(h,N+w)];

XLH=[0 0 0 0];
for u=0:l1:M-l1
    for v=0:l2:N-l2
SumLH=0;
meanLH=0;
VarLH=0;
EneLH=0;
Gtheta=0;
for i=1:W
    for j=1:H
        SumLH=SumLH+LH(u+i,v+j);
        EneLH=EneLH+LH(u+i,v+j)^2;
        Gtheta= Gtheta+(i-j)^2*LH(u+i,v+j);
            end
end
meanLH=SumLH/(W*H)
for i=1:W
    for j=1:H
        VarLH=VarLH+(LH(u+i,v+j)-meanLH)^2;
            end
end
VarLH=VarLH/(W*H);
VarLH=sqrt(VarLH);
XLH=[XLH;meanLH VarLH EneLH Gtheta];
    end
end

    w=min(l1-d1,mod(l1-d1,l1));
    h=min(l2-d2,mod(l2-d2,l2));
    HL=[HL zeros(M,w)];
    HL=[HL;zeros(h,N+w)];

XHL=[0 0 0 0];
for u=0:l1:M-l1
    for v=0:l2:N-l2
SumHL=0;
meanHL=0;
VarHL=0;
EneHL=0;
Gtheta=0;
for i=1:W
    for j=1:H
        SumHL=SumHL+HL(u+i,v+j);
        EneHL=EneHL+HL(u+i,v+j)^2;
        Gtheta= Gtheta+(i-j)^2*HL(u+i,v+j);
            end
end
meanHL=SumHL/(W*H)
for i=1:W
    for j=1:H
        VarHL=VarHL+(HL(u+i,v+j)-meanHL)^2;
            end
end
VarHL=VarHL/(W*H);
VarHL=sqrt(VarHL);
XHL=[XHL;meanHL VarHL EneHL Gtheta];
    end
end

HH=[HH zeros(M,w)];
    HH=[HH;zeros(h,N+w)];

XHH=[0 0 0 0];
for u=0:l1:M-l1
    for v=0:l2:N-l2
SumHH=0;
meanHH=0;
VarHH=0;
EneHH=0;
Gtheta=0;
for i=1:W
    for j=1:H
        SumHH=SumHH+HH(u+i,v+j);
        EneHH=EneHH+HH(u+i,v+j)^2;
        Gtheta= Gtheta+(i-j)^2*HH(u+i,v+j);
            end
end
meanHH=SumHH/(W*H)
for i=1:W
    for j=1:H
        VarHH=VarHH+(HH(u+i,v+j)-meanHH)^2;
            end
end
VarHH=VarHH/(W*H);
VarHH=sqrt(VarHH);
XHH=[XHH;meanHH VarHH EneHH Gtheta];
    end
end

X=[XLH XHL XHH]';
maxerr = 0;
K=12;
[proto Nproto] = simple_kmeans(X,K,maxerr)