clc;
clear all; 
close all;

% Enter date & time to make file name
DateTime = '2017_06_20_19_13_50';

% Open original RGB file
filename = sprintf('RGB%s.jpg',DateTime);
rgb = imread(filename); 
rgb = imresize(rgb, 1);
%figure, imshow(rgb,[])

% Enhance Image || Filter image and remove noise

% Crop and resize RGB image
rgb2 = imresize(rgb, 0.9);
rgb3 = imcrop(rgb2,[145 65 399 299]); % crop RGB image
figure, imshow(rgb3,[]); impixelinfo; 

% Open and read thermal binary file
filename = sprintf('IR%s.bin',DateTime);
fid=fopen(filename,'r'); 
data=fread(fid, [80 60],'2*int16');
% Check for error in data and fix it
for c = 1:60
    for r = 1:80        
        if data(r,c)<0
            data(r,c) = data(r,c)*(-1);       
        end        
    end
end
data = ((data/100)-273.15); % Pixel calibration
%data = data*1.0517-2.433; % Lepton calibration (Cam #1)
data = data*1.0814-3.027; % Lepton calibration (Cam #2)
%data = data*1.0531-0.6249; % Lepton calibration (Cam #3)-> Cherry Project
data = round(data,1);
fclose(fid);

%# Show thermal image in gray scale
W= data;
W = imrotate(W,90);
W = flipdim(W,1);
W = imresize(W, 5);
%figure, imshow(W,[]);colormap(jet);colorbar;impixelinfo

%# Show RGB and thermal images separately
%figure
%subplot(121), imshow(rgb3)
%subplot(122), imshow(W,[], 'colormap', jet);colorbar;impixelinfo

%# Show overlayed thermal & 'Cropped' RGB image
figure, imshow(rgb3), 
hold on
hImg = imshow(W,[], 'colormap', jet); set(hImg, 'AlphaData', 0.6); impixelinfo
hold off

%# Show a pseudocolor thermal image 
figure, h = pcolor(W);
set(h, 'EdgeColor', 'none');
xticks([0:50:800]); yticks([0:50:600]);
axis ij
axis equal tight; colormap(jet); colorbar; 

% Average Temperature (Cherries) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Binarize image by thresholding
red = rgb3(:,:,1); % Red channel
green = rgb3(:,:,2); % Green channel
blue = rgb3(:,:,3); % Blue channel
I2 = red > green & (red - green) > 20;  % logical indexing: removes background; keeps cherries
%figure, imshow(I2,[]); impixelinfo;
% Fill the holes
I3 = imfill(I2,'holes');
% Remove small objects
I4 = bwareaopen(I3, 400);
% Erode image
se = strel('disk',2);
I5 = imerode(I4,se);
figure, imshow(I5,[]); impixelinfo;
% Multiply binary 'Mask' by thermal image
I6 = immultiply(I5,W);
Z_Cherries = I6;
% Display image
figure, h = pcolor(I6);
set(h, 'EdgeColor', 'none');
xticks([0:50:800]); yticks([0:50:600]);
axis ij 
m = colorbar; 
xlabel(m,'Temperature (Celsius)')
axis equal tight; colormap(jet);
% Calculate average temperature of cherries
n=0;
cherry_temp=0;
for c = 1:400
    for r = 1:300        
        if Z_Cherries(r,c)>0
            n = n + 1; 
            cherry_temp = Z_Cherries(r,c) + cherry_temp;
        end        
    end
end
cherry_temp = cherry_temp/n 

% Average Temperature (leaves) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Binarize image by thresholding
red = rgb3(:,:,1); % Red channel
green = rgb3(:,:,2); % Green channel
blue = rgb3(:,:,3); % Blue channel
I2 = green > red & red > blue & (red - green) < 25;  % logical indexing: removes background; keeps cherries
%figure, imshow(I2,[]); impixelinfo;
% Fill the holes
I3 = imfill(I2,'holes');
% Remove small objects
I4 = bwareaopen(I3, 100);
% Erode image
se = strel('disk',1);
I5 = imerode(I4,se);
figure, imshow(I5,[]); impixelinfo;
% Multiply binary 'Mask' by thermal image
I6 = immultiply(I5,W);
Z_leaves = I6;
% Display image
figure, h = pcolor(I6);
set(h, 'EdgeColor', 'none');
xticks([0:50:800]); yticks([0:50:600]);
axis ij 
m = colorbar; 
xlabel(m,'Temperature (Celsius)')
axis equal tight; colormap(jet);
% Calculate average temperature of leaves
n=0;
leaf_temp=0;
for c = 1:400
    for r = 1:300        
        if Z_leaves(r,c)>0
            n = n + 1; 
            leaf_temp = Z_leaves(r,c) + leaf_temp;
        end        
    end
end
leaf_temp = leaf_temp/n

% Average Temperature (LWS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Binarize image by thresholding
red = rgb3(:,:,1); % Red channel
green = rgb3(:,:,2); % Green channel
blue = rgb3(:,:,3); % Blue channel
chDiff1 = red - blue;
chDiff2 = green - blue;
I2 = chDiff1 < 1 & chDiff2 < 10; % logical indexing: removes background; keeps cherries
%figure, imshow(I2,[]); impixelinfo;
% Fill the holes
I3 = imfill(I2,'holes');
% Remove small objects
I4 = bwareaopen(I3, 1500);
% Erode image
se = strel('disk',5);
I5 = imerode(I4,se);
figure, imshow(I5,[]); impixelinfo;
% Multiply binary 'Mask' by thermal image
I6 = immultiply(I5,W);
Z_LWS = I6;
% Display image
figure, h = pcolor(I6);
set(h, 'EdgeColor', 'none');
xticks([0:50:800]); yticks([0:50:600]);
axis ij 
m = colorbar; 
xlabel(m,'Temperature (Celsius)')
axis equal tight; colormap(jet);
% Calculate average temperature of leaves
n=0;
LWS_temp=0;
for c = 1:400
    for r = 1:300        
        if Z_LWS(r,c)>0
            n = n + 1; 
            LWS_temp = Z_LWS(r,c) + LWS_temp;
        end        
    end
end
LWS_temp = LWS_temp/n

%# Histogram of temperature frequency for whole image (Canopy)
figure('rend','painters','pos',[10 10 300 250]), h = histogram(W,'Orientation','horizontal','Normalization','probability');% Relative frequency
h.FaceColor = [1 0 0]; % or h.FaceColor = 'red'
h.BinEdges = [15:35];
h.BinWidth = 0.5;
xlabel('Relative Frequency');
ylabel('Temperature (Celsius)');
%title('Canopy')

% Histogram of All in one figure
%# Histogram of temperature frequency for leaves
figure
h = histogram(Z_leaves,'facealpha',.5,'Orientation','horizontal','Normalization','probability');% Relative frequency
h.BinEdges = [15:35];
h.BinWidth = 0.5;
hold on
%# Histogram of temperature frequency for cherries
h = histogram(Z_Cherries,'facealpha',.5,'Orientation','horizontal','Normalization','probability');% Relative frequency
h.BinEdges = [15:35];
h.BinWidth = 0.5;
%# Histogram of temperature frequency for LWS
h = histogram(Z_LWS,'facealpha',.5,'Orientation','horizontal','Normalization','probability');% Relative frequency
h.BinEdges = [15:35];
h.BinWidth = 0.5;
xlabel('Temperature (Celsius)');
ylabel('Relative Frequency');
legend('Leaves','Cherries','LWS','location','northwest');
hold off

%# Histogram of temperature frequency for cherries
figure, h = histogram(Z_Cherries,'facealpha',.5,'Orientation','horizontal','Normalization','probability');% Relative frequency
h.BinEdges = [15:35];
h.BinWidth = 0.5;
xlabel('Temperature (Celsius)');
ylabel('Relative Frequency');
title('Cherries')


