%% Histogram-based Global Thresholding
% -------------------------------------------------------------------------
% This study presents a novel and effective approach to global thresholding
% method of grayscale images. In the proposed method, alpha (α) and beta
% (β) regions are determined using the mean and standard deviation values
% of an image histogram. The optimum threshold value is obtained by
% calculating the average of gray-scale values of the α and β regions.
%
% Cite:
% Elen, A. & Dönmez, E. (2024). Histogram-based global thresholding method
% for image binarization, Optik, vol. 306, pp. 1-20.
% https://doi.org/10.1016/j.ijleo.2024.171814
%
% Contact:
% Department of Software Engineering, Faculty of Engineering and Natural
% Sciences, Bandirma Onyedi Eylul University, Balikesir / TURKIYE.
% aelen@bandirma.edu.tr, emrahdonmez@bandirma.edu.tr
% -------------------------------------------------------------------------

function result = ElenThreshold(img)
    % Histogram of the grayscale image.
    hst = imhist(img);

    % Set the histogram bins from 0 to 255.
    bins = (0 : 255)';
    % Probability of the histogram.
    prob = hst/sum(hst);
    % Mean value of the histogram.
    avg = sum(bins.*prob);
    % Standard deviation of the histogram.
    stdDev = sqrt(sum(((bins-avg).^2).*prob));


    % Alpha and Beta region variables.
    weightA = 0; pixelA = 0;
    weightB = 0; pixelB = 0;

    % Lower and upper bounds of the Alpha region.
    lbA = avg - stdDev;
    ubA = avg + stdDev;
    
    for i = 0 : 1 : 255
        % Get current bin location.
        binLoc = hst(i + 1);
        if (i >= lbA && i <= ubA)
            % Alpha region.
            weightA = weightA + binLoc;
            pixelA = pixelA + (i * binLoc);
        else
            % Beta region.
            weightB = weightB + binLoc;
            pixelB = pixelB + (i * binLoc);
        end
    end
    
    % Mean value of the Alpha region.
    avgA = (pixelA / weightA);

    % Mean value of the Beta region.
    avgB = (pixelB / weightB);
    
    % Threshold value.
    result = (avgA + avgB) / 2.0;
end
