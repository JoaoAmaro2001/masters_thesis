% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Run Helpers
setpath_exp2; % setpath
config_exp2;  % general config

% Stufy info
study = struct();
study.dataset_description.short = 'exp2';
study.path.scripts = fullfile(scripts, 'Exp_2_Video');
study.path.pipeline = 'pipeline-esi_literature';
study.path.specific = fullfile(study.path.scripts,'pipeline',study.path.pipeline);

% run pipeline config
cd(study.path.specific)
config_pip_esi_literature; 
cd(scripts)

% Utils
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
fname = fetchScriptName; mkdir(fullfile(LOGS,fname));
mkdir(fullfile(FIGURES,fname)); called = manualOrCalled();
if called; startLogging(fullfile(LOGS, fname,'cli')); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Load MFF and merge

% Define folder and file extension
eeglab nogui
folder2fetch = fullfile(sourcedata, 'data', info.specific.sub(5:end));
file_ext = '*.mff';

% Search for part one and part two files
mff_files = dir(fullfile(folder2fetch, file_ext));
run1_file = mff_files(find(contains({mff_files.name}, 'p1'), 1));
run2_file = mff_files(find(contains({mff_files.name}, 'p2'), 1));

% Ensure both files are available
if isempty(run1_file) || isempty(run2_file)
    error('Missing one or both parts of the EEG data (p1 or p2).');
end

% Load part one and part two files
fpath1 = fullfile(run1_file.folder, run1_file.name);
fpath2 = fullfile(run2_file.folder, run2_file.name);

EEG_run1 = pop_mffimport(fpath1,{'code','description','label','mffkey_cidx','mffkey_gidx','mffkeys','mffkeysbackup','name','relativebegintime','sourcedevice','tracktype'},0,0);
EEG_run2 = pop_mffimport(fpath2,{'code','description','label','mffkey_cidx','mffkey_gidx','mffkeys','mffkeysbackup','name','relativebegintime','sourcedevice','tracktype'},0,0);

% Check and process EEG data
EEG_run1 = eeg_checkset(EEG_run1);
EEG_run2 = eeg_checkset(EEG_run2);

% Concatenate and check dataset
EEG_merged = pop_mergeset(EEG_run1, EEG_run2);
EEG_merged = eeg_checkset(EEG_merged);

% -------------------------------------------------------------------------
% Assert conditions for EEGLAB
EEG = EEG_merged;
[EEG.event.type] = EEG.event.code;
EEG.chanlocs(257).labels = 'E257';
EEG.data = double(EEG.data);
% -------------------------------------------------------------------------

% Quick check of merged EEG freqs (merged files are corrupted!)
figure;
pop_spectopo(EEG_merged, 1, [], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 EEG_merged.srate/2],'electrodes','on');
saveFigs(gcf, fullfile(FIGURES,fname), 'psd_merged', false); close all

%% Manual Inspection

if ~called
    
% Quickly check data (epoch if necessary)    
EEG = pop_resample(EEG , mcfg.resample);
EEG = pop_eegfiltnew(EEG, 'locutoff', mcfg.filter.highpass.cutoff, 'hicutoff', mcfg.filter.lowpass.cutoff, 'revfilt', 0, 'plotfreqz', 1);
% Quick look at data
eegplot(EEG.data, 'winlength', 30, 'dispchans', 30, 'events', EEG.event, 'ploteventdur', 'on')
pop_eegbrowser(EEG,1); % use this plugin for quick event visualization
% Quick check of freqs
figure;
spec = pop_spectopo(EEG, 1, [], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 EEG.srate/2],'electrodes','on');
close all
% Check with trimOutlier (removing data: EEG = trimOutlier(EEG, 0, 10000, 10000, 100))
EEG = pop_trimOutlier(EEG,1); % slightly modified version for plotting only
saveFigs(gcf, fullfile(FIGURES, fname), 'trimOutlier_vis', false); close all;
% Check wether you should epoch before ICA
df_eeg = check2convert(EEG);
should_epoch_for_ica(df_eeg, [-1 1], 'DI11');
clear df_eeg
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
stopLogging();
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %