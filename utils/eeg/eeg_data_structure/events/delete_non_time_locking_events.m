% Motivation: Imagine you have mismatch negativity data sets in which a stimulus was presented every 0.5 s. 
% In order to perform our standard time-frequency analysis, which uses 1116 ms Morlet wavelet kernel with the 
% lowest 3 Hz with 3 cycles (but this does NOT mean EEGLAB performs a pure wavelet analysis--see this page), we need much longer epoch than one trial. 
% If we apply our standard recommendation of -1 to 2 s epoching, it will inflate the data to 6 times larger (3.0 s contains 6 0.5 s). 
% This not only inflate data size, but also inflate event structure. 
% This redundant event structure causes many problems, although all we need in this situation is just those events whose within-epoch latency is 0. 
% The following code addresses this issue so that EEG.event and EEG.epoch have only one event that has latency zero.

% Delete non-time-locking events from epoched data (08/16/2020 updated)
for epochIdx = 1:length(EEG.epoch)
    allEventIdx    = 1:length(EEG.epoch(epochIdx).event);
    if length(allEventIdx) == 1 % If there is only 1 event, it must have latency zero.
        continue
    else
        zeroLatencyIdx = find(cell2mat(EEG.epoch(epochIdx).eventlatency) == 0);
        EEG.epoch(epochIdx).event         = EEG.epoch(epochIdx).event(zeroLatencyIdx);
        EEG.epoch(epochIdx).eventtype     = EEG.epoch(epochIdx).eventtype(zeroLatencyIdx);
        EEG.epoch(epochIdx).eventlatency  = {0};
        EEG.epoch(epochIdx).eventurevent  = EEG.epoch(epochIdx).eventurevent(zeroLatencyIdx);
        EEG.epoch(epochIdx).eventduration = 0;
    end
end
validEventIdx  = [EEG.epoch.event];
deleteEventIdx = setdiff(1:length(EEG.event), validEventIdx);
EEG.event(deleteEventIdx) = [];
for epochIdx = 1:length(EEG.epoch)
    EEG.epoch(epochIdx).event = epochIdx;
end