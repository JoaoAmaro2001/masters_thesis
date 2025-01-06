function saveTextOutput(text_output, outdir, filename)
    % saveTextOutput Saves text output to a .txt file
    %
    % Parameters:
    %   text_output - The text string to save
    %   outdir      - The directory where the file will be saved
    %   filename    - The name of the file (without extension)
    
    % Ensure output directory exists
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end

    % Full path to the output file
    file_path = fullfile(outdir, [filename '.txt']);

    % Replace literal '\n' with actual newline characters
    text_output = strrep(text_output, '\n', newline);

    % Open the file for writing
    fid = fopen(file_path, 'w');
    if fid == -1
        error('Cannot open file for writing: %s', file_path);
    end

    % Write the text output to the file
    fprintf(fid, '%s', text_output);

    % Close the file
    fclose(fid);
end
    