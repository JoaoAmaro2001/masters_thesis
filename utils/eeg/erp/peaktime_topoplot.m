data = EEG.data;

timerange = [300 1000]; % ms
indices = dsearchn(EEG.times', timerange');

maxvalues = zeros(size(data,1),1);
for j=1:size(data,1) % i could have done this loop in one line of code
    [~,timeid] = max(data(j,indices(1):indices(2)));
    maxvalues(j,1) = EEG.times(timeid + indices(1) - 1); % -1 because timeid starts from index 1
end

figure(16), clf
topoplot(maxvalues,EEG.chanlocs,'numcontour', 2 ,'electrodes','numbers')
title({'ERP peak times';[' (' num2str(EEG.times(indices(1))) '-' num2str(EEG.times(indices(2))) ' ms)' ]})
set(gca,'clim',EEG.times(indices))
% colormap hot
colorbar