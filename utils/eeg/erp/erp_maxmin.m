

data = EEG.data;
erp = mean(EEG.data,3);

% choose channel
chan2use = 'E31';
chanidx = strcmpi({EEG.chanlocs.labels},chan2use);

% maximum and minimum voltage values for the channel
[vmax_n, i1] = max(squeeze(data(chanidx,:)),[],'all'); 
[vmin_n, i2] = min(squeeze(data(chanidx,:)),[],'all');

% find indices of relevant time interval
negpeaktime = dsearchn(EEG.times', [180 295]')';
pospeaktime = dsearchn(EEG.times', [300 950]')';

figure(14),clf
plot(EEG.times,erp(chanidx,:),'k','linew',1)
set(gca,'xlim',[-300 1000])

% plot patches over areas
ylim = get(gca,'ylim');
ph = patch(EEG.times(negpeaktime([1 1 2 2])),ylim([1 2 2 1]),'y'); % order is lower left, higher left, higher right, lower right
set(ph,'facealpha',.8,'edgecolor','none')

ph = patch(EEG.times(pospeaktime([1 1 2 2])),ylim([1 2 2 1]),'g');
set(ph,'facealpha',.8,'edgecolor','none')

% move the patches to the background
set(gca,'Children',flipud( get(gca,'Children') )) % children are the subpolts and flipud filps the order

% axis labels, etc
xlabel('Time (ms)')
ylabel('Voltage (\muV)')
title([ 'ERP from channel ' chan2use ])
legend({'LPP','Occipital'})

% mean
win = 15; % ms
wini = round(win*(EEG.srate/1000));

% find minimum/maximum peak times
[~,data_MinTime] = min(erp(chanidx, negpeaktime(1):negpeaktime(2)));
[~,data_MaxTime] = max(erp(chanidx, pospeaktime(1):pospeaktime(2)));

% adjust ERP timings
data_MinTime = data_MinTime + negpeaktime(1)-1; % -1 corrects the calculation
data_MaxTime = data_MaxTime + pospeaktime(1)-1;

% now find average values around the peak time - reduces noise
data_Min = mean( erp(chanidx, data_MinTime-wini:data_MinTime+wini) );
data_Max = mean( erp(chanidx, data_MaxTime-wini:data_MaxTime+wini) );

% ERP timings
data_MinTime = EEG.times( data_MinTime );
data_MaxTime = EEG.times( data_MaxTime );

% get results (peak-to-peak voltage and latency)
data_P2P = data_Max - data_Min;
data_P2Plat = data_MaxTime - data_MinTime;

% print results
fprintf('\nRESULTS FOR WINDOW AROUND PEAK (Nature):')
fprintf('\nPeak-to-peak on ERP: %5.4g muV, %4.3g ms span.',data_P2P,data_P2Plat)