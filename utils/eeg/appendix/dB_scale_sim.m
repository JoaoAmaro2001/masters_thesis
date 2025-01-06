% Scale of 2 and a gain of 6 dB refers to the use of the amplitude ratio
% Scale of 2 and a gain of 3 dB refers to the use of the power ratio

Fs = 1000;     % Sampling frequency (Hz)      
T = 1/Fs;      % Sampling period       
L = 1000;      % Length of signal (ms)
t = (0:L-1)*T; % Time vector (ms)
targetF = 12;  % Target freq (Hz)
 
 
%% Validate EEGLAB's PSD by spectopo().
figure
% set(gcf,'position', [999   429   897   885])
 
scalerVector = [0.5 1 2];
for scaleIdx = 1:length(scalerVector)
 
    % Define the input data.
    X = sin(2*pi*targetF*t).*scalerVector(scaleIdx);
 
    subplot(3,2,1+2*(scaleIdx-1))
    plot(t, X)
    title(['12-Hz, amplitude +/-' num2str(scalerVector(scaleIdx)) '\muV'])
    xlabel('Time (s)')
    ylabel('Amplitude (\muV)')
    xlim([0 1])
    ylim([-2.5 2.5])
    grid on
 
    % Matlab FFT.
    Y = fft(X);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    P1 = P1.^2;
    P1_log10 = 10*log10(P1);
 
    subplot(3,2,2+2*(scaleIdx-1))
    f = Fs*(0:(L/2))/L;
    plot(f,P1_log10)
    title('Power Spectral Density')
    xlabel('Frequency (Hz)')
    ylabel('10*log10 \muV^2/Hz (dB)')
    hold on
 
    % EEGLAB
    [spectra,freqs] = spectopo(X, L, Fs, 'plot', 'off');
    plot(freqs, spectra)
    xlim([0 20])
    ylim([-20 10])
    grid on
    legend({'Matlab FFT' 'EEGLAB spectopo'}, 'location', 'northwest')
end
% print('/data/projects/makoto/psdValidation', '-djpeg95', '-r150') % this command is for linux only
 
 
%% Validate EEGLAB's hybrid spectro-/scalo-gram by newtimef().
Fs = 1000;     % Sampling frequency (Hz)      
T = 1/Fs;      % Sampling period       
L = 5000;      % Length of signal (ms)
t = (0:L-1)*T; % Time vector (ms)
targetF = 12;  % Target freq (Hz)
 
figure
% set(gcf,'position', [999   429   897   885])
 
scalerVector = [0.5 1 2];
for scaleIdx = 1:length(scalerVector)
 
    % Define the input data.
    splicingIdx = 2500;
    X           = sin(2*pi*targetF*t);
    X(splicingIdx:end) = sin(2*pi*targetF*t(splicingIdx:end)).*scalerVector(scaleIdx);
 
    % Plot the waveform.
    subplot(3,2,1+2*(scaleIdx-1))
    plot(t-2.5, X)
    title(['12-Hz, Amp. +/-1.0 -> ' num2str(scalerVector(scaleIdx)) ' \muV'])
    xlabel('Latency (s)')
    ylabel('Amplitude (\muV)')
    xlim([-2.5 2.5])
    ylim([-2.5 2.5])
    grid on
    line([0 0], [-2.5  2.5], 'color', [0 0 0], 'linewidth', 2, 'linestyle', '--')
 
    % Plot ERSP.
    [ersp,itc,powbase,times,freqs] = newtimef(X, L, [0 5000], Fs, [3 8],...
                                     'freqs', [2 30], 'nfreqs', 50,...
                                     'plotitc', 'off', 'plotersp', 'off', ...
                                     'baseline', [0 2500]);
 
    subplot(3,2,2+2*(scaleIdx-1))
    erspTime = round(times)/1000;
    imagesc(erspTime-2.5, freqs, ersp, [-12 12])
    title('Event-related spectral perturbation')
    xlabel('Latency (s)')
    ylabel('Frequency (Hz)')
    line([0 0], [0 50], 'color', [0 0 0], 'linewidth', 2, 'linestyle', '--')
    colormap jet
    axis xy
    colorbar
end
% print('/data/projects/makoto/erspValidation', '-djpeg95', '-r150')