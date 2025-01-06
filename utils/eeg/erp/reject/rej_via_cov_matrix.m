% Clean EEG Data by Removing Trials with High Covariance Distance
% This script computes the covariance distance of each trial to the average covariance matrix
% and removes trials that exceed a specified z-score threshold.

% Ensure that 'data' structure contains the necessary fields:
% data.eeg     - EEG data (channels x time points x trials)
% data.nbchan  - Number of channels
% data.trials  - Number of trials
% data.times   - Time vector
% data.srate   - Sampling rate

%% Helper function: Convert EEGLAB structure to custom structure
check2convert;

%% Compute Covariance Distance for Each Trial's SNR Time-Series

% Initialize vector to store covariance distances
covarianceDistances = zeros(data.trials, 1);

% Compute covariance distance for each trial
for trialIndex = 1:data.trials
    % Extract SNR time-series data for the current trial
    trialSNRData = squeeze(data.snr(:, :, trialIndex));

    % Compute covariance matrix for the current trial
    trialCovariance = cov(trialSNRData');

    % Compute Frobenius distance to the average covariance matrix
    distance = sqrt(sum((trialCovariance(:) - averageCovariance(:)).^2));
    covarianceDistances(trialIndex) = distance;
end

% Convert distances to z-scores
covarianceDistancesZ = (covarianceDistances - mean(covarianceDistances)) / std(covarianceDistances);

%% Visual Inspection of Covariance Distances

% Plot z-scored covariance distances
figure;
subplot(2, 2, 1);
plot(covarianceDistancesZ, 'ks-', 'LineWidth', 2, 'MarkerFaceColor', 'w', 'MarkerSize', 8);
xlabel('Trial');
ylabel('Z_{dist}');
title('Z-scored Covariance Distances (SNR Time-Series)');
grid on;

% Plot histogram of z-scored distances
subplot(2, 2, 2);
histogram(covarianceDistancesZ, 10);
xlabel('Z_{dist}');
ylabel('Count');
title('Histogram of Z-scored Distances');
grid on;

%% Identify and Remove Bad Trials

% Set z-score threshold for outlier detection (e.g., 2.3 corresponds to p ~ 0.01)
zScoreThreshold = 2.3;

% Identify trials exceeding the threshold
badTrialIndices = find(covarianceDistancesZ > zScoreThreshold);

% Display the number of trials identified as bad
fprintf('Number of trials identified as bad: %d out of %d\n', length(badTrialIndices), data.trials);

% Remove bad trials from the data
data.eeg(:, :, badTrialIndices) = [];
data.snr(:, :, badTrialIndices) = [];
data.trials = size(data.eeg, 3);

%% Compare SNR Time-Series Before and After Cleaning

% Select a channel to plot (e.g., channel 1)
channelToPlot = 1;

% Compute the mean SNR time-series before and after cleaning
meanSNROriginal = mean(data.snr(channelToPlot, :, :), 3);
meanSNRCleaned = mean(data.snr(channelToPlot, :, :), 3);

% Plot the SNR time-series
subplot(2, 2, [3, 4]);
hold on;
plot(data.snr_times, meanSNROriginal, 'k', 'LineWidth', 2);
plot(data.snr_times, meanSNRCleaned, 'r', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('SNR (dB)');
legend({'Original SNR', 'Cleaned SNR'});
title(sprintf('SNR Time-Series Before and After Cleaning (Channel %d)', channelToPlot));
grid on;
hold off;

%% Update Data Structure

% The 'data' structure now contains cleaned EEG and SNR data
% (Optional) Save the cleaned data structure
% save('cleaned_data.mat', 'data');