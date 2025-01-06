% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                           Run helpers                                   %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
fname = fetchScriptName; mkdir(fullfile(FIGURES,fname)); mkdir(fullfile(DATA,fname));
mkdir(fullfile(LOGS,fname)); called = manualOrCalled();
if called; startLogging(fullfile(LOGS, fname,'cli')); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Lowpass (optional)
do_lowpass = 1; % change here
if do_lowpass
EEG = pop_eegfiltnew(EEG, 'locutoff', [], 'hicutoff', 40, 'revfilt', 0, 'plotfreqz', 1);
figure; spec = pop_spectopo(EEG, 1, [], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 EEG.srate/2],'electrodes','on');
saveFigs(gcf, fullfile(FIGURES, fname),'lowpass_psd', false); close all;
end

%% Epoch data
EEG_ep = f_epoch_by_images(EEG, 0); % 1 -> remove baseline; 0 -> otherwise
EEG_ep = eeg_checkset(EEG_ep,'event');

%% Trial rejection
do_remove_trials = 1; % change here
if do_remove_trials
    try
    % Use trimOutliers(e.g. EEG = trimOutlier(EEG, 6, 12, 200, 50);)
    pop_trimOutlier(EEG,true);
    saveFigs(gcf, fullfile(FIGURES, fname),'vis_trimOutlier', false); close all; 
    catch; fprintf('Install trimOutlier...'); 
    end
    % Use the STFT
    [~, bad_trials_cov] = cov_zscore_clean(EEG_ep, 'time_window', [-200 1000], 'sliding', false, 'window_size', 500, 'step_size', 250, 'threshold', 2.3, 'channels', 1:257, 'plot', true);
    saveFigs(gcf, fullfile(FIGURES, fname),'cov_zscore_clean', false); close all;
    % Use Covariance Z-score
    bad_trials_spect = spectrogram_clean(EEG_ep, 'method', 'data', 'threshold', 3, 'freqband', [1 40]);
    saveFigs(gcf, fullfile(FIGURES, fname),'spectrogram_clean', false); close all;
    % Combine indices of trials to reject
    trials_to_reject = union(bad_trials_cov, bad_trials_spect);
    fprintf('Removing %d trials\n', length(trials_to_reject));
    fprintf('Trial numbers: %d\n', trials_to_reject)
    % Reject
    EEG_ep = pop_rejepoch(EEG_ep, trials_to_reject, 0); 
    save(fullfile(DATA, fname, 'rejected_trials'),'trials_to_reject')
end

%% Sort by conditions

% Choose sorting method
sort_by_cat            = 1; % more trials (more snr)
sort_by_beh            = 0; % bigger effect size (more unambiguous stimuli)
sort_by_ignoring_crowd = 0; % bigger effect size (remove confounding factor)
sort_by_sam            = 0; % bigger effect size (more emotional stimuli)

% Fetch condition indices
subid = strcat('sub-', info.process.sub);
t   = readtable([bidsroot filesep subid filesep 'eeg' filesep subid '_task-videorating_events.tsv'], 'FileType', 'text');
if do_remove_trials; t = t(~ismember(t.trial_number, trials_to_reject), :); end % remove information from rejected trials
stimuli             = {'DI11'};
str                 = string(t{:,4});
index_stimuli       = ismember(str, stimuli);
trl_imgonly         = t(index_stimuli, :);

% Compute sorting method
if sort_by_cat
n_ind               = startsWith(trl_imgonly.stim_file,'A') | startsWith(trl_imgonly.stim_file,'B');
u_ind               = startsWith(trl_imgonly.stim_file,'C') | startsWith(trl_imgonly.stim_file,'D');
c_ind               = startsWith(trl_imgonly.stim_file,'B') | startsWith(trl_imgonly.stim_file,'D');
nc_ind              = startsWith(trl_imgonly.stim_file,'A') | startsWith(trl_imgonly.stim_file,'C');
elseif sort_by_ignoring_crowd
n_ind               = startsWith(trl_imgonly.stim_file,'A');
u_ind               = startsWith(trl_imgonly.stim_file,'C');
c_ind               = startsWith(trl_imgonly.stim_file,'B') | startsWith(trl_imgonly.stim_file,'D');
nc_ind              = startsWith(trl_imgonly.stim_file,'A') | startsWith(trl_imgonly.stim_file,'C');
elseif sort_by_beh
load(fullfile(results,'behavioral','survey_videos_above_median.mat')) % T
n_ind               = ismember(trl_imgonly.stim_file, cellfun(@(x) strcat(x, '_video.avi'), T{:,"A"}, 'UniformOutput', false)) |...
                      ismember(trl_imgonly.stim_file, cellfun(@(x) strcat(x, '_video.avi'), T{:,"B"}, 'UniformOutput', false));
u_ind               = ismember(trl_imgonly.stim_file, cellfun(@(x) strcat(x, '_video.avi'), T{:,"C"}, 'UniformOutput', false)) |...
                      ismember(trl_imgonly.stim_file, cellfun(@(x) strcat(x, '_video.avi'), T{:,"D"}, 'UniformOutput', false));
c_ind               = ismember(trl_imgonly.stim_file, cellfun(@(x) strcat(x, '_video.avi'), T{:,"B"}, 'UniformOutput', false)) |...
                      ismember(trl_imgonly.stim_file, cellfun(@(x) strcat(x, '_video.avi'), T{:,"D"}, 'UniformOutput', false));
nc_ind              = ismember(trl_imgonly.stim_file, cellfun(@(x) strcat(x, '_video.avi'), T{:,"A"}, 'UniformOutput', false)) |...
                      ismember(trl_imgonly.stim_file, cellfun(@(x) strcat(x, '_video.avi'), T{:,"C"}, 'UniformOutput', false));
elseif sort_by_sam
% n_ind               = ( startsWith(trl_imgonly.stim_file,'A') | startsWith(trl_imgonly.stim_file,'B') ) && ( trl_imgonly.sam == 1 );
% u_ind               = startsWith(trl_imgonly.stim_file,'C') | startsWith(trl_imgonly.stim_file,'D');
end
% Filter conditions into new EEG sets
conds = {'n', n_ind; 'u', u_ind; 'c', c_ind; 'nc', nc_ind};
for i = 1:size(conds, 1)
    condEEG = EEG_ep;
    condEEG.epoch = EEG_ep.epoch(conds{i, 2});
    condEEG.data = EEG_ep.data(:, :, conds{i, 2});
    condEEG.trials = size(condEEG.data, 3);
    condEEG.event = EEG_ep.event(conds{i, 2});
    assignin('base', ['EEG_' conds{i, 1}], condEEG);
    eval(eeg_checkset(['EEG_' conds{i, 1}],'events'))
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
if called; stopLogging(); end %  s = what('Exp_2_Video\analysis')
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %