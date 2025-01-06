function should_epoch_for_ica(df, epoch_win, event_stim)
% Function requires custom schema for EEG data structure.
% Do it by running the following code:
% df = check2convert(EEG);
% This script checks whether you have sufficient data points after epoching
% to perform ICA and whether your Stimulus Onset Asynchrony (SOA) is appropriate.
% It outputs recommendations on whether to epoch the data before ICA or not.
% Recommendations given by Makoto Miyakoshi.

% Parse the input arguments
if nargin < 3
    error('Usage: should_epoch_for_ica(df, epoch_win, event_stim)');
end



% Get the number of channels
num_channels = df.nbchan;

% Calculate required number of data points
required_data_points = (num_channels^2) * 30;

% Define the epoch time range (e.g., -1 to 2 seconds)
epoch_start = epoch_win(1); % in seconds
epoch_end = epoch_win(2);    % in seconds

% Get the sampling rate
fs = df.srate;

% Calculate the number of data points per epoch
data_points_per_epoch = (epoch_end - epoch_start) * fs;

% Define the event types of interest (adjust according to your data)
event_types = {event_stim}; % Replace 'Stimulus' with your event type(s)

% Find indices of events of interest
event_indices = find(ismember({df.event.type}, event_types));

% Number of epochs
num_epochs = length(event_indices);

% Total data points after epoching
total_data_points = num_epochs * data_points_per_epoch;

% Output the calculation results
fprintf('Number of channels: %d\n', num_channels);
fprintf('Required data points for ICA: %d\n', required_data_points);
fprintf('Data points per epoch (fs = %d): %d\n', fs, data_points_per_epoch);
fprintf('Number of epochs: %d\n', num_epochs);
fprintf('Total data points after epoching: %d\n', total_data_points);

% Check if total data points after epoching is sufficient
if total_data_points >= required_data_points
    fprintf('\nSufficient data points after epoching (%d >= %d).\n', total_data_points, required_data_points);
    epoching_recommendation = 'You can epoch the data before ICA.';
else
    fprintf('\nInsufficient data points after epoching (%d < %d).\n', total_data_points, required_data_points);
    epoching_recommendation = 'It is recommended to perform ICA on continuous data, then epoch.';
end

% Check the Stimulus Onset Asynchrony (SOA)

% Get the latencies of the events (in data points)
event_latencies = [df.event(event_indices).latency];

% Convert latencies to times in seconds
event_times = event_latencies / fs;

% Calculate SOAs (differences between consecutive events)
SOAs = diff(event_times);

% Output SOA information
if isempty(SOAs)
    fprintf('Not enough events to calculate SOA.\n');
else
    fprintf('Average SOA: %.2f seconds\n', mean(SOAs));
    fprintf('Minimum SOA: %.2f seconds\n', min(SOAs));
    
    % Check if any SOA is less than 3 seconds
    if any(SOAs < 3)
        fprintf('\nSome Stimulus Onset Asynchronies (SOAs) are shorter than 3 seconds.\n');
        soa_recommendation = 'It is recommended to perform ICA on continuous data, then epoch.';
    else
        fprintf('\nAll SOAs are at least 3 seconds.\n');
        soa_recommendation = 'SOA is sufficient for epoching before ICA.';
    end
end

% Based on both checks, make a recommendation
fprintf('\nRecommendation:\n');
if total_data_points >= required_data_points && (~isempty(SOAs) && all(SOAs >= 3))
    fprintf('Based on data points and SOA, you can epoch before ICA.\n');
else
    fprintf('Based on data points and/or SOA, it is recommended to perform ICA on continuous data, then epoch.\n');
end

% Output specific recommendations
fprintf('\n%s\n', epoching_recommendation);
if exist('soa_recommendation', 'var')
    fprintf('%s\n', soa_recommendation);
end

% Additional notes:
fprintf('\nAdditional Notes:\n');
fprintf('- Ensure that the data has been high-pass filtered properly (e.g., above 1 Hz).\n');
fprintf('- Do not perform baseline correction before ICA.\n');
fprintf('- Use an epoch length of -1 to 2 seconds for later wavelet transform analysis.\n');
