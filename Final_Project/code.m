clear all
close all
load test4.mat
output_path = '.\outputs\digit4\';
mkdir(output_path);
for i=1:size(D,1)
img=D(i,:);img=reshape(img,28,28);
img=imrotate(img,-90);
I2 = flipdim(img ,2); 
filename = [output_path 'digit4_' num2str(i) '.jpg'];
imwrite(I2,filename);
end