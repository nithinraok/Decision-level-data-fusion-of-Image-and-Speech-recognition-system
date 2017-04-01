clc;
close all;
clear all;
cam = webcam;
preview(cam);
pause(5);
img=snapshot(cam);
image(img);