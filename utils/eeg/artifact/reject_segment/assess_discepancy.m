% % % % % %  More advanced

%% Inspect data by eye

% Calculate the difference between consecutive time points in the EEG data
diffData = diff(EEG.data, 1, 2);

% Define a threshold for sharp increases or decreases
% You should adjust this value based on your specific data and requirements
threshold = 1000;

% Find the indices of the time points where the absolute difference is above the threshold
sharpChangeIndices = find(abs(diffData) > threshold);

% If there are any such time points
if ~isempty(sharpChangeIndices)
    % Find the start and end indices of the region of sharp change
    % In this case, we're considering the region to be the range from the first to the last time point with a sharp change
    % You might want to adjust this to better suit your specific data and requirements
    region = [sharpChangeIndices(1), sharpChangeIndices(end)];

    % Reject the region using eeg_eegrej
    % This will add a boundary event at the start of the rejected region
    EEG = eeg_eegrej(EEG, region);
end
