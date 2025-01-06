% pick a time point for the topoplot, and pick a channel for the ERPs
time2plot = 250; % ms
chan2plot = 'E100';


% convert to indices
tidx = dsearchn(EEG.times',time2plot);
chanidx = strcmpi({EEG.chanlocs.labels},chan2plot);


% Compute the laplacian and store as a new field in the EEG structure.
EEG.lap = laplacian_perrinX(EEG.data,[EEG.chanlocs.X],[EEG.chanlocs.Y],[EEG.chanlocs.Z]);


% The voltage and Laplacian data are in different scales. To compare them
% directly, they need to be independently normalized (z-transform).
voltERP = mean(EEG.data(chanidx,:,:),3);
voltERP = (voltERP - mean(voltERP)) / std(voltERP);

lapERP = mean(EEG.lap(chanidx,:,:),3);
lapERP = (lapERP - mean(lapERP)) / std(lapERP);

figure(5), clf
subplot(221)
topoplotIndie(mean(EEG.data(:,tidx,:),3),EEG.chanlocs,'electrodes','labels','numcontour',0);
title([ 'Voltage (' num2str(time2plot) ' ms)' ])

subplot(222)
topoplotIndie(mean(EEG.lap(:,tidx,:),3),EEG.chanlocs,'electrodes','numbers','numcontour',0);
title([ 'Laplacian (' num2str(time2plot) ' ms)' ])

subplot(212)
plot(EEG.times,voltERP, EEG.times,lapERP,'linew',2)
set(gca,'xlim',[-300 1200])
legend({'Voltage';'Laplacian'})
title([ 'ERP from channel ' chan2plot ])
xlabel('Time (ms)'), ylabel('Data (z-score)')


%% I can use the Laplacian to estimate the depth of the sources and help justify 
% my choice of MNE method (loreta VS sloreta). 