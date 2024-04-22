%% Histogram-based global thresholding
% Elen, A. & Dönmez, E., Histogram-based global thresholding method for
% image binarization, Optik, vol. 306, pp. 1-20 (2024).
% https://doi.org/10.1016/j.ijleo.2024.171814
%
% Visit GitHub link below for test images
% https://github.com/abdullahelen/ElenThreshold
% -------------------------------------------------------------------------

clc;
clear;
close all;

%% Section 1: Get image.
% Set full path to the image.
imgFile = 'Images\Test.gif';
% Read image data.
img = imread(imgFile);
% Convert RGB image to grayscale, if need.
if (imfinfo(imgFile).BitDepth > 8)
    img = rgb2gray(img);
end

%% Section 2: Run method.
thresholdElen = ElenThreshold(img);

% Binarize the image by threshold value.
binImg = imbinarize(img, thresholdElen / 256.0);


%% Section 3: Show result.
fig = figure();
sgtitle('Elen''s Thresholding Method.');

subplot(1, 2, 1);
imshow(img);
title('Input Image');

subplot(1, 2, 2);
imshow(binImg);
title('Output Image');

