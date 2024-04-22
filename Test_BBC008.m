%% Human HT29 colon-cancer cells (BBBC008 v1)
% -------------------------------------------------------------------------
% Comparison of the Elen and Otsu methods for BBBC008.
%
% The imageset consists of 24 images. The samples were stained with
% Hoechst (channel 1), pH3 (channel 2), and phalloidin (channel 3). Hoechst
% labels DNA, which is present in the nucleus. Phalloidin labels actin,
% which is present in the cytoplasm. The last stain, pH3, indicates cells
% in mitosis; whereas this was important for Moffat et al.'s screen, it is
% irrelevant for segmentation and counting, so this channel is left out.
%
% Visit for more information:
% https://bbbc.broadinstitute.org/BBBC008
%
% Visit GitHub link below for test images
% https://github.com/abdullahelen/ElenThreshold
% -------------------------------------------------------------------------

clc;
clear;
close all;

% Get list of all TIF files in image directory.
imgOFiles = dir('Images/BBBC008_v1/Originals/*.tif');
imgOriginal = cell(length(imgOFiles), 1);
for i = 1 : length(imgOFiles)
   % Read i-th image from graphics file.
   currFile = fullfile(imgOFiles(i).folder, imgOFiles(i).name);
   img = imread(currFile);

   % Convert RGB image to grayscale.
   if (imfinfo(currFile).BitDepth > 8)
        img = rgb2gray(img);
   end

   imgOriginal{i} = img;
end


imgGFiles = dir('Images/BBBC008_v1/GroundTruth/*.tif');
imgGroundTruth = cell(length(imgGFiles), 1);
for i = 1 : length(imgGFiles)
    % Read i-th image from graphics file.
    currFile = fullfile(imgGFiles(i).folder, imgGFiles(i).name);
    if (imfinfo(currFile).BitDepth == 1)
        imgGroundTruth{i} = imread(currFile);
    end
end

% Check image counts.
if (length(imgOFiles) == length(imgGFiles))

    imgCount = length(imgOFiles);

    Similarities = table('Size', [imgCount, 2], ...
        'VariableTypes', {'double', 'double'}, ...
        'VariableNames', {'Elen', 'Otsu'});

    Thresholds = table('Size', [imgCount, 2], ...
        'VariableTypes', {'double', 'double'}, ...
        'VariableNames', {'Elen', 'Otsu'});

    ElapsedTimes = table('Size', [imgCount, 2], ...
        'VariableTypes', {'double', 'double'}, ...
        'VariableNames', {'Elen', 'Otsu'});

    tabResult = table('Size', [imgCount, 2], ...
        'VariableTypes', {'categorical', 'categorical'}, ...
        'VariableNames', { ...
            'ImageID', ...   % Image ID
            'Winner'         % Winner method
         });

    for i = 1 : imgCount
        % Get current original and ground-truth image.
        imgO = imgOriginal{i};
        imgG = imgGroundTruth{i};        
        
        %% OTSU'S THRESHOLDING METHOD
        tic;
        thresholdOtsu = graythresh(imgO) * 256.0;
        timeOtsu = toc * 1000; % in second
        % Binarize the image by thresholding.
        IbOtsu = imbinarize(imgO, thresholdOtsu / 256.0);

        %% ELEN'S THRESHOLDING METHOD
        tic;
        thresholdElen = ElenThreshold(imgO);
        timeElen = toc * 1000; % in second
        % Binarize the image by thresholding.
        IbElen = imbinarize(imgO, thresholdElen / 256.0);
        

        %% Structural similarity index for measuring image.
        [simElen, ~] = ssim(uint8(IbElen), uint8(imgG));
        [simOtsu, ~] = ssim(uint8(IbOtsu), uint8(imgG));

        % Insert results to the tabResult.
        methods = ["Elen", "Otsu"];
        [sMax, sI] = max([simElen, simOtsu]);
        winner = methods(sI);
        tabResult(i, :) = {['#', num2str(i)], winner};

        % Add similarity indices to the table.
        Similarities(i, :) = {simElen, simOtsu};

        % Add threshold values to the table.
        Thresholds(i, :) = {round(thresholdElen), round(thresholdOtsu)};

        % Add threshold values to the table.
        ElapsedTimes(i, :) = {timeElen, timeOtsu};
    end

    % Sum of winners.
    cElen = sum(tabResult.Winner == "Elen");
    cOtsu = sum(tabResult.Winner == "Otsu");

    % Display results.
    disp('<strong>Table 1.</strong> Comparison of the Elen and Otsu methods for Human HT29 colon-cancer cells.');
    disp(table(tabResult(:, 1), Thresholds, Similarities, ElapsedTimes, tabResult(:, 2)));

    disp('<strong>Result:</strong>');
    disp(['Out of <strong>', num2str(imgCount), '</strong> images in the dataset, ', ...
        '<strong>Elen''s method</strong> won <strong>', num2str(cElen), ...
        '</strong> and <strong>Otsu''s method</strong> won <strong>', ...
        num2str(cOtsu), '</strong>. In addition,']);
    disp(['total elapsed times of the Elen and Otsu in thresholding are ', ...
        '<strong>', num2str(sum(ElapsedTimes.Elen)), '</strong> and ', ...
        '<strong>', num2str(sum(ElapsedTimes.Otsu)), '</strong> seconds, respectively.']);
end
