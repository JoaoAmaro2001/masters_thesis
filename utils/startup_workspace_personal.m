% Directories
cdir = pwd; % Run this to start on custom directory
cd('C:\Users\joaop\git\JoaoAmaro2001\WorkRepo')
matlab_config
addpath(genpath(pwd))
try
cd(cdir)
catch
end
clear

% Toolboxes
toolbox_dir = 'C:\Users\joaop\toolbox';
items = dir(toolbox_dir);
for i = 1:length(items)
    if items(i).isdir && ~strcmp(items(i).name, '.') && ~strcmp(items(i).name, '..')
        folderPath = fullfile(toolbox_dir, items(i).name);
        switch items(i).name
            case 'Corr_toolbox_v2'
            addpath(genpath(folderPath));
            disp(['Added to path (via genpath): ', folderPath]);
            case 'plotly_matlab-master'
            addpath(genpath(folderPath));
            disp(['Added to path (via genpath): ', folderPath]);
            plotlysetup_offline;
            otherwise
            addpath(folderPath);
            disp(['Added to path: ', folderPath]);
        end
    end
end

