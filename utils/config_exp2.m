% Script description:
% Defines configurations for the specific study
% Everything between percent-rows should not be changed
% Author: João Amaro, FMUL, 2024/12/05

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                           Do not change                                 %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

%% Check if study has already been loaded
if exist('study', 'var')
    warning('The study struct is already loaded. If you want to reload it, please clear the workspace and run this script again.');
    return;
end

%% Setpath
if ~exist('bidsroot', 'var')
    setpath_exp2;
end

%% Init STUDY struct
study                           = struct();
study.dataset.short             = 'exp2';
study.path.scripts              = fullfile(scripts, 'Exp_2_Video');
study.path.pipeline             = fullfile(study.path.scripts, 'pipeline');
study.path.analysis             = fullfile(study.path.scripts, 'analysis');

%% Query BIDS
if ~exist('BIDS', 'var')
info = struct();
BIDS = bids.layout(bidsroot, 'verbose', 'true');
end

% Get metadata

% Get entities (e.g. sub; task; run; ses)
info.entities = bids.query(BIDS, 'entities');
disp('Entities:');
disp(info.entities);

% Get subjects
info.subjects = bids.query(BIDS, 'subjects');
disp('Subjects:');
disp(info.subjects);

% Get sessions
info.sessions = bids.query(BIDS, 'sessions');
disp('Sessions:');
disp(info.sessions);

% Get tasks
info.tasks = bids.query(BIDS, 'tasks');
disp('Tasks:');
disp(info.tasks);

% Get runs
info.runs = bids.query(BIDS, 'runs');
disp('Runs:');
disp(info.runs);
info.runs = {}; % fixes the bug

% Get data types
info.suffixes = bids.query(BIDS, 'suffixes');
disp('Data types:');
disp(info.suffixes);

% Get file extensions
info.extensions = bids.query(BIDS, 'extensions');
disp('Data types:');
disp(info.extensions);

if ismember('eeg', info.suffixes)

% Get EEG data
info.eeg_data = bids.query(BIDS, 'data', 'suffix', 'eeg');
disp('EEG Data:');
disp(info.eeg_data);

elseif ismember('meg', info.suffixes)

% Get MEG data
info.meg_data = bids.query(BIDS, 'data', 'suffix', 'meg');
disp('MEG Data:');
disp(info.meg_data);

elseif ismember('ieeg', info.suffixes)

% Get iEEG data
info.ieeg_data = bids.query(BIDS, 'data', 'suffix', 'ieeg');
disp('iEEG Data:');
disp(info.ieeg_data);

elseif ismember('mri', info.suffixes)

% Get MRI data
info.mri_data = bids.query(BIDS, 'data', 'suffix', 'mri');
disp('MRI Data:');
disp(info.mri_data);

else

% No recognized neuroimaging data found
disp('No recognized neuroimaging data (EEG, MEG, iEEG, or MRI) found in the dataset.');


end

%% Create BIDS log file

log_dir = fullfile(sourcedata, 'supp', 'bidsLog');
if ~exist(log_dir, 'dir')
    mkdir(log_dir);
end

% Get current timestamp
timestamp     = char(datetime, 'yyyyMMdd_HHmmss');

% Compile BIDS information
bids_info              = struct();
bids_info.AccessTime   = timestamp;
bids_info.BIDSVersion  = BIDS.description.BIDSVersion;
bids_info.Name         = BIDS.description.Name;
bids_info.Entities     = info.entities;
bids_info.Subjects     = info.subjects;
bids_info.Sessions     = info.sessions;
bids_info.Tasks        = info.tasks;
bids_info.Runs         = info.runs;
bids_info.EEGDataFiles = info.eeg_data;

% Export as text
txt_filename = fullfile(log_dir, ['BIDS_log_', timestamp, '.txt']);
fid = fopen(txt_filename, 'w');
fprintf(fid, 'BIDS Log File\n\n');
fprintf(fid, 'Access Time: %s\n\n', bids_info.AccessTime);
fprintf(fid, 'BIDS Version: %s\n', bids_info.BIDSVersion);
fprintf(fid, 'Dataset Name: %s\n\n', bids_info.Name);

fprintf(fid, 'Entities:\n');
fprintf(fid, '%s\n', strjoin(bids_info.Entities, ', '));

fprintf(fid, '\nSubjects:\n');
fprintf(fid, '%s\n', strjoin(bids_info.Subjects, ', '));

fprintf(fid, '\nSessions:\n');
fprintf(fid, '%s\n', strjoin(bids_info.Sessions, ', '));

fprintf(fid, '\nTasks:\n');
fprintf(fid, '%s\n', strjoin(bids_info.Tasks, ', '));

fprintf(fid, '\nRuns:\n');
fprintf(fid, '%s\n', strjoin(bids_info.Runs, ', '));

fprintf(fid, '\nEEG Data Files:\n');
fprintf(fid, '%s\n', strjoin(bids_info.EEGDataFiles, '\n'));

fclose(fid);

% Export as JSON
json_filename = fullfile(log_dir, [timestamp,'_BIDS_log', '.json']);
jsonStr = jsonencode(bids_info, 'PrettyPrint', true);
fid = fopen(json_filename, 'w');
fprintf(fid, '%s', jsonStr);
fclose(fid);

disp(['BIDS log files created: ', txt_filename, ' and ', json_filename]);

%% STUDY - EEG

% We used EGI's HydroCel GSN 256 channel cap

% Init fields
study.eeg.channels.eog                = struct();
study.eeg.channels.clusters           = struct();

% Define electrooculogram (EOG) channels
study.eeg.channels.eog.under_left     = {'E241'}; % under the left eye (vertical movement)
study.eeg.channels.eog.under_right    = {'E238'}; % under the right eye (vertical movement)
study.eeg.channels.eog.outer_left     = {'E54'};  % outer canthus of the left eye (horizontal movement)
study.eeg.channels.eog.outer_right    = {'E1'};   % outer canthus of the right eye (horizontal movement)
% Define electrode clusters
study.eeg.channels.clusters.frontal       = {'E38', 'E39', 'E40', 'E36', 'E35', 'E34', 'E33', 'E28', 'E29', 'E19', 'E22', 'E11','E12','E13','E14','E15', 'E3', 'E4', 'E5','E21', 'E20', 'E27', 'E26'};
study.eeg.channels.clusters.right_frontal = {'E38', 'E39', 'E40', 'E36', 'E35', 'E34', 'E33', 'E28', 'E29', 'E27', 'E22'};
study.eeg.channels.clusters.left_frontal  = {'E19','E11','E12','E13','E14', 'E3', 'E4', 'E5', 'E20','E223','E224'};
study.eeg.channels.clusters.central       = {'Cz', 'C3', 'C4'};
study.eeg.channels.clusters.temporal      = {'T7', 'T8'};
study.eeg.channels.clusters.parietal      = {'P7', 'P8', 'P3', 'P4', 'Pz'};
study.eeg.channels.clusters.occipital     = {'O1', 'O2'};
study.eeg.channels.clusters.midline       = {'Fz', 'Cz', 'Pz'};
study.eeg.channels.clusters.global        = {''};
clusterNames                              = fieldnames(study.eeg.channels.clusters);
numClusters                               = length(clusterNames);

% Luu, P., & Ferree, T. (n.d.). Determination of the HydroCel Geodesic Sensor Nets’ 
% Average Electrode Positions and Their 10 – 10 International Equivalents.
standard2egi = { ...
    'Fp1', 'E37'; ...
    'Fp2', 'E18'; ...
    'AF3', 'E34'; ...
    'AF4', 'E12'; ...
    'F3', 'E36'; ...
    'F4', 'E224'; ...
    'F7', 'E47'; ...
    'F8', 'E2'; ...
    'Fz', 'E21'; ...
    'FC1', 'E24'; ...
    'FC5', 'E49'; ...
    'FC6', 'E213'; ...
    'FC2', 'E207'; ...
    'T7', 'E69'; ...
    'T8', 'E202'; ...
    'C3', 'E59'; ...
    'C4', 'E183'; ...
    'Cz', 'E257'; ...
    'CP5', 'E76'; ...
    'CP6', 'E172'; ...
    'CP1', 'E79'; ...
    'CP2', 'E143'; ...
    'P7', 'E96'; ...
    'P8', 'E170'; ...
    'P3', 'E87'; ...
    'P4', 'E153'; ...
    'Pz', 'E101'; ...
    'PO3', 'E109'; ...
    'PO4', 'E140'; ...
    'O1', 'E116'; ...
    'O2', 'E150'; ...
    'Oz', 'E126'; ...
    'AFz', 'E20'; ...
    'TP8', 'E179'; ...
    'TP7', 'E47'; ...
    'P6', 'E162'; ...
    'P5', 'E86'; ...
    'FT7', 'E62'; ...
    'FT8', 'E211'; ...
    'F10', 'E5'; ...
    'F1', 'E3'; ...
    'F2', 'E5'; ...
    'POz', 'E119'; ...
    'CPz', 'E81'; ...
    'T10', 'E210'; ...
    'T9', 'E3'; ...
    'P9', 'E194'; ...
    'P10', 'E169'; ...
    'PO7', 'E97';...
    'PO8', 'E161';...    
};
