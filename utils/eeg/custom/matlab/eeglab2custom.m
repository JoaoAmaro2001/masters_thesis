function [df_eeg, EEG] = eeglab2custom(EEG)
    % eeglab2custom - Convert EEGLAB EEG structure to custom EEG structure
    %
    % Usage:
    %   >> df_eeg = eeglab2custom(EEG)
    %
    % Inputs:
    %   EEG       - EEGLAB EEG structure
    %
    % Outputs:
    %   df_eeg - Custom EEG structure
    
    % Initialize df_eeg structure
    df_eeg = struct();

    % Data conversion
    df_eeg.data     = double(EEG.data);
    df_eeg.nbchan   = EEG.nbchan;
    df_eeg.srate    = EEG.srate;
    df_eeg.pnts     = EEG.pnts;
    df_eeg.trials   = EEG.trials;
    df_eeg.times    = EEG.times;
    df_eeg.chanlocs = EEG.chanlocs;
    df_eeg.event    = EEG.event;

    % Epoch information (if available)
    if isfield(EEG, 'epoch')
        df_eeg.epoch = EEG.epoch;
    else
        df_eeg.epoch = [];
    end
    
    % Additional info
    df_eeg.etc = struct();
    
    % Additional metadata (optional)
    df_eeg.etc.metadata = struct();
    df_eeg.etc.metadata.comments = EEG.comments;
    df_eeg.etc.metadata.history  = EEG.history;

end
    