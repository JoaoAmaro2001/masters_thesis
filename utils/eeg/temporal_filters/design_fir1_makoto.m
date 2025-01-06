% Set input parameters
fs     = 250; 
signal = randn(10000,1);
hpfHz  = 8;
lpfHz  = 13;
filtOrder = 826; % Hamming, Transition Bandwidth == 1.
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate high-pass filter. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
normFreqHPF  = hpfHz/(fs/2);
filtCoeffHPF = fir1(filtOrder, normFreqHPF, 'high'); % freqz(filtCoeffHPF, 1, fs) to plot the frequency response.
transferFunctionHPF = tf(filtCoeffHPF,1,1/fs);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate low-pass filter. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
normFreqLPF  = lpfHz/(fs/2);
filtCoeffLPF = fir1(filtOrder, normFreqLPF, 'low');  % freqz(filtCoeffHPF, 1, fs) to plot the frequency response.
transferFunctionLPF = tf(filtCoeffLPF,1,1/fs);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Combine the filters. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
transferFunctionBPF = series(transferFunctionHPF, transferFunctionLPF);
 
% Visualize the designed low-pass filter.
figure
bodeHandle = bodeplot(transferFunctionBPF);
optionParams = getoptions(bodeHandle);
optionParams.FreqScale = 'linear';
optionParams.FreqUnits = 'Hz';
optionParams.XLim      = [0 fs/2];
optionParams.YLim{1}   = [-70 0];
setoptions(bodeHandle, optionParams)
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Apply the designed band-pass filter. %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filteredSignal = filtfilt(transferFunctionBPF.Numerator{1}, 1, signal);