function [info] = text2struct(info, fieldPath, text_info)
    % text2struct - Saves text output to both EEG and info structs
    %
    % Usage:
    %   [info] = text2struct(info, fieldPath, text_info)
    %
    % Inputs:
    %   info      - Info struct
    %   fieldPath - Field path as a string (e.g., 'filter.type')
    %   text_info - Text information to save
    %
    % Outputs:
    %   info      - Updated info struct with text_info added to info.process
    %
    % This function ensures that both EEG and info structs exist, and then saves
    % the specified text output to both structs under the specified fieldPath.

    
        % Split the fieldPath by dots to handle nested fields
        fieldNames = strsplit(fieldPath, '.');
    
        % Ensure structs exist
        if ~exist('EEG', 'var')
            warning('EEG struct is empty or does not exist.');
        else
            EEG.etc = set_nested_field(EEG.etc, fieldNames, text_info);
            disp(['Saved text to EEG.etc.' fieldPath]);
        end
    
        % Save to info.process
        if ~isfield(info, 'process') || isempty(info.process)
            info.process = struct();
        end
        info.process = set_nested_field(info.process, fieldNames, text_info);
    
    end
    
    function s = set_nested_field(s, fieldNames, value)
    % Helper function to set nested fields in a struct
    %
    % Inputs:
    %   s          - Struct to update
    %   fieldNames - Cell array of field names
    %   value      - Value to set at the specified field path
    %
    % Outputs:
    %   s          - Updated struct with the value set at the specified field path
    
        if isscalar(fieldNames)
            s.(fieldNames{1}) = value;
        else
            if ~isfield(s, fieldNames{1}) || isempty(s.(fieldNames{1}))
                s.(fieldNames{1}) = struct();
            end
            s.(fieldNames{1}) = set_nested_field(s.(fieldNames{1}), fieldNames(2:end), value);
        end
    end
    