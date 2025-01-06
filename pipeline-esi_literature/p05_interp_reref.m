% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
fname = fetchScriptName; mkdir(fullfile(FIGURES, fname)); mkdir(fullfile(LOGS, fname));
mkdir(fullfile(DATA, fname)); called = manualOrCalled(); 
if called; startLogging(fullfile(LOGS, fname,'cli')); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% Low pass filter
% EEG = pop_eegfiltnew(EEG, 'locutoff', [], 'hicutoff', 40, 'revfilt', 0, 'plotfreqz', 1);

% Interpolate only channels removed during artifact rejection
EEG = pop_interp(EEG, EEG.urchanlocs(1:256), 'spherical');

% Add reference back as zeroed out channel
EEG.nbchan = EEG.nbchan + 1;
EEG.chanlocs = EEG.urchanlocs(1:EEG.nbchan);
zero_data = zeros(1, EEG.pnts);
EEG.data(end+1, :) = zero_data; 
EEG = eeg_checkset(EEG);

% Rereference to common average
EEG = pop_reref(EEG, []);

% Save Dataset
bids_fname = strcat('sub-',info.subjects{index_sub}, '_ses-',info.sessions{index_ses}, '_task-',info.tasks{index_tsk}, '_eeg.set');
EEG = pop_saveset(EEG, 'filename', bids_fname, 'filepath', fullfile(DATA,fname));

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
stopLogging();
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %