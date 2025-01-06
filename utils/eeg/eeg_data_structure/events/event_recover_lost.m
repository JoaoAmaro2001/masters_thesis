% How to recover the lost events by window rejection by clean_rawdata (05/22/2021 added)
% After applying clean_rawdata, or any other manual or automated window-rejection method for data cleaning, 
% you may find some event markers are rejected as a result. 
% If those are the markers for the onset and/or offset of a block, for example, then you [can't perform the block-design analysis.
% I developed a prototype of a solution to recover the lost event markers for the case that clean_rawdata() log ']clean_sample_mask' and EEGLAB log EEG.urevent are BOTH available. 
% It replaces the 'boundary' with the lost event marker. Note that the recovered event marker is not valid to show the onset/offset of the latency of the event onset/offset, so this method cannot be straightforwardly used for the event-related study design 
% (unless you implement additional solution to detect epochs with non-canonical epoch length, although this also has a problem if the epoch contains variable SOA... but for the fixed-length epochs it should work).

% Recover the lost events.
urEventType         = {EEG.urevent.type}';
urEventLatencyFrame = round([EEG.urevent.latency]);
cleanSampleMask     = EEG.etc.clean_sample_mask;
isEventPresent      = cleanSampleMask(urEventLatencyFrame);
boundaryIdx = find(contains({EEG.event.type}, 'boundary'));
if any(isEventPresent==false)
    lostEventIdx = find(isEventPresent==0);
    for lostEventIdxIdx = 1:length(lostEventIdx)
        lostEventUrlatencyFrame = urEventLatencyFrame(lostEventIdx(lostEventIdxIdx));
        lostEventCurrentPosition = sum(cleanSampleMask(1:lostEventUrlatencyFrame));
        boundaryLatency = round([EEG.event(boundaryIdx).latency]);
        [differenceInFrame, selectedBoundaryIdx] = min(abs(boundaryLatency-lostEventCurrentPosition));
        if differenceInFrame > 3
            error('Fail to recover the lost event.')
        end
        EEG.event(selectedBoundaryIdx).type = urEventType{lostEventIdx(lostEventIdxIdx)};
    end
end