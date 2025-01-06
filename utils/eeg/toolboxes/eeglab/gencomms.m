% Overview:
%
% Generates automatic commands for fast EEG data importation into the
% EEGLAB study framework. Function works only for .SET files. 
% 
% Function:
% gencomms(data_folder, number of subjects, number of conditions, name of conditions)
% Example:
% gencomms( '.\folder' , 18 , 2 , 'nature' , 'urban' );
% 
% data_folder -> mandatory input. It should be ordered as such:
% -> subject 1, condition 1 (.set)
% -> subject 1, condition 2 (.set), repeat for y conditions
% -> subject 2, condition 1 (.set), repeat for x subjects until
% -> subject x, condition y (.set), end of data folder
% 
% n_subs -> optional input; use [] for default which is equal to the
% number of set files in data_folder.
% 
% n_conds -> optional input; use [] or ignore for default value = 0.
% 
% c_name1,... -> additional inputs specify the names of each condition
% in the same order of conditions as in the data folder.
% 
% Details:
% This function should be used in the 'command' input in the std_editset
% function of eeglab. 

% Author: João Amaro, MSc Neuroscience

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

function commands = gencomms(data_folder, n_subs, n_conds, varargin)

    if ~ischar(data_folder)
        error('folder path must be a string');
    end

    % set type of file
    set_pattern_search = '*.set';

    % get all files in path
    files = dir(fullfile(data_folder,set_pattern_search));

    % checking for all necessary conditions
    if nargin < 2
        n_subs = numel(files);
    elseif ~isnumeric(n_subs) || mod(n_subs, 1) ~= 0 || n_subs < 1
        error('number of subjects must be an integer');
    end
    
    if nargin < 3
        n_conds = 0;
    elseif ~isnumeric(n_conds) || mod(n_conds, 1) ~= 0 || n_conds < 0
        error('n_conds must be a non-negative integer');
    end
    
    if n_conds >= 1 && (nargin - 3) ~= n_conds
        error('You must specify a name for each condition');
    end

    if ~all(cellfun(@ischar, varargin))
        error('All input arguments must be strings.');
    end
    
    % Init commands (this function's output)
    commands = {};
    
    % IDs of subjects
    subjects = arrayfun(@(x) sprintf('S%02d', x), 1:n_subs, 'UniformOutput', false);

    % prealocating filenames
    filename = cell(1, numel(files));
    for i=1:numel(files)
        filename{i}= fullfile(files(i).folder,files(i).name);
    end

    % conditions
    
    if n_conds>0
        
        conditions = varargin;
        index = 0;
        
        for i = 1:length(subjects)

            for j = 1:length(conditions)
    
                    index = index + 1;
                    command = {'index', index, 'load', filename{index}, 'subject', subjects{i}, 'condition', conditions{j}};
                    commands{end+1} = command;
    
            end

        end
    
    % no conditions
    
    else

        for j = 1:length(subjects)
                
            command = {'index', j, 'load', filename{j}, 'subject', subjects{j}};
            
            commands{end+1} = command;
    
        end

    end

end
