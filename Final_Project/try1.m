I=imread('test.jpg');
I=imrotate(I,90);
I=rgb2gray(I);
background = imopen(I,strel('disk',15));
I2 = I - background;
I3 = imadjust(I2);
level = graythresh(I3);
bw = im2bw(I3,level);
bw = bwareaopen(bw, 50);
cc = bwconncomp(bw, 4);
imshow(bw);