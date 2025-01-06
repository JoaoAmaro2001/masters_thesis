function cleanEmptyFolders(folderPath)
    % Function to recursively traverse a folder and delete empty folders.
    % If a folder contains only .txt files, asks the user whether to delete it.
    %
    % Usage:
    %   clean_empty_folders(folderPath)
    %
    % Input:
    %   - folderPath: Path to the folder to be cleaned.
    %
    % Example:
    %   clean_empty_folders('C:\Users\Username\Documents\MyFolder');

    if nargin < 1
        error('Please provide the folder path as an input argument.');
    end

    % Ensure the folder exists
    if ~isfolder(folderPath)
        error('The specified folder does not exist.');
    end

    % Start the recursive process
    process_folder(folderPath);

    function containsOnlyTxt = process_folder(currentFolder)
        % Initialize flags
        containsOnlyTxt = true; % Assume the folder contains only .txt files until proven otherwise
        totalFiles = 0;

        % Get list of all items in the current folder
        items = dir(currentFolder);
        % Remove '.' and '..' entries
        items = items(~ismember({items.name}, {'.', '..'}));

        % Separate files and folders
        isDir = [items.isdir];
        subFolders = items(isDir);
        files = items(~isDir);

        % Process subfolders recursively
        for i = 1:length(subFolders)
            subFolderPath = fullfile(currentFolder, subFolders(i).name);
            % Recursively process the subfolder
            subFolderContainsOnlyTxt = process_folder(subFolderPath);

            if subFolderContainsOnlyTxt
                % If the subfolder contains only .txt files or is empty, check if it's empty
                if is_folder_empty(subFolderPath)
                    % Delete the empty subfolder
                    fprintf('Deleting empty folder: %s\n', subFolderPath);
                    rmdir(subFolderPath);
                end
            else
                % The subfolder contains other files
                containsOnlyTxt = false;
            end
        end

        % Process files in the current folder
        for i = 1:length(files)
            totalFiles = totalFiles + 1;
            [~, ~, ext] = fileparts(files(i).name);
            if ~strcmpi(ext, '.txt')
                % Found a file that is not a .txt file
                containsOnlyTxt = false;
            end
        end

        % Decide what to do with the current folder
        if isempty(subFolders) && isempty(files)
            % The folder is empty
            fprintf('Deleting empty folder: %s\n', currentFolder);
            rmdir(currentFolder);
            % Return true since the folder was empty and deleted
            containsOnlyTxt = true;
        elseif containsOnlyTxt && totalFiles > 0
            % Folder contains only .txt files
            prompt = sprintf('Folder "%s" contains only .txt files. Do you want to delete it? Y/N [N]: ', currentFolder);
            str = input(prompt, 's');
            if strcmpi(str, 'Y')
                % Delete the folder and its contents
                fprintf('Deleting folder and its contents: %s\n', currentFolder);
                rmdir(currentFolder, 's'); % 's' option deletes contents recursively
                % Since we deleted the folder, return true
                containsOnlyTxt = true;
            else
                % User chose not to delete
                containsOnlyTxt = false;
            end
        else
            % Folder contains other files or non-empty subfolders
            containsOnlyTxt = false;
        end
    end

    function empty = is_folder_empty(folder)
        % Check if a folder is empty (excluding '.' and '..')
        items = dir(folder);
        items = items(~ismember({items.name}, {'.', '..'}));
        empty = isempty(items);
    end

end
