function df = check2convert(data, toolbox)
    %CHECK2CONVERT Convert EEG data from EEGLAB or FieldTrip to custom structure
    %
    % Usage:
    %   df = check2convert(data)
    %   df = check2convert(data, toolbox)
    %
    % Inputs:
    %   data     - EEG data structure from EEGLAB or FieldTrip
    %   toolbox  - (Optional) String specifying the toolbox ('eeglab' or 'fieldtrip')
    %
    % Outputs:
    %   df       - Custom EEG structure
    %
    % Description:
    %   If 'toolbox' is not specified, the function attempts to determine the toolbox
    %   based on the fields present in 'data'. It then calls the appropriate
    %   conversion function to convert 'data' into the custom EEG structure 'df'.
    
    if nargin == 0
        help check2convert
        return
    end

    if nargin < 2 || isempty(toolbox)
        % Attempt to determine the toolbox based on the data structure
        if isstruct(data)
            if isfield(data, 'data') && isfield(data, 'srate')
                % Likely EEGLAB structure
                toolbox = 'eeglab';
            elseif isfield(data, 'trial') && isfield(data, 'fsample')
                % Likely FieldTrip structure
                toolbox = 'fieldtrip';
            else
                error('Unable to determine the toolbox from the data structure. Please specify the toolbox as ''eeglab'' or ''fieldtrip''.');
            end
        else
            error('Input data must be a structure.');
        end
    end

    % Convert based on the specified or determined toolbox
    switch lower(toolbox)
        case 'eeglab'
            try
                df = eeglab2custom(data);
                disp('Converting from EEGLAB...')
            catch ME
                warning(E.identifier, '%s', E.message);
                disp('Attempting to convert using fieldtrip2custom...');
                try
                    df = fieldtrip2custom(data);
                catch ME2
                    error('Conversion failed with both eeglab2custom and fieldtrip2custom: %s', ME2.message);
                end
            end
        case 'fieldtrip'
            try
                df = fieldtrip2custom(data);
            catch ME
                warning(E.identifier, '%s', E.message);
                disp('Attempting to convert using eeglab2custom...');
                try
                    df = eeglab2custom(data);
                catch ME2
                    error('Conversion failed with both fieldtrip2custom and eeglab2custom: %s', ME2.message);
                end
            end
        otherwise
            error('Invalid toolbox specified. Please specify ''eeglab'' or ''fieldtrip'' as the toolbox.');
    end
    disp('Finished!')
end
