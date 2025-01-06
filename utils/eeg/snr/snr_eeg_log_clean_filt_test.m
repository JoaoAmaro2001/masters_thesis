% References:
% Mavros, P., J Wälti, M., Nazemi, M., Ong, C. H., & Hölscher, C. (2022). A mobile EEG study on the psychophysiological effects of walking and crowding in indoor and outdoor urban environments. Scientific Reports, 12(1), Article 1. https://doi.org/10.1038/s41598-022-20649-y


% Helper - conversion
check2convert;

% Initialize SNR matrix
snr_matrix             = zeros(size(data.eeg, 1), size(data.eeg, 2));

% Compute SNR for each channel
for ch                 = 1:size(data.eeg, 1)
    
    % Clean EEG and Filtered EEG for each channel
    clean_eeg          = data.eeg(ch, :);  % clean EEG
    filt_eeg           = EEG_filt.data(ch, :);  % filtered EEG
    % Compute power of clean EEG squared and noise squared
    clean_eeg_power_sq = clean_eeg.^2;
    noise_sq           = (filt_eeg - clean_eeg).^2;
    % Compute SNR in dB
    snr                = 10*log10(clean_eeg_power_sq ./ noise_sq);
    % Store SNR for the channel
    snr_matrix(ch, :)  = snr;

end

% Text output
for ch                 = 1:size(snr_matrix, 1)
    fprintf(fid, 'Channel %d SNR: %s\n', ch, mat2str(snr_matrix(ch, :)));
end

% Plot SNR across time for all channels
figure(1);
time_axis              = (1:size(snr_matrix, 2)) / data.srate; % create time axis based on sampling rate
plot(time_axis, snr_matrix');
xlabel('Time (s)');
ylabel('SNR (dB)');
title('SNR Across Time for All Channels');
legend(arrayfun(@(x) sprintf('Ch %d', x), 1:size(snr_matrix, 1), 'UniformOutput', false));

function plot_snr_covariance(data)

    if data.ndims==3
        covarianceDistances = zeros(data.trials, 1);
        for trialIndex = 1:data.snr
            % Extract SNR time-series data for the current trial
            trialSNRData = squeeze(data.snr(:, :, trialIndex));
            % Compute covariance matrix for the current trial
            trialCovariance = cov(trialSNRData');
            % Compute Frobenius distance to the average covariance matrix
            distance = sqrt(sum((trialCovariance(:) - averageCovariance(:)).^2));
            covarianceDistances(trialIndex) = distance;
        end

    elseif data.ndims==2
        covarianceDistances = zeros(data.snr, 1);
        for trialIndex = 1:data.snr
            % Compute covariance matrix for the current trial
            trialCovariance = cov(data.snr');
            % Compute Frobenius distance to the average covariance matrix
            distance = sqrt(sum((trialCovariance(:) - averageCovariance(:)).^2));
            covarianceDistances(trialIndex) = distance;
        end
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
    fprintf('Number of trials identified as bad: %d out of %d\n', length(badTrialIndices), data.snr);

    % Remove bad trials from the data
    data.eeg(:, :, badTrialIndices) = [];
    data.snr(:, :, badTrialIndices) = [];
    data.snr = size(data.eeg, 3);

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


end

