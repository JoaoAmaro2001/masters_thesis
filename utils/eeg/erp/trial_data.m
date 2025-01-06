
data = EEG.data;
erp = mean(EEG.data,3);

% choose chan
chan2plot = 'E90';

% plot ERP for each trial
figure, clf
subplot(311), hold on
plot(EEG.times,erp(strcmpi({EEG.chanlocs.labels},chan2plot),:),'b','linew',2)
set(gca,'xlim',[-200 EEG.times(end)],'ylim',[-8 8])
title([ 'ERP from channel ' num2str(chan2plot) ' - nature'])
plot([0 0],get(gca,'ylim'),'k--')
plot([0 0]+ 500,get(gca,'ylim'),'k--')
plot(get(gca,'xlim'),[0 0],'k--')
xlabel('Time (ms)')
ylabel('Voltage (\muV)')

% now plot all trials from this channel
subplot(3,1,2:3)
imagesc(EEG.times,[],squeeze(data(strcmpi({EEG.chanlocs.labels},chan2plot),:,:))') 
set(gca,'clim',[-8 8],'xlim',[-200 EEG.times(end)]) 
xlabel('Time (ms)')
ylabel('Trials')
hold on
plot([0 0],get(gca,'ylim'),'k--','linew',3)
plot([0 0]+500,get(gca,'ylim'),'k--','linew',3)
hold off
colorbar
colormap turbo