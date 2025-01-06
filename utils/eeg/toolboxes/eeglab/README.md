## Preprocessing

### Artifact rejection
`eeg_rejsuperpose` - updates rejection fields

Example:
```matlab
% Remove artifact trials
EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
EEG = pop_rejepoch( EEG, find(EEG.reject.rejglobal), 0);
```