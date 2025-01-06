%% Multiple topoplots

data = EEG.data;

% time parameters
times2plot = -200:50:900;
tidx = dsearchn(EEG.times',times2plot'); %get indices of each time; loop version is faster

% plot several
figure(6), clf
% define subplot geometry
subgeomR = ceil(sqrt(length(tidx))); % ceil == ceiling; computing the rows
subgeomC = ceil(length(tidx)/subgeomR); % this is computing the columns
for i=1:length(tidx)
    subplot( subgeomR,subgeomC,i )
    topoplot( data(:,tidx(i)),EEG.chanlocs,'electrodes','off','numcontour',0  );
    set(gca,'clim',[-1 1]*10) %allows for comparison
    title([ num2str(times2plot(i)) ' ms' ])
    colorbar
    colormap(bluewhitered(64))
end


%% time-averaged topoplot (cleaner)
 
twin = 10; % in ms; half of window
twinidx = round(twin*(EEG.srate/1000)); % convert to indices

figure(7), clf
for i=1:length(tidx)
    subplot( subgeomR,subgeomC,i )

    % time points to average together
    times2ave = tidx(i)-twinidx : tidx(i)+twinidx;

    % draw the topomap
    topoplot( mean(data(:,times2ave),2),EEG.chanlocs,'electrodes','off','numcontour',0 );
    set(gca,'clim',[-1 1]*10)
    title([ num2str(times2plot(i)) ' ms' ])
    colorbar
    colormap(bluewhitered(64))

end

