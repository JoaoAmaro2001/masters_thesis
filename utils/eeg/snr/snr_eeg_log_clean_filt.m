% References:
% Mavros, P., J Wälti, M., Nazemi, M., Ong, C. H., & Hölscher, C. (2022). A mobile EEG study on the psychophysiological effects of walking and crowding in indoor and outdoor urban environments. Scientific Reports, 12(1), Article 1. https://doi.org/10.1038/s41598-022-20649-y

function snr_matrix = snr_eeg_log_clean_filt(EEG_prepoc, EEG_filt)
    % snr_eeg_log_clean_filt - Compute SNR between clean and filtered EEG data
    %
    % Usage:
    %   >> snr_matrix = snr_eeg_log_clean_filt(EEG_prepoc, EEG_filt)
    %
    % Inputs:
    %   EEG_prepoc - Clean EEG data structure (custom format or EEGLAB EEG structure)
    %   EEG_filt  - Filtered EEG data structure (custom format or EEGLAB EEG structure)
    %
    % Outputs:
    %   snr_matrix - Matrix of SNR values in dB (channels x time points)
    %
    % Notes:
    %   - This function computes the SNR in dB for each channel and time point.
    %   - It supports both your custom EEG structure and EEGLAB EEG structures.
    
    % Convert inputs to custom format if necessary
    EEG_prepoc = eeglab2custom(EEG_prepoc);
    EEG_filt  = eeglab2custom(EEG_filt);

    % Check that inputs have matching dimensions
    assert(size(EEG_prepoc.data,3) == size(EEG_filt.data,3), ...
        'Data dimensions do not match between clean and filtered EEG data');
    
    if size(EEG_prepoc.data, 3) > 1
        % Compute SNR for each channel
        snr_matrix = zeros(size(EEG_prepoc.data, 1), size(EEG_prepoc.data, 2), size(EEG_prepoc.data, 3));
        % Loop across trials
        for triali = 1:size(EEG_prepoc.data, 3)
            % Compute signal power and noise power
            signal_power = EEG_prepoc.data(:, :, triali) .^ 2;
            noise_power  = (EEG_filt.data(:, :, triali) - EEG_prepoc.data(:, :, triali)) .^ 2;

            % Add small epsilon to avoid division by zero
            epsilon = 1e-10;
            snr_matrix(:, :, triali) = 10 * log10(signal_power ./ (noise_power + epsilon));
        end
        

        % Plot the SNR across time for each channel using 3d plot
        time_axis = EEG_prepoc.times;
        figure;
        surf(time_axis, 1:size(snr_matrix, 1), snr_matrix);
        xlabel('Time (s)');
        ylabel('Channel');
        zlabel('SNR (dB)');
        title('SNR Across Time for Each Channel');
        
    else
        % Compute SNR for all channels
        % Compute signal power and noise power
        signal_power = EEG_prepoc.data .^ 2;
        noise_power  = (EEG_filt.data - EEG_prepoc.data) .^ 2;

        % Add small epsilon to avoid division by zero
        epsilon = 1e-10;
        snr_matrix = 10 * log10(signal_power ./ (noise_power + epsilon));

        % Plot the SNR across time for all channels
        time_axis = EEG_prepoc.times;
        figure;
        plot(time_axis, snr_matrix');
        xlabel('Time (s)');
        ylabel('SNR (dB)');
        title('SNR Across Time for All Channels');
        legend(arrayfun(@(x) sprintf('Ch %d', x), 1:size(snr_matrix, 1), 'UniformOutput', false));

    end

end

