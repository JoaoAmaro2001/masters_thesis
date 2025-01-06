function [df_eeg, ft_data] = fieldtrip2custom(ft_data)
    % fieldtrip2custom - Convert FieldTrip data structure to custom EEG structure
    %
    % Usage:
    %   >> df_eeg = fieldtrip2custom(ft_data)
    %
    % Inputs:
    %   ft_data   - FieldTrip data structure (raw or epoched)
    %
    % Outputs:
    %   df_eeg - Custom EEG structure
    
    % Initialize df_eeg structure
    df_eeg = struct();

    % Check if data is continuous or epoched
    if isfield(ft_data, 'trial') && iscell(ft_data.trial)
        % Epoched data
        num_trials = length(ft_data.trial);
        df_eeg.trials = num_trials;
        df_eeg.nbchan = size(ft_data.trial{1}, 1);
        df_eeg.pnts   = length(ft_data.time{1});
        
        % Concatenate trials into a 3D matrix
        data = zeros(df_eeg.nbchan, df_eeg.pnts, num_trials);
        for i = 1:num_trials
            data(:, :, i) = ft_data.trial{i};
        end
        df_eeg.data = data;
        df_eeg.times = ft_data.time{1};
    else
        % Continuous data
        df_eeg.trials = 1;
        df_eeg.data   = ft_data.trial{1};
        df_eeg.nbchan = size(df_eeg.data, 1);
        df_eeg.pnts   = size(df_eeg.data, 2);
        df_eeg.times  = ft_data.time{1};
    end

    % Sampling rate
    df_eeg.srate = ft_data.fsample;

    % Channel information
    if isfield(ft_data, 'label')
        % Create a chanlocs structure similar to EEGLAB
        df_eeg.chanlocs = struct('labels', ft_data.label);
    else
        df_eeg.chanlocs = [];
    end

    % Event and epoch information
    if isfield(ft_data, 'trialinfo')
        % FieldTrip stores trial info separately
        df_eeg.epoch = ft_data.trialinfo;
    else
        df_eeg.epoch = [];
    end

    % Event information (FieldTrip events are in cfg)
    if isfield(ft_data, 'cfg') && isfield(ft_data.cfg, 'event')
        df_eeg.event = ft_data.cfg.event;
    else
        df_eeg.event = [];
    end

    % Additional metadata (optional)
    df_eeg.metadata = struct();
    if isfield(ft_data, 'cfg')
        df_eeg.metadata.cfg = ft_data.cfg;
    end

    % Ensure times are in seconds
    if max(df_eeg.times) > 1000
        df_eeg.times = df_eeg.times / 1000;
        fprintf('Converted times from milliseconds to seconds.\n');
    end

    % Convert data to double precision
    df_eeg.data = double(df_eeg.data);
end
    