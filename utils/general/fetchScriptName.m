% Function to fetch the name of the currently running script
function script_name = fetchScriptName()
    
    % Get the call stack with complete file paths
    stack = dbstack('-completenames');

    % Initialize the script name
    script_name = '';

    % Start from the second element of the stack, since the first is this function
    for i = 2:length(stack)
        % Get the caller's file information
        caller = stack(i);
        % Check if the caller is a script or function
        if exist(caller.file, 'file') == 2  % Check if it's a file on disk
            % Extract the file name and extension
            [~, name, ext] = fileparts(caller.file);
            script_name = [name, ext];
            return;
        end
    end

    % If no script found in the call stack, use the active editor file
    if isempty(script_name)
        fullFilePath = matlab.desktop.editor.getActiveFilename;
        [~, name, ext] = fileparts(fullFilePath);
        script_name = [name, ext]; % or just name
    end
end
