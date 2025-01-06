% Example:
%           badTrialIdx = rejectTrialSTFT(EEG.icaact, 3, EEG.pnts, EEG.srate, [15 50]); % Use 15-50 Hz freq band to evaluate PSD.
%           EEG = pop_select(EEG, 'notrial', badTrialIdx);
%
% 02/04/2020 Makoto. Modified.
% 01/31/2020 Makoto. Used with modification.
% 11/08/2019 Makoto. Created. Changed from Hamming to Rectangular window (Thanks Masaki!)
 
function badTrialIdx = rejectTrialSTFT(icaact, SD, pnts, srate, freqEdges)
 
data2D = icaact(:,:);
 
totalExclusionIdx = [];
for icIdx = 1:size(data2D,1);
    [S,F,T,P,Fc,Tc] = spectrogram(data2D(icIdx,:), pnts, 0, [], srate);         % This is by default Hamming.
    %[S,F,T,P,Fc,Tc] = spectrogram(data2D(icIdx,:), rectwin(pnts), 0, [], srate); % This is rectangular window.
 
    log10P = 10*log10(P);
 
%     figure; imagesc(T, F, log10P); axis xy; colormap('jet')
 
    medianP = median(log10P,2);
 
%     figure; plot(F, medianP)
 
    errorP = bsxfun(@minus, log10P, medianP);
 
%     figure; imagesc(T, F, errorP, [-20 20]); axis xy; colormap('jet')
 
    zscoreHighFreqPower = zscore(sum(errorP(freqEdges(1):freqEdges(2),:))); % Targetting EMG.
 
 
%     figure; hist(zscoreHighFreqPower, 100)
 
    exclusionIdx = find(zscoreHighFreqPower>=SD);
 
    %{
 
    figure
    subplot(2,1,1)
    imagesc(T, F, errorP, [-20 20]); axis xy; colormap('jet')
    title('Error from median PSD')
    xlabel('Frames (s)')
    ylabel('10*log10(Power)/Hz')
 
    subplot(2,1,2)
    barHandle = bar(zscoreHighFreqPower, 1);
    xlim([0.5 length(zscoreHighFreqPower)-0.5])
    hold on
    line([0.5 length(zscoreHighFreqPower)-0.5], [SD SD], 'color', [1 0 0])
    title(sprintf('Z-scored error between %.0f and %.0f Hz.', freqEdges(1), freqEdges(2)))
    xlabel('Frames (s)')
    ylabel('Z-score')
 
    %}
 
    totalExclusionIdx = [totalExclusionIdx exclusionIdx];
end
 
badTrialIdx = unique(totalExclusionIdx);