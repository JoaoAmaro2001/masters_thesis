data = EEG.data;

% define time parameters
time2plot = 900;  %  choose time point, in ms, for topographical map
[~,tidx] = min(abs(EEG.times-time2plot)); % convert time in ms to time in indices
% the ~ is negation since we dont want the first output, only the second -> index

figure(4), clf
topoplot(data(:,tidx),EEG.chanlocs); % change to geoscan file
title([ 'ERP from time equal to ' num2str(time2plot) ' ms'])
set(gca,'clim', [-8 8]);
colorbar
colormap(bluewhitered(64))