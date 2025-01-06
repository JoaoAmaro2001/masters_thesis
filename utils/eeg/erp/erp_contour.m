data = EEG.data;
erp = mean(EEG.data,3);

figure, clf
contourf(EEG.times,1:size(data,1),erp,100,'linecolor','none') 
set(gca,'xlim',[-200 EEG.times(end)],'ydir','reverse')
title('Time-by-depth plot')
xlabel('Time (ms)'), ylabel('Channel')
hold on
plot([0 0],get(gca,'ylim'),'k--','linew',2)
plot([0 0]+500,get(gca,'ylim'),'k--','linew',2)
colorbar
axis xy