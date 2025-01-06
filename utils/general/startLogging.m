function logfile = startLogging(log_filename)
    % start_logging - Starts logging command window output to a file
    %
    % Usage:
    %   logfile = start_logging(log_filename)
    %
    % Inputs:
    %   log_filename - (Optional) Name or path of the log file to save the output.
    %                  If not provided, a default name with a timestamp is used.
    %
    % Outputs:
    %   logfile - The name of the log file being used.
    %
    % This function starts capturing all command window output to the specified
    % log file using MATLAB's diary functionality.
    
        if nargin < 1 || isempty(log_filename)
            % Generate a default filename with a timestamp
            timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
            log_filename = ['command_window_log_' timestamp '.txt'];
        end
    
        % Ensure the filename ends with .txt
        [filepath, name, ext] = fileparts(log_filename);
        if isempty(ext)
            ext = '.txt';
        end
        logfile = fullfile(filepath, [name ext]);
    
        % Start logging
        diary(logfile);
    
        % Display a message
        fprintf('Command window output is being logged to: %s\n', logfile);
    end
    