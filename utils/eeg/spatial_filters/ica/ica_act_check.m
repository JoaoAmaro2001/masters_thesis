%% ICA is faster after downsampling the data

% ICA has a known bias toward high amplitude. 
% If the data length were infinite, it would not have this bias--my former colleague told me so. 
% Due to 1/f property of scalp-recorded EEG signal, which is predicted from the cable equation (see 'Electric Field of the Brain' p.174- by Nunez and Srinivasan, 2006), signal power in the higher frequency range is very small. 
% This simply means that ICA has less things to learn from high frequency (by the way, ASR applies inverse EEG-PSD filter so that signals in those high frequency ranges, which are unlikely to be dominated by natural EEG, is enhanced so that it is detected for correction). 
% If that's the case, why not cutting the high frequency from the beginning, at least for ICA purpose--that's the rational for this process. 
% If you doubt it, you can anytime verify it comparing ICA results obtained from using 1000-Hz sampled data with that from using 100-Hz downsampled data. 
% It is even possible that due to the band-limiting effect (100-Hz downsampled data is 50-Hz low-pass filtered because of anti-aliasing), ICA result could be even better. 
% The favorable effect of low-pass filtering before ICA has been told in the past EEGLAB workshops by Scott himself, I believe ('Applying 100-Hz low-pass filter before ICA is also important...') At least, it will speed up ICA.

% Run ICA.
EEG_forICA = pop_resample(EEG, 100);
EEG_forICA = pop_runica(EEG_forICA, 'extended',1,'interupt','off');
EEG.icaweights = EEG_forICA.icaweights;
EEG.icasphere  = EEG_forICA.icasphere;
EEG = eeg_checkset(EEG, 'ica');

% This is for Syanah Wynn--If you downsample the data from 250Hz to 100Hz, you have only 40% of data length. 
% Does it negatively impact ICA's performance, since there is much less data available? 
% This is something a simulation study can answer empirically, but the empirical answer is no. 
% In fact, I don't recommend to use SCCN's rule of thumb literally--I would rather add an additional condition as follows: ICA requires data length of ((ch)^2)*30 if data were sampled at 250 Hz. 
% I have been applying this downsampling-to-100Hz approach as ICA preprocessing over several thousands of datasets, in some of which the data length became shorter than the above recommendation but I did not see any impact. 
% So, the length in time in the real world counts rather than frames. For example, 5-min data can be 30,000 frames when sampled at 100 Hz, and 300,000 frames when sampled at 1000Hz. 
% Does the latter help ICA decomposition quality? It does not. It depends on how much information scalp-recorded EEG contains above 100Hz compared with below 100Hz.
% This view is supported by the following description taken from Nunez and Srinivasan (2006) p.308: "EEG (and ECoG) power in mammals tends to fall off sharply above 50 or 100 Hz, apparently reflecting cortical cell time constants in the 10 ms range as indicated in chapter 4. 
% That is, we expect minimal changes in the mesosource function P(r,t) over mesoscopic "relaxation times" in the range of 10 ms or perhaps several tens of milliseconds."

%% Checking whether icaact is computed correctly

EEG.icaact;
icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);

% It is recommended: 