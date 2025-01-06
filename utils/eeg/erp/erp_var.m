% variance time series -> variance relates to brain dynamics
figure(3), clf

data = EEG.data;

subplot(211)
var_data = var(data); % see formula; default takes variance across first dim (nbchan in this case)
plot(EEG.times,var_data,'k','linew',2) % variance is independent of reference system (it seems tho i might be wrong - see video)
set(gca,'xlim',[-500 1000],'ylim',[0 30])
xlabel('Time (s)'), ylabel('Voltage (\muV)')
grid on
title('Topographical variance time series')