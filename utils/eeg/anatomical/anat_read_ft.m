%% How to obtain anatomical labels using Fieldtrip

% Set path to Fieldtrip's AAL library.
% addpath('C:\Users\joaoa\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\FieldTrip\fieldtrip-master-02000301')
ft_defaults
 
% Obtain the Automated Anatomical Label (AAL) library (Tzourio-Mazoyer et al., 2002)
aal = ft_read_atlas('C:\Users\joaoa\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\FieldTrip\template\atlas\aal\ROI_MNI_V4.nii');
 
% Obtain the current IC-dipole xyz (need to run dipfit)
currentXyz = EEG.dipfit.model(1).posxyz; % For the IC1.
inputData = currentXyz;
 
% Transform the current xyz into the specified format.
aalCoordinates = round([(inputData(1)-aal.transform(1,4))/aal.transform(1,1) ...
    (inputData(2)-aal.transform(2,4))/aal.transform(2,2) ...
    (inputData(3)-aal.transform(3,4))/aal.transform(3,3)]);
aal.transform*[aalCoordinates(1);aalCoordinates(2);aalCoordinates(3);1]; % For a validation.
 
% Find the 10 closest ROIs.
uniqueROIs = unique(aal.tissue(:));
minDistVector = zeros(length(uniqueROIs)-1,1);
for uniqueRoiIdx = 1:length(minDistVector) % 0 is outside the brain.
    currentRoiMask   = aal.tissue == uniqueRoiIdx;
    currentRoiMask1D = find(currentRoiMask(:));
    [X,Y,Z] = ind2sub(size(aal.tissue), currentRoiMask1D);
    distVec = sqrt(sum(bsxfun(@minus, [X Y Z], [aalCoordinates(1), aalCoordinates(2), aalCoordinates(3)]).^2, 2));
    minDistVector(uniqueRoiIdx) = min(distVec);
end
[sortedDist, sortingIdx] = sort(minDistVector);
brainIcAnatomicalLabels    = aal.tissuelabel(sortingIdx(1:10))';
brainIcAnatomicalDistances = sortedDist(1:10)*mean([abs(aal.transform(1,1)) abs(aal.transform(2,2)) abs(aal.transform(3,3))]); 
 
% Add the info as a title.
title(sprintf('%s (%.1fmm)\n%s (%.1fmm)\n%s (%.1fmm)', brainIcAnatomicalLabels{1}, brainIcAnatomicalDistances(1), brainIcAnatomicalLabels{2}, brainIcAnatomicalDistances(2), brainIcAnatomicalLabels{3}, brainIcAnatomicalDistances(3)), 'interpreter', 'none')