data1 = EEG.data;
data2 = EEG.data;

% choose chans or time parameters
chan2plot = 'E233';  % choose which channel to plot

%  plot ERP for a particular channel
figure(1), clf
plot(EEG.times,data1(strcmpi({EEG.chanlocs.labels},chan2plot),:),'g','linew',2)
hold on
plot(EEG.times,data2(strcmpi({EEG.chanlocs.labels},chan2plot),:),'k','linew',2)
title(['ERP from channel ' num2str(chan2plot)])
xlabel('Time (ms)')
ylabel('Voltage (\muV)')
legend({'data1','data2'})
% % plot([0 0], get(gca,'ylim'),'k')
set(gca,'xlim',[-200 1000])
hold off