%% Helpers

% clear; clc; close all
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
setpath_exp2;
config_exp2;
dir2get = fullfile(study.path.scripts, 'pipeline', 'pipeline-esi_literature');
cd(dir2get); config_pip_esi_literature; cd(scripts)
datename  = char(datetime, 'yyyyMMdd_HHmmss');
mkdir(fullfile(GROUPFIGURES,datename)); 
mkdir(fullfile(GROUPDATA,datename));
mkdir(fullfile(GROUPLOGS,datename));
called    = manualOrCalled(); 
if called; startLogging(fullfile(GROUPLOGS, datename,'cli')); end
eeglab; close all;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Parameters
from_scratch = 1; % truncates list of scripts to run

%% Read the subject info from the BIDS dataset
t           = readtable([bidsroot filesep 'participants.tsv'], 'FileType', 'text');
subjectlist = t.participant_id;

%% Preprocessing scripts' names
dirlist     = dir(dir2get);
dirlist     = {dirlist.name};
dirlist     = dirlist(startsWith(dirlist,'p') & endsWith(dirlist,'.m'));
dirlist     = sort(dirlist); 
tmp_dirlist = dirlist;
if ~from_scratch 
    tmp_dirlist = dirlist(2:end); % change here upper and lower scripts
end

%% Loop over single subjects to do the analysis

for subi = 7:size(subjectlist,1)

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    %                            Progress Bar                             %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    updateProgressBar(subi,size(subjectlist,1))
    % ---------------------------------------------------------------------  
    
    % Fetch subject
    info.process.sub = subjectlist{subi}(5:end);

    % run pipeline config
    cd(dir2get)
    config_pip_esi_literature; 

    % Get most recent saved data if p00 is not in dirlist
    if ~any(ismember(tmp_dirlist, 'p00_fetch_data.m'))
        dirlist = tmp_dirlist;
        for diri=length(tmp_dirlist):-1:1
            scriptfolder = tmp_dirlist{diri};
            if ~isempty(dir(fullfile(derivatives, info.pip_name, info.specific.sub, 'data',scriptfolder, '*.set')))
                % Load data
                setfiles = dir(fullfile(derivatives, info.pip_name, info.specific.sub, 'data',scriptfolder, '*.set'));
                fpath = fullfile(setfiles(1).folder, setfiles(1).name);
                EEG = pop_loadset(fpath);
                EEG_spatial_filter = EEG;
                % Update dirlist (start from the next script)
                dirlist = tmp_dirlist(diri+1:end);
                break
            end
        end
    end

    for runi=1:2
        % Run information
        info.process.run = num2str(runi);

    for scripti = 1:length(dirlist)
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
        %                            Progress Bar                             %
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        updateProgressBarSimple(scripti,length(dirlist))
        % ---------------------------------------------------------------------
        run(fullfile(dir2get,dirlist{scripti}));
    end

    end

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
cd(scripts)
if called; stopLogging(); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %