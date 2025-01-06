%% Phase 1

%This script demonstrates the first phase of artifact correction, in which
%the data are preprocessed in a manner designed to optimize the ICA decomposition.
%The script operates on the data from 10 participants from the ERP CORE MMN experiment.
%Each subject's data must be in a separate folder inside the MMN_Data folder, 
%named with the subject's ID number. The data must be continuous, and we're
%assuming that they have been filtered at 0.1 Hz and referenced.
%The script assumes that you've already looked through the data and
%determined which channels should be interpolated and what parameters
%should be used for continuous artifact rejection. The filenames for these
%spreadsheets are listed in variables below.
%The steps are:
%Load data
%Filter from 1-30 Hz, 48 dB/octave
%Resample to 100 Hz
%Delete segments of EEG during breaks
%Delete segments with huge C.R.A.P.

%To run it, just click the Run button in the Matlab GUI. If it asks you to
%change the folder or add the folder to the path, select Change Folder.

%Important: You may need to launch EEGLAB before running this script.

%DIR is the location of the main folder for this exercise. It must be the current folder.
DIR = pwd; 

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4','5', '6', '7', '8', '9', '10'}; 

% You can uncomment the next line to run this script on one participant at a time
% SUB = {'1'};

%Key filenames (I can also use .xlsx files for the future)
interpolation_fname = 'interpolate.xlsx'; % Stores information about which channels, if any, should be interpolated for each subject. These channels are excluded from ICA.
continuous_AR_parameters_fname = 'ICA_Continuous_AR.xlsx'; % Stores paramaters for artifact rejection in continuous data
orignal_dataset_fname = '_MMN_preprocessed.set'; % This is the name of the initial dataset that will be loaded, minus the subject number
output_dataset_name = '_MMN_preprocessed_optimized'; % This is the name of the dataset after all the processing steps, minus the subject number

num_channels = 33; % Number of channels in the dataafile

%%
%Read in parameters from spreadsheets
%Each line creates a variable using Matlab's Table structure
%The labels in the top line of the spreadsheet are used to define the
%names of the table columns.

interpolation_parameters = readtable(interpolation_fname);
AR_parameters = readtable(continuous_AR_parameters_fname);
 
%%
%Loop through each subject listed in SUB
for i = 1:length(SUB)
    
    % Print info to the command window
    fprintf('Processing Subject %s\n', SUB{i});
        
    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep 'MMN_Data' filesep SUB{i} filesep];
    
    % Load the original datset into memory, storing it in a variable named EEG.
    EEG = pop_loadset('filename', [SUB{i} orignal_dataset_fname],'filepath', Subject_Path);
        
    % Bandpass filter from 1-30 Hz, 48 dB/octave
    EEG = pop_basicfilter(EEG,  1:33 , 'Boundary', 'boundary', 'Cutoff', [1 30], ...
        'Design', 'butter', 'Filter', 'bandpass', 'Order',  8, 'RemoveDC', 'on' );
    
    % Resample to 100 Hz for increased speed of ICA decomposition
    EEG = pop_resample( EEG, 100);
    
    % Delete break periods, defined as 1500 ms without an event code (but
    % ignoring event codes <10). Buffer of 500 ms prior to the first event
    % code of a block and 1500 ms after the last event code of a block.
    %%% Need to also tell it to ignore boundary events
    EEG  = pop_erplabDeleteTimeSegments( EEG , 'displayEEG',  0, 'endEventcodeBufferMS',  500, 'ignoreUseEventcodes',  [1:9], 'ignoreUseType', 'ignore', 'startEventcodeBufferMS',  1500, 'timeThresholdMS',  1500 );
    
    % Set parameters for artifact rejection in continuous data and peform
    % the rejection
    table_row = find(AR_parameters{:,'ID'}==str2num(SUB{i})); % Find the row for this subject in the table
    channels = str2num(char(AR_parameters{table_row,'Channels'})); % List of channels
    threshold = AR_parameters{table_row,'Threshold'};
    window_size = AR_parameters{table_row,'Window_Size'};
    window_step = AR_parameters{table_row,'Window_Step'};
    EEG = pop_continuousartdet( EEG , 'ampth',  threshold, 'chanArray',  channels, 'shortisi',  1000, 'winms',  window_size, 'stepms',  window_step, 'threshType', 'peak-to-peak' );
    
    
    % Determine channels to include in ICA decomposition.
    chans_to_include = 1:num_channels;
    table_row = find(interpolation_parameters{:,'ID'}==str2num(SUB{i})); % Find the row for this subject in the table
    bad_channels = str2num(char(interpolation_parameters{table_row,'Bad_Channels'})); % List of channels to be interpolated
    ignored_channels = str2num(char(interpolation_parameters{table_row,'Ignored_Channels'})); % List of channels to be ignored
    chans_to_exclude = [bad_channels,ignored_channels];
    chans_to_include = chans_to_include(~ismember(chans_to_include,chans_to_exclude));

    %Update the name of the dataset.
    EEG.setname = [SUB{i} output_dataset_name];

    % Save the final version of the dataset as a file.
    EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'],'filepath', Subject_Path);

end

%% Phase 2

%This script performs the actual ICA decomposition.

%To run it, just click the Run button in the Matlab GUI. If it asks you to
%change the folder or add the folder to the path, select Change Folder.

%Important: You may need to launch EEGLAB before running this script.

%DIR is the location of the main folder for this exercise. It must be the current folder.
DIR = pwd; 

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4','5', '6', '7', '8', '9', '10'}; 

% You can uncomment the next line to run this script on one participant at a time
% SUB = {'1'}; 

%Key filenames
interpolation_fname = 'interpolate.xlsx'; % Stores information about which channels, if any, should be interpolated for each subject. These channels are excluded from ICA.
input_dataset_fname = '_MMN_preprocessed_optimized.set'; % This is the name of the initial dataset that will be loaded, minus the subject number
final_dataset_name = '_MMN_preprocessed_optimized_weights'; % This is the name of the dataset after all the processing steps, minus the subject number

num_channels = 33; % Number of channels in the datafile

%%
%Read in parameters from spreadsheets
%Each line creates a variable using Matlab's Table structure
%The labels in the top line of the spreadsheet are used to define the
%names of the table columns.

interpolation_parameters = readtable(interpolation_fname);
 
%%
%Loop through each subject listed in SUB
for i = 1:length(SUB)
    
    % Print info to the command window
    fprintf('Processing Subject %s\n', SUB{i});
        
    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep 'MMN_Data' filesep SUB{i} filesep];
    
    % Load the original datset into memory, storing it in a variable named EEG.
    EEG = pop_loadset('filename', [SUB{i} input_dataset_fname],'filepath', Subject_Path);
    
    % Determine channels to include in ICA decomposition.
    chans_to_include = 1:num_channels;
    table_row = find(interpolation_parameters{:,'ID'}==str2num(SUB{i})); % Find the row for this subject in the table
    bad_channels = str2num(char(interpolation_parameters{table_row,'Bad_Channels'})); % List of channels to be interpolated
    ignored_channels = str2num(char(interpolation_parameters{table_row,'Ignored_Channels'})); % List of channels to be ignored
    chans_to_exclude = [bad_channels,ignored_channels];
    chans_to_include = chans_to_include(~ismember(chans_to_include,chans_to_exclude));
    
    % Perform the ICA decomposition
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1, 'chanind', chans_to_include);

    %Update the name of the dataset.
    EEG.setname = [SUB{i} final_dataset_name];

    % Save the final version of the dataset as a file.
    EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'],'filepath', Subject_Path);

end

%% Phase 3

%This script transfers the weights to the original dataset and removes the
%artifactual ICs listed in the spreadsheet.
%It then interpolates any bad channels.
%This would eventually be followed by epoching and artifact detection/
%rejection for any remaining C.R.A.P.
%In a visual experiment, we'd also reject trials with blinks and eye
%movements near the time of the stimulus that might interfere with the
%sensory input.

%To run it, just click the Run button in the Matlab GUI. If it asks you to
%change the folder or add the folder to the path, select Change Folder.

%Important: You may need to launch EEGLAB before running this script.

%DIR is the location of the main folder for this exercise. It must be the current folder.
DIR = pwd; 

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4','5', '6', '7', '8', '9', '10'}; 

% You can uncomment the next line to run this script on one participant at a time
% SUB = {'1'}; 

%Key filenames
interpolation_fname = 'interpolate.xlsx'; % Stores information about which channels, if any, should be interpolated for each subject. These channels are excluded from ICA.
ICs_to_remove_fname = 'ICs_to_Remove.xlsx'; % Stores paramaters for artifact rejection in continuous data
original_dataset_fname = '_MMN_preprocessed.set'; % This is the name of the initial dataset that will be loaded, minus the subject number
weight_dataset_name = '_MMN_preprocessed_optimized_weights.set'; % This is the name of the dataset with the ICA weights
output_dataset_name = '_MMN_preprocessed_pruned'; % This is the name of the output dataset

%%
%Read in parameters from spreadsheets
%Each line creates a variable using Matlab's Table structure
%The labels in the top line of the spreadsheet are used to define the
%names of the table columns.

interpolation_parameters = readtable(interpolation_fname);
List_of_ICs_to_remove = readtable(ICs_to_remove_fname);

 
%%
%Loop through each subject listed in SUB
for i = 1:length(SUB)
    
    % Print info to the command window
    fprintf('Processing Subject %s\n', SUB{i});
        
    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep 'MMN_Data' filesep SUB{i} filesep];
    
    % Load the original datset into memory, storing it in a variable named EEG.
    EEG = pop_loadset('filename', [SUB{i} original_dataset_fname],'filepath', Subject_Path);
    
    % Load the datset with the ICA weights into memory, storing it in a variable named EEG2.
    EEG2 = pop_loadset('filename', [SUB{i} weight_dataset_name],'filepath', Subject_Path);
    
    % Transfer the weights to the original dataset
    EEG = pop_editset(EEG, 'run', [], 'icaweights', 'EEG2.icaweights', 'icasphere', 'EEG2.icasphere', 'icachansind', 'EEG2.icachansind');
    EEG = eeg_checkset(EEG); % Verify that everything is OK after the transfer
    
    % Load set of ICs to be removed
    table_row = find(List_of_ICs_to_remove{:,'ID'}==str2num(SUB{i})); % Find the row for this subject in the table
    ICs_to_remove = str2num(char(List_of_ICs_to_remove{table_row,'ICs_to_Remove'})); % List of ICs to be removed
    
    % Remove the ICs
    EEG = pop_subcomp( EEG, ICs_to_remove, 0);
    
    % Interpolate bad channels
    table_row = find(interpolation_parameters{:,'ID'}==str2num(SUB{i})); % Find the row for this subject in the table
    bad_channels = str2num(char(interpolation_parameters{table_row,'Bad_Channels'})); % List of channels to be interpolated
    ignored_channels = str2num(char(interpolation_parameters{table_row,'Ignored_Channels'})); % List of channels to be ignored
    EEG = pop_erplabInterpolateElectrodes(EEG , 'displayEEG',  0, 'ignoreChannels',  ignored_channels, 'interpolationMethod', 'spherical', 'replaceChannels', bad_channels);

    %Update the name of the dataset.
    EEG.setname = [SUB{i} output_dataset_name];

    % Save the final version of the dataset as a file.
    EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'],'filepath', Subject_Path);

end