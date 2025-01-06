% filepath: /C:/Users/joaop/git/JoaoAmaro2001/WorkRepo/GeneralPurposeFunctions/EEG/snr/snr_var_over_baseline.m

function snr_matrix = snr_var_over_baseline(df)
    % snr_var_over_baseline - Compute SNR using mean and std over trials
    %
    % Usage:
    %   >> snr_matrix = snr_var_over_baseline(EEG_data)
    %
    % Inputs:
    %   EEG_data - EEG data structure with fields:
    %              data: [channels x time points x trials]
    %
    % Outputs:
    %   snr_matrix - Matrix of SNR values (channels x time points)
    
    % Compute mean over trials
    mean_data = mean(df.data, 3);
    
    % Compute standard deviation over trials
    std_data = std(df.data, 0, 3);
    
    % Avoid division by zero
    epsilon = 1e-10;
    
    % Compute SNR
    snr_matrix = mean_data ./ (std_data + epsilon);
    
    % Optionally, plot the SNR across time for all channels
    % time_axis = EEG_data.times;
    % figure;
    % plot(time_axis, snr_matrix');
    % xlabel('Time (s)');
    % ylabel('SNR');
    % title('SNR Across Time for All Channels');
    % legend(arrayfun(@(x) sprintf('Ch %d', x), 1:size(snr_matrix, 1), 'UniformOutput', false));
end