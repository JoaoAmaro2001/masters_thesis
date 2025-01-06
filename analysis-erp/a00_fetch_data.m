% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                           Run helpers                                   %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% study config
config_exp2;

% analysis config
cd(fullfile(study.path.analysis, 'analysis-erp'))
config_ana_erp; 
cd(scripts)

% output helpers
fname = fetchScriptName; called = manualOrCalled();
mkdir(fullfile(FIGURES,fname));mkdir(fullfile(DATA,fname));mkdir(fullfile(LOGS,fname));
if called; startLogging(fullfile(LOGS, fname,'cli')); end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                             Script                                      %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Get the data from derivatives (in runs)
eeglab nogui
for runidx=1:2
folder2fetch = fullfile(derivatives, info.pip_name, info.specific.sub, strcat('run-',num2str(runidx)), 'data', 'p06_spatial_filter.m');
file_ext   = '*.set';
set_files  = dir(fullfile(folder2fetch, file_ext));
fpath      = fullfile(set_files(1).folder, set_files(1).name);
if runidx == 1
ALLEEG     = pop_loadset(fpath);
[ALLEEG.event.type] = ALLEEG.event.code; % requires type field
else
ALLEEG(runidx) = pop_loadset(fpath);
[ALLEEG(runidx).event.type] = ALLEEG(runidx).event.code; % requires type field
end
end
EEG = pop_mergeset(ALLEEG(1), ALLEEG(2), 0);
% -------------------------------------------------------------------------
% Assert EEGLAB info
EEG = pop_chanedit(EEG,'nosedir','+Y'); % Otherwise plots will be rotated
EEG.chanlocs(257).labels = 'E257'; % Label can sometimes be 'E1001'
EEG.data = double(EEG.data);
% -------------------------------------------------------------------------

% Inspect
if ~called
figure;
pop_spectopo(EEG, 1, [], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 EEG.srate/2],'electrodes','on');
saveFigs(gcf, fullfile(FIGURES, fname),'merged_psd', false); close all;
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                            Wrapping up                                  %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% End log
if called; stopLogging(); end