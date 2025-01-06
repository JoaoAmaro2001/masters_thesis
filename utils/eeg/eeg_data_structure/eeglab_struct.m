% Create empty EEG structure.
EEG                                                          = eeg_emptyset;
 
% Define basic items of EEG structure.
EEG                                                          = eeg_emptyset();
EEG.data                                                     = timeSeriesDataYouHave;
EEG.times                                                    = timeSeriesDataLatencyYouHave;
EEG.xmin                                                     = EEG.times(1);
EEG.xmax                                                     = EEG.times(end);
EEG.srate                                                    = round(1/((EEG.xmax-EEG.xmin)/length(EEG.times))); % Rounded actual sampling rate. Note that the unit of the time must be in second.
EEG.nbchan                                                   = size(EEG.data,1);
EEG.pnts                                                     = size(EEG.data,2);
 
% Define event information.
eventStructure                                               = struct('type', [], 'latency', []);
latencyValues                                                = num2cell(eventLatencyInSecYouHave*EEG.srate);
[eventStructure(1:length(eventLatencyInSecYouHave)).latency] = latencyValues{:};
eventTypes                                                   = eventTypesYouHave;
[eventStructure(1:length(eventLatencyInSecYouHave)).type]    = eventTypes{:};
EEG.event                                                    = eventStructure;
EEG                                                          = eeg_checkset(EEG, 'eventconsistency');
EEG                                                          = eeg_checkset(EEG, 'makeur');