% We can load a .set file, which contains header information, by using Matlab function load() with '-mat' option. 
% However, how can we load .fdt file that is the matrix of EEG time-series data? 
% See below for the example of loading a dataset that is saved as a pair of XXXXX.set and XXXXX.fdt files.

%% Files to Load

%% Load

% Load header info.
headerInfo = load('XXXXX.set', '-mat');
 
% Load EEG time-series matrix (taken from eeg_getdatact.m centered at line 233)
fid = fopen('XXXXX.fdt', 'r', 'ieee-le');
for trialIdx = 1:headerInfo.EEG.trials % In case the saved data are epoched, loop the process for each epoch. Thanks Ramesh Srinivasan!
    currentTrialData = fread(fid, [headerInfo.EEG.nbchan headerInfo.EEG.pnts], 'float32');
    data(:,:,trialIdx) = currentTrialData; % Data dimentions are: electrodes, time points, and trials (the last one is for epoched data)                  
end
fclose(fid);