%% Run helpers (either call them here or on script (recommended))
setpath_exp2; % setpath
% Hardcoding run information
info.runs = {'1', '2'};

%% Pipeline info
info.pip_name                   = 'pipeline-esi_literature'; % change here the pipeline name

%% Check inputs
sub_default = 'NSNP811';     % Change here the subject
ses_default = '';            % Change here the session
run_default = '';           % Change here the run
tsk_default = 'videorating'; % Change here the task

% Ensure 'info' and 'info.process' exist
if ~exist('info', 'var') || ~isstruct(info)
    info = struct();
end
if ~isfield(info, 'process') || ~isstruct(info.process)
    info.process = struct();
end

% Define the fields and their default values
fields = {'sub', 'ses', 'run', 'tsk'};
defaults = {sub_default, ses_default, run_default, tsk_default};
for i = 1:numel(fields)
    fieldName = fields{i};
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

% ------------------------------------------------------------------------------
%% Create directories
DERIVATIVES     = fullfile(derivatives, info.pip_name); mkdir(DERIVATIVES);
GROUP           = fullfile(DERIVATIVES, 'group'); mkdir(GROUP);
GROUPDATA       = fullfile(GROUP, 'data'); mkdir(GROUPDATA);
GROUPLOGS       = fullfile(GROUP, 'logs'); mkdir(GROUPLOGS);
GROUPFIGURES    = fullfile(GROUP, 'figures'); mkdir(GROUPFIGURES);
if isempty(info.specific.ses) && isempty(info.specific.run)
    DATA        = fullfile(DERIVATIVES, info.specific.sub, 'data');
    LOGS        = fullfile(DERIVATIVES, info.specific.sub, 'logs');
    FIGURES     = fullfile(DERIVATIVES, info.specific.sub, 'figures');
elseif isempty(info.specific.run)
    DATA        = fullfile(DERIVATIVES, info.specific.sub, info.specific.ses, 'data');
    LOGS        = fullfile(DERIVATIVES, info.specific.sub, info.specific.ses, 'logs');
    FIGURES     = fullfile(DERIVATIVES, info.specific.sub, info.specific.ses, 'figures');
else
    DATA        = fullfile(DERIVATIVES, info.specific.sub, info.specific.ses, info.specific.run, 'data');
    LOGS        = fullfile(DERIVATIVES, info.specific.sub, info.specific.ses, info.specific.run, 'logs');
    FIGURES     = fullfile(DERIVATIVES, info.specific.sub, info.specific.ses, info.specific.run, 'figures');
end
mkdir(DATA); mkdir(FIGURES); mkdir(LOGS);

%% Load BIDS data
if ~exist('BIDS', 'var')
    BIDS = bids.layout(bidsroot);
end
subject_id = info.specific.sub;
task_name = info.specific.task;

% Query for EEG data
info.eeg_fname = bids.query(BIDS, 'data', 'sub', subject_id, 'task', task_name, 'suffix', 'eeg');
info.events_fname = bids.query(BIDS, 'data', 'sub', subject_id, 'task', task_name, 'suffix', 'events');
info.channels_fname = bids.query(BIDS, 'data', 'sub', subject_id, 'task', task_name, 'suffix', 'channels');
info.electrodes_fname = bids.query(BIDS, 'data', 'sub', subject_id, 'task', task_name, 'suffix', 'electrodes');

% Display loaded file information
disp('EEG files:');
disp(info.eeg_fname);
disp('Events files:');
disp(info.events_fname);
disp('Channels files:');
disp(info.channels_fname);
disp('Electrodes files:');
disp(info.electrodes_fname);
% ------------------------------------------------------------------------------

%% Piepline configuration (note this can be used for testing different parameters)

% Init mcfg
mcfg = struct();
mcfg.load = struct();
mcfg.load.ica = true;
mcfg.preprocess = 'default';

% Types of preprocessing (apply in mcfg.preprocess)
mcfg.options = {
    'conservative', ... % Conservative preprocessing
    'moderate', ...     % Moderate preprocessing
    'aggressive' ...    % Aggressive preprocessing
    'default' ...       % Default preprocessing
};

switch mcfg.preprocess

    case 'default'

    % Rereferencing and downsampling
    mcfg.rereference = 'average';    % Reference to average, [] in EEGLAB
    mcfg.resample    = 250;            % Downsample to 250 Hz

    % Filtering parameters (check Klug and Gramann, “Identifying Key Factors for Improving ICA-Based Decomposition of EEG Data in Mobile and Stationary Experiments.”)
    mcfg.filter.lowpass.cutoff  = 40;        % Low cutoff for band-pass filter
    mcfg.filter.highpass.cutoff = 1;         % High cutoff for band-pass filter
    mcfg.filter.order           = 2;         % Filter order
    mcfg.filter.filttype        = 'fir1';  % Filter type

    % Artifact rejection settings
    mcfg.artifact.flat    = 5;     % Flatline criterion
    mcfg.artifact.channel = 0.8;   % Bad channel rejection criterion
    mcfg.artifact.noise   = 4;     % Line noise rejection criterion

    % ICA settings
    mcfg.ica.epoch      = false;
    mcfg.ica.type       = 'runica'; % amica, runica
    switch mcfg.ica.type
        case 'amica' % https://github.com/MariusKlug/KeyFactorsForImprovingICAinEEG/blob/master/compute_0_AMICA_investigation_settings.m
            mcfg.ica.max_threads = 4;
            mcfg.ica.num_models  = 1;
    end

    % ICLABEL rejection settings
    mcfg.ica.eye        = 0.3;     % ICA rejection for eye artifacts
    mcfg.ica.muscle     = 0.3;     % ICA rejection for muscle artifacts
    mcfg.ica.heart      = 0.3;     % ICA rejection for heart artifacts
    mcfg.ica.brain      = 0.7;     % ICA retention for brain activity
    mcfg.ica.chan_noise = 0.3;     % Channel Noise removal criteria
    mcfg.ica.line_noise = 0.3;     % Line noise removal

    % Frequency bands
    mcfg.bands.delta = [1 4];      % Delta band
    mcfg.bands.theta = [4 8];      % Theta band
    mcfg.bands.alpha = [8 13];     % Alpha band
    mcfg.bands.beta  = [13 30];    % Beta band
    mcfg.bands.gamma = [30 80];    % Gamma band

    case 'conservative'
        disp('Conservative preprocessing selected');
    case 'moderate'
        disp('Moderate preprocessing selected');
    case 'aggressive'
        disp('Aggressive preprocessing selected');
    otherwise
        error('Unknown preprocessing option');
end

%% Create field for study structure (preprocessing information)

