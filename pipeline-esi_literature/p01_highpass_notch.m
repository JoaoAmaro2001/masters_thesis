% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
fname = fetchScriptName; mkdir(fullfile(FIGURES, fname)); mkdir(fullfile(LOGS, fname));
mkdir(fullfile(DATA, fname)); called = manualOrCalled(); 
if called; startLogging(fullfile(LOGS, fname,'cli')); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Choose correct EEG struct
if strcmpi(info.specific.run,'run-1')
    EEG = EEG_run1;
elseif strcmpi(info.specific.run,'run-2')
    EEG = EEG_run2;
else
    EEG = EEG_merged;
end
[EEG.event.type] = EEG.event.code; % requires type field

%% High-pass filter with butterworth (requires Fieldtrip)

% Choose the filter
if strcmpi(mcfg.filter.filttype,'butter')
    EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff', [1 30],...
    'Design', 'butter', 'Filter', 'bandpass', 'Order',  2,...
    'RemoveDC', 'on', 'History', 'script');
elseif strcmpi(mcfg.filter.filttype,'fir1')
    % high-pass filter
    if strcmpi(info.specific.run,'run-1')    
    EEG = pop_eegfilt(EEG_run1,  mcfg.filter.highpass.cutoff, 0, [], 0, 0, 1, 'fir1', 0);
    else
    EEG = pop_eegfilt(EEG_run2,  mcfg.filter.highpass.cutoff, 0, [], 0, 0, 1, 'fir1', 0);
    end
    saveFigs(gcf,fullfile(FIGURES,fname),strcat(mcfg.filter.filttype,'filter')); close all;
    % notch filter
    EEG = pop_zapline_plus(EEG, 'noisefreqs','line','coarseFreqDetectPowerDiff',4,'chunkLength',0,'adaptiveNremove',1,'fixedNremove',1);
    EEG = pop_zapline_plus(EEG, 'noisefreqs','line','coarseFreqDetectPowerDiff',4,'chunkLength',0,'adaptiveNremove',1,'fixedNremove',1);
    % Save figures
    figHandles = findall(groot, 'Type', 'Figure');
    for idx = 1:length(figHandles)
        h = figHandles(idx);
        figname = get(h, 'Name');
        saveFigs(h, fullfile(FIGURES,fname), ['notchfilter_' num2str(idx)], false);
    end
    close all;
elseif strcmpi(mcfg.filter.filttype,'butter_ft') 
    data_ft = eeglab2fieldtrip(EEG, 'raw');
    cfg = [];
    cfg.demean = 'yes';  % Optional: remove mean
    cfg.bpfilter = 'high'; % Enable bandpass filtering
    cfg.bpfreq = 1;  % Define frequency range, e.g., 1-30 Hz
    cfg.bpfiltord = 2;    % Set filter order to 2 for second-order
    data_filtered = ft_preprocessing(cfg, data_ft);
    % EEG_filt = fieldtrip2eeglab(data_filtered)
    EEG_filt = EEG;
    EEG_filt.data = data_filtered.trial{:};
end

% Save --------------------------------------------------------------------
% saveFigs(gcf,fullfile(FIGURES,fname),'highpass_filter'); close all;
text_info = sprintf('High-pass filter applied. Butterworth filter of 2nd order. Bandpass lower-edge frequency of %d Hz', mcfg.filter.highpass.cutoff);
EEG.etc.filter.type = text_info;
text2struct(mcfg, 'filter.type', text_info)
% -------------------------------------------------------------------------                        

if ~called

% Get filtered signal
[EEG_filt.event.type] = EEG.event.trial_type; % requires type field

% Inspect time domain
eegplot(EEG_filt.data, 'winlength', 30, 'dispchans', 30, 'events', EEG.event, 'ploteventdur', 'on')
close all

% Global PSD
figure;
pop_spectopo(EEG, 1, [], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 EEG.srate/2],'electrodes','on');
saveFigs(gcf,fullfile(FIGURES,fname),'psd_global'); close all

% Go over each channel
for chan = 1:15:EEG.nbchan
    % [com_original] = pop_prop(EEG, 1, chan, NaN, {'freqrange', [1 60]}); 
    [com_filtered] = pop_prop(EEG_filt, 1, chan, NaN, {'freqrange', [1 EEG.srate/2]});
    % saveFigs(gcf,fullfile(FIGURES,fname),'individual_ics')
end
close all

% Visualize artifacts
try
vis_artifacts(EEG_filt, EEG, 'channel_subset', {EEG.chanlocs.labels}, 'EqualizeChannelScaling', true);
% fig2movie(gcf,fullfile(FIGURES,fname),'clean_artifacts',30,300)
% saveFigs(gcf,fullfile(FIGURES,fname),'clean_artifacts', false)
catch
end

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
if called; stopLogging(); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %