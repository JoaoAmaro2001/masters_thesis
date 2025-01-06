% Define dummy event labels and latencies.
eventLabels  = {'a' 'b' 'c' 'd' 'e'}; % Example event labels.
eventLatency = [3 4 5 6 7]; % Example event latencies.
 
% Build a minimal but valid EEG.event from scratch (i.e. EEG.event = [])
[EEG.event(1:length(eventLabels)).type] = eventLabels{:};
latencyInCell = num2cell(eventLatency);
[EEG.event(1:length(eventLabels)).latency] = latencyInCell{:};
eeglab redraw % Optional. This runs eeg_checkset() and refreshes GUI.
 