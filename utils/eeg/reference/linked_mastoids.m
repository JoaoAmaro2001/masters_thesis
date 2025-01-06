% Rereference to linked T7 and T8

% -------------------------------------------------------------------------
df = check2convert(EEG);
% Find the indices of the T7 and T8 channels
t7_index = find(strcmp({df.chanlocs.labels}, 'T7'));
t8_index = find(strcmp({df.chanlocs.labels}, 'T8'));
compute_linked_mastoids = (df.data(t7_index, :) + df.data(t8_index, :)) / 2;
% Update the reference information in EEG structure
% EEG.ref = 'linked mastoids';
% EEG = eeg_checkset(EEG);

% -------------------------------------------------------------------------
% In eeglab
% % t7_index = find(strcmp({EEG.chanlocs.labels}, 'T7'));
% % t8_index = find(strcmp({EEG.chanlocs.labels}, 'T8'));
% % EEG = pop_reref(EEG, [t7_index t8_index], 'refstate', 'averef');