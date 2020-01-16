clc
clear all
close all
warning off

while(1)
    ch=menu('EFFECTIVE CONTRAST BASED DEHAZING',....
    'LOAD HAZE IMAGE',....
    'ESTIMATE GLOBAL AIRLIGHT',....
    'CALCULATE BOUNDARY CONSTRAINTS',....
    'REFINING ESTIMATION',....
    'APPLY DEHAZING',...
    'HAZE MATCHING POINTS',....
    'DEHAZE MATCHING POINTS ',...
    'EXIT');

if (ch==1)
    

[file,path]=uigetfile('input\*.bmp');
filename=strcat(path,file);

HazeImg = imread(filename);
figure, imshow(HazeImg, []);

% [] for better display

end

if(ch==2)
    method = 'manual'; 
wsz = 15; % window size
A = Airlight(HazeImg, method, wsz); 

end
if (ch==3)
    
    wsz = 3; % window size
ts = Boundcon(HazeImg, A, 30, 300, wsz);
end
    
if(ch==4)
    lambda = 2;  % regularization parameter, the more this parameter, the closer to the original patch-wise transmission
t = CalTransmission(HazeImg, ts, lambda, 0.5); % using contextual information
end

if(ch==5)
    r = Dehazefun(HazeImg, t, A, 0.85); 

% show and save the results
figure, imshow(ts, []);
figure, imshow(1-t, []); colormap hot;
figure, imshow(r, []);

end

if(ch==6)

I1p=HazeImg;
I1=rgb2gray(HazeImg);

I2p=HazeImg;
I2=rgb2gray(I2p);
Options.upright=true;
Options.tresh=0.0001;
Ipts1=OpenSurf(I1,Options);
Ipts2=OpenSurf(I2,Options);

D1 = reshape([Ipts1.descriptor],64,[]);
D2 = reshape([Ipts2.descriptor],64,[]);

err=zeros(1,length(Ipts1));
cor1=1:length(Ipts1);
cor2=zeros(1,length(Ipts1));
for i=1:length(Ipts1),
    distance=sum((D2-repmat(D1(:,i),[1 length(Ipts2)])).^2,1);
    [err(i),cor2(i)]=min(distance);
end


[err, ind]=sort(err);
cor1=cor1(ind);
cor2=cor2(ind);

% Make vectors with the coordinates of the best matches
Pos1=[[Ipts1(cor1).y]',[Ipts1(cor1).x]'];
Pos2=[[Ipts2(cor2).y]',[Ipts2(cor2).x]'];
Pos1=Pos1(1:5:300,:);
Pos2=Pos2(1:5:300,:);

I = zeros([size(I1p,1) size(I1p,2)*2 size(I1p,3)]);
I(:,1:size(I1,2),:)=I1p; I(:,size(I1p,2)+1:size(I1p,2)+size(I2p,2),:)=I2p;
figure('name','Matching Points','numbertitle','off')
imshow(uint8(I)); hold on;
pause(0.5)
% Show the best matches
plot([Pos1(:,2) Pos2(:,2)+size(I1,2)]',[Pos1(:,1) Pos2(:,1)]','-');
plot([Pos1(:,2) Pos2(:,2)+size(I1,2)]',[Pos1(:,1) Pos2(:,1)]','o');

end

if(ch==7)
imwrite(r,'De.jpg');
v=imread('De.jpg');
I1pp=v;
I11=rgb2gray(v);

I2pp=v;
I22=rgb2gray(v);
Options.upright=true;
Options.tresh=0.0001;
Ipts11=OpenSurf(I11,Options);
Ipts22=OpenSurf(I22,Options);

D11 = reshape([Ipts11.descriptor],64,[]);
D22 = reshape([Ipts22.descriptor],64,[]);

err1=zeros(1,length(Ipts11));
cor11=1:length(Ipts11);
cor22=zeros(1,length(Ipts11));
for i=1:length(Ipts11),
    distance=sum((D22-repmat(D11(:,i),[1 length(Ipts22)])).^2,1);
    [err1(i),cor22(i)]=min(distance);
end


[err1, ind1]=sort(err1);
cor11=cor11(ind1);
cor22=cor22(ind1);

% Make vectors with the coordinates of the best matches
Pos11=[[Ipts11(cor11).y]',[Ipts11(cor11).x]'];
Pos22=[[Ipts22(cor22).y]',[Ipts22(cor22).x]'];
Pos11=Pos11(1:2:300,:);
Pos22=Pos22(1:2:300,:);

Ic = zeros([size(I1pp,1) size(I1pp,2)*2 size(I1pp,3)]);
Ic(:,1:size(I11,2),:)=I1pp; Ic(:,size(I1pp,2)+1:size(I1pp,2)+size(I2pp,2),:)=I2pp;
figure('name','Matching Points','numbertitle','off')
imshow(uint8(Ic)); hold on;
pause(0.5)
% Show the best matches
plot([Pos11(:,2) Pos22(:,2)+size(I11,2)]',[Pos11(:,1) Pos22(:,1)]','-');
plot([Pos11(:,2) Pos22(:,2)+size(I11,2)]',[Pos11(:,1) Pos22(:,1)]','o');

end

if(ch==8)
    break
end

end