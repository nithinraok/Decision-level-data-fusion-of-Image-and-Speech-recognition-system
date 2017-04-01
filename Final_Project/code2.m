clear all
close all
output_path = '..\Final2\traindata\outputs\digit5\';
mkdir(output_path);
addpath(output_path);
for i=751:1000
    Int = randi([37 54],1,1);
    filename1 = ['digit5_' num2str(Int) '.jpg'];
     Int = randi([1 36],1,1);
    filename2 = ['digit5_' num2str(Int) '.jpg'];
    
img=(imread(filename1)-imread(filename2));
% img=imnoise(img,'gaussian',0,floor((i-750)/2));
img=imrotate(img,-i*90);
img = flipdim(img ,2);
img = im2bw(img,graythresh(img));
img=imresize(img,[28 28]);

filename = [output_path 'digit5_' num2str(i) '.jpg'];
imwrite(img,filename);
end