% This example code compares PSD in dB (left) vs. uV^2/Hz (right) rendered as scalp topography (setfile must be loaded.) Requires EEGLAB.
function psd_all_channels(eeg,freqsEEG,varargin)

% Parse varargin for custom plotting settings
p = inputParser;
addParameter(p, 'cmap', 'jet', @(x) ischar(x) || isstring(x) || ismatrix(x));
addParameter(p, 'convert', 'eeglab', @(x) ischar(x) || isstring(x));
parse(p, varargin{:});

if contains(p.Results.convert, 'eeglab')
    data = eeglab2custom(eeg);
else
    data = eeg;
end

if data.ndims == 2
    dataEEG = data.eeg;     
elseif data.ndims == 3
    dataEEG = data.erp;
end

lowerFreq  = freqsEEG(1);   % Hz
higherFreq = freqsEEG(end); % Hz
meanPowerDb     = zeros(data.nbchan,1);
meanPowerMicroV = zeros(data.nbchan,1);
for channelIdx = 1:data.nbchan
    [psdOutDb(channelIdx,:), freq] = spectopo(dataEEG(channelIdx, :), 0, data.srate, 'plot', 'on', 'overlap', data.srate);
    lowerFreqIdx    = find(freq==lowerFreq);
    higherFreqIdx   = find(freq==higherFreq);
    meanPowerDb(channelIdx) = mean(psdOutDb(channelIdx, lowerFreqIdx:higherFreqIdx));
    meanPowerMicroV(channelIdx) = mean(10.^((psdOutDb(channelIdx, lowerFreqIdx:higherFreqIdx))/10), 2);
end
 
figure
subplot(1,2,1)
topoplot(meanPowerDb, data.chanlocs)
title(sprintf('Power distribution (%d-%dHz)', lowerFreq, higherFreq)) % Adjusted title
cbarHandle = colorbar;
colormap(p.Results.cmap)
set(get(cbarHandle, 'title'), 'string', '(dB)')
 
subplot(1,2,2)
topoplot(meanPowerMicroV, data.chanlocs)
title(sprintf('Power distribution (%d-%dHz)', lowerFreq, higherFreq)) % Adjusted title
cbarHandle = colorbar;
colormap(p.Results.cmap)
set(get(cbarHandle, 'title'), 'string', '(uV^2/Hz)')