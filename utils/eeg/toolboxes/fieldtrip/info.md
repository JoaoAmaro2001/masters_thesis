% The cfg structure

%% Temporal Filtering

```matlab
% Set channels
cfg.channel             = 'all';        % only the EEG channels
cfg.method              = 'channel';    % filter by channel, not by trial
% Baseline-correction options (highpass and lowpass)
cfg.prepoc.hpfilter     = 'yes';  % band-pass filtering
cfg.hpfilttype          = 'but';  % butterworth
cfg.hpfiltwintype       = 'hann'; 
cfg.hpfreq              = 0.5;    % filter between 1-40 Hz
cfg.demean              = 'yes';
cfg.detrend             = 'yes';
cfg.dftfilter           = 'yes';  % These are removed -> [50 100 150]
cfg.bpfilttype          = 'but';  % butterworth
cfg.lpfilter            = 'yes';  % band-pass filtering
cfg.lpfilttype          = 'but';  % butterworth
cfg.lpfiltwintype       = 'hann'; 
cfg.lpfreq              = 40;     % filter between 1-40 Hz
cfg.demean              = 'yes';
cfg.detrend             = 'yes';
cfg.dftfilter           = 'yes';  % These are removed -> [50 100 150]
cfg.bpfilttype          = 'but';  % butterworth
cfg.plotfiltresp        = 'yes';
data                    = ft_preprocessing(cfg);
```