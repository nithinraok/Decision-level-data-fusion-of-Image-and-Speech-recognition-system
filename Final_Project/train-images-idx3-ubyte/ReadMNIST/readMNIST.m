function [I,labels,I_test,labels_test] = readMNIST(num)
%===========Читаем обучающую выборку
path = '..\train-images.idx3-ubyte';
fid = fopen(path,'r','b');  %big-endian
disp('hello'    );
magicNum = fread(fid,1,'int32');    %Магическое число
if(magicNum~=2051) 
    display('Error: cant find magic number');
    return;
end
imgNum = fread(fid,1,'int32');  %Количество изображений
rowSz = fread(fid,1,'int32');   %Размер изображения по вертикали
colSz = fread(fid,1,'int32');   %Размер изображения по горизонтали

if(num<imgNum) 
    imgNum=num; 
end

for k=1:imgNum
        I{k} = uint8(fread(fid,[rowSz colSz],'uchar'));
end
fclose(fid);

%============Читаем метки
path = '..\train-labels.idx1-ubyte';
fid = fopen(path,'r','b');  % big-endian
magicNum = fread(fid,1,'int32');    %Магическое число
if(magicNum~=2049) 
    display('Error: cant find magic number');
    return;
end
itmNum = fread(fid,1,'int32');  %Количество меток

if(num<itmNum) 
    itmNum=num; 
end

labels = uint8(fread(fid,itmNum,'uint8'));   %Загружаем все метки

fclose(fid);

%============Читаем тестовую выборку
path = '..\t10k-images.idx3-ubyte';
fid = fopen(path,'r','b');  % big-endian
magicNum = fread(fid,1,'int32');    %Магическое число
if(magicNum~=2051) 
    display('Error: cant find magic number');
    return;
end
imgNum = fread(fid,1,'int32');  %Количество изображений
rowSz = fread(fid,1,'int32');   %Размер изображения по вертикали
colSz = fread(fid,1,'int32');   %Размер изображения по горизонтали

if(num<imgNum) 
    imgNum=num; 
end

for k=1:imgNum
        I_test{k} = uint8(fread(fid,[rowSz colSz],'uchar'));
end
fclose(fid);

%============Читаем тестовые метки
path = '..\t10k-labels.idx1-ubyte';
fid = fopen(path,'r','b');  % big-endian
magicNum = fread(fid,1,'int32');    %Магическое число
if(magicNum~=2049) 
    display('Error: cant find magic number');
    return;
end
itmNum = fread(fid,1,'int32');  %Количество меток
if(num<itmNum) 
    itmNum=num; 
end
labels_test = uint8(fread(fid,itmNum,'uint8'));   %Загружаем все метки

fclose(fid);