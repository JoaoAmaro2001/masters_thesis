%% setup connectivity parameters

% Prelim (3d data)
csd = EEG.data;
timevec = EEG.times;

% channels for connectivity
chan1idx = 1;
chan2idx = 8;


% create a complex Morlet wavelet
cent_freq = 8;
time      = -1.5:1/srate:1.5;
s         = 8/(2*pi*cent_freq);
wavelet   = exp(2*1i*pi*cent_freq.*time) .* exp(-time.^2./(2*s^2));
half_wavN = (length(time)-1)/2;

% FFT parameters
nWave = length(time);
nData = size(csd,2);
nConv = nWave + nData - 1;

% FFT of wavelet (check nfft)
waveletX = fft(wavelet,nConv);
waveletX = waveletX ./ max(waveletX);

% initialize output time-frequency data
phase_data = zeros(2,length(timevec));
real_data  = zeros(2,length(timevec));


% analytic signal of channel 1
dataX = fft(squeeze(csd(chan1idx,:,1)),nConv);
as = ifft(waveletX.*dataX,nConv);
as = as(half_wavN+1:end-half_wavN);

% collect real and phase data
phase_data(1,:) = angle(as); % extract phase angles
real_data(1,:)  = real(as);  % extract the real part (projection onto real axis)

% analytic signal of channel 1
dataX = fft(squeeze(csd(chan2idx,:,1)),nConv);
as = ifft(waveletX.*dataX,nConv);
as = as(half_wavN+1:end-half_wavN);

% collect real and phase data
phase_data(2,:) = angle(as);
real_data(2,:)  = real(as);

%% setup figure and define plot handles

% note: This cell is just setting up the figure for the following cell. 
%       You can run it and move on.


% open and name figure
figure(1), clf
set(gcf,'NumberTitle','off','Name','Movie magic minimizes the magic.');

% draw the filtered signals
subplot(221)
filterplotH1 = plot(timevec(1),real_data(1,1),'b');
hold on
filterplotH2 = plot(timevec(1),real_data(2,1),'m');
set(gca,'xlim',[timevec(1) timevec(end)],'ylim',[min(real_data(:)) max(real_data(:))])
xlabel('Time (ms)')
ylabel('Voltage (\muV)')
title([ 'Filtered signal at ' num2str(cent_freq) ' Hz' ])

% draw the phase angle time series
subplot(222)
phaseanglesH1 = plot(timevec(1),phase_data(1,1),'b');
hold on
phaseanglesH2 = plot(timevec(1),phase_data(2,1),'m');
set(gca,'xlim',[timevec(1) timevec(end)],'ylim',[-pi pi]*1.1)
xlabel('Time (ms)')
ylabel('Phase angle (radian)')
title('Phase angle time series')

% draw phase angles in polar space
subplot(223)
polar2chanH1 = polar([zeros(1,1) phase_data(1,1)]',repmat([0 1],1,1)','b');
hold on
polar2chanH2 = polar([zeros(1,1) phase_data(2,1)]',repmat([0 1],1,1)','m');
title('Phase angles from two channels')

% draw phase angle differences in polar space
subplot(224)
polarAngleDiffH = polar([zeros(1,1) phase_data(2,1)-phase_data(1,1)]',repmat([0 1],1,1)','k');
title('Phase angle differences from two channels')

%% now update plots at each timestep

for ti=1:5:length(timevec)
    
    % update filtered signals
    set(filterplotH1,'XData',timevec(1:ti),'YData',real_data(1,1:ti))
    set(filterplotH2,'XData',timevec(1:ti),'YData',real_data(2,1:ti))
    
    % update cartesian plot of phase angles
    set(phaseanglesH1,'XData',timevec(1:ti),'YData',phase_data(1,1:ti))
    set(phaseanglesH2,'XData',timevec(1:ti),'YData',phase_data(2,1:ti))
    
    subplot(223), cla
    polar([zeros(1,ti) phase_data(1,1:ti)]',repmat([0 1],1,ti)','b');
    hold on
    polar([zeros(1,ti) phase_data(2,1:ti)]',repmat([0 1],1,ti)','m');
    
    subplot(224), cla
    polar([zeros(1,ti) phase_data(2,1:ti)-phase_data(1,1:ti)]',repmat([0 1],1,ti)','k');
    
    drawnow
end

%% now quantify phase synchronization between the two channels

% phase angle differences
phase_angle_differences = phase_data(2,:)-phase_data(1,:);

% euler representation of angles
euler_phase_differences = exp(1i*phase_angle_differences);

% mean vector (in complex space)
mean_complex_vector = mean(euler_phase_differences);

% length of mean vector (this is the "M" from Me^ik, and is the measure of phase synchronization)
phase_synchronization = abs(mean_complex_vector);

disp([ 'Synchronization between ' num2str(chan1idx) ' and ' num2str(chan2idx) ' is ' num2str(phase_synchronization) '!' ])

% of course, this could all be done on one line:
phase_synchronization = abs(mean(exp(1i*(phase_data(2,:)-phase_data(1,:)))));

% notice that the order of subtraction is meaningless (see below), which means that this measure of synchronization is non-directional!
phase_synchronization_backwards = abs(mean(exp(1i*(phase_data(1,:)-phase_data(2,:)))));


% now plot mean vector
subplot(224)
hold on
h = polar([0 angle(mean_complex_vector)],[0 phase_synchronization]);
set(h,'linewidth',6,'color','g')
