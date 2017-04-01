clear all
close all
clc
test=rgb2gray(imresize(imread('test.jpg'),[1024 1024]));
test1=rgb2gray(imresize(imread('test1.jpg'),[1024 1024]));
test2=rgb2gray(imresize(imread('test2.jpg'),[1024 1024]));
test3=rgb2gray(imresize(imread('test3.jpg'),[1024 1024]));
test4=rgb2gray(imresize(imread('test4.jpg'),[1024 1024]));
test=imrotate(test,90);
Etest=edge(test,'canny');
