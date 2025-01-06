 %% Rename event type name 'example1' into 'example2'
 allEvents = {EEG.event.type}';
 example1Idx = strcmp(allEvents, 'example1');
 [EEG.event(example1Idx).type] = deal('example2');