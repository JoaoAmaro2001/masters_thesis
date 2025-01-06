% Script description:
% Defines configurations for the specific pipeline/analysis
% Everything between percent-rows should not be changed
% Author: João Amaro, FMUL, 2024/12/05

%% Pipeline and analysis info
info.pip_name = 'pipeline-esi_literature'; % change here the pipeline name
info.ana_name = 'analysis_erp'; % change here the analysis name

%% Check inputs -----------------------------------------------------------
sub_default = 'NSNP808';     % Change here the subject
ses_default = '';            % Change here the session
run_default = '';            % Change here the run
tsk_default = 'videorating'; % Change here the task
% -------------------------------------------------------------------------

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                           Do not change                                 %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% Ensure 'info' and 'info.process' exist
if ~exist('info', 'var') || ~isstruct(info)
    info = struct();
end
if ~isfield(info, 'process') || ~isstruct(info.process)
    info.process = struct();
end

% Define the fields and their default values
bids_fields = {'sub', 'ses', 'run', 'tsk'};
defaults = {sub_default, ses_default, run_default, tsk_default};
for i = 1:numel(bids_fields)
    fieldName = bids_fields{i};
    defaultValue = defaults{i};
    if ~isfield(info.process, fieldName) || isempty(info.process.(fieldName))
        info.process.(fieldName) = defaultValue;
    end
end

%% Fetch subject data
index_sub          = strcmpi(info.subjects,info.process.sub);
index_ses          = strcmpi(info.sessions,info.process.ses); 
index_run          = strcmpi(info.runs,info.process.run);          
index_tsk          = strcmpi(info.tasks,info.process.tsk); 
% Populate info structure
info.specific.sub  = strcat('sub-',info.subjects{index_sub});
if ~any(index_ses) 
info.specific.ses = ''; 
else 
info.specific.ses = strcat('ses-',info.sessions{index_ses});
end
if ~any(index_run)
info.specific.run = ''; 
else
info.specific.run  = strcat('run-',info.runs{index_run});
end
info.specific.task = info.tasks{index_tsk};

%% Create directories
RESULTS         = fullfile(results, strcat(info.ana_name,'_',info.pip_name)); mkdir(RESULTS);
GROUP           = fullfile(RESULTS, 'group'); mkdir(GROUP);
GROUPDATA       = fullfile(GROUP, 'data'); mkdir(GROUPDATA);
GROUPLOGS       = fullfile(GROUP, 'logs'); mkdir(GROUPLOGS);
GROUPFIGURES    = fullfile(GROUP, 'figures'); mkdir(GROUPFIGURES);
if isempty(info.specific.ses) && isempty(info.specific.run)
    DATA        = fullfile(RESULTS, info.specific.sub, 'data');
    LOGS        = fullfile(RESULTS, info.specific.sub, 'logs');
    FIGURES     = fullfile(RESULTS, info.specific.sub, 'figures');
elseif isempty(info.specific.run)
    DATA        = fullfile(RESULTS, info.specific.sub, info.specific.ses, 'data');
    LOGS        = fullfile(RESULTS, info.specific.sub, info.specific.ses, 'logs');
    FIGURES     = fullfile(RESULTS, info.specific.sub, info.specific.ses, 'figures');
else
    DATA        = fullfile(RESULTS, info.specific.sub, info.specific.ses, info.specific.run, 'data');
    LOGS        = fullfile(RESULTS, info.specific.sub, info.specific.ses, info.specific.run, 'logs');
    FIGURES     = fullfile(RESULTS, info.specific.sub, info.specific.ses, info.specific.run, 'figures');
end
mkdir(DATA); mkdir(FIGURES); mkdir(LOGS);

%% Load BIDS data
if ~exist('BIDS', 'var')
    BIDS = bids.layout(bidsroot);
end

% Query for EEG data
info.eeg_fname = bids.query(BIDS, 'data', 'sub', info.specific.sub, 'task', info.specific.task, 'suffix', 'eeg');
info.events_fname = bids.query(BIDS, 'data', 'sub', info.specific.sub, 'task', info.specific.task, 'suffix', 'events');
info.channels_fname = bids.query(BIDS, 'data', 'sub', info.specific.sub, 'task', info.specific.task, 'suffix', 'channels');
info.electrodes_fname = bids.query(BIDS, 'data', 'sub', info.specific.sub, 'task', info.specific.task, 'suffix', 'electrodes');

% Display loaded file information
disp('EEG files:');
disp(info.eeg_fname);
disp('Events files:');
disp(info.events_fname);
disp('Channels files:');
disp(info.channels_fname);
disp('Electrodes files:');
disp(info.electrodes_fname);

%% Init mcfg
mcfg          = struct(); % main struct
mcfg.analysis = struct(); % analysis params
mcfg.group    = struct(); % group params

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                           You can change now                            %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

%% Populate mcfg

% Group analysis parameters
% sub-NSNP811 - seems to be corrupted (check psd)
mcfg.analysis.subjects_to_remove = {'sub-NSNP811'}; % sub-NSNP811

% Channel locations
mcfg.analysis.channels = struct();
mcfg.analysis.channels.left_frontal = {''};
mcfg.analysis.channels.neighbors_matrix = 'egi'; % or triangulation

% Group
der_folder = dir(fullfile(derivatives, info.pip_name, 'group'));

