% Find the frequency resolution

% Input information
EEG.pnts = 2000000;
EEG.srate = 500;

%% First Method

% Calculate the total time in seconds
total_time = EEG.pnts / EEG.srate;

% Calculate the frequency resolution
freq_resolution = 1 / total_time;

% Print the frequency resolution
fprintf('The frequency resolution is %f Hz\n', freq_resolution);

%% Second method

% % freqspace = linspace(0,EEG.srate,EEG.pnts);
% % freqres = unique(single(diff(freqspace)));

