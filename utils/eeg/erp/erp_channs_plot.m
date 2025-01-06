%% Plot ERPs for selected electrodes (Need to add more figure info)

figure
plotElecIdx = [3 7 11]; % Select the indices of the electrodes whose ERPs you want to plot.
for elecIdx = 1:length(plotElecIdx)
    hold on
    plot(EEG.times, mean(EEG.data(plotElecIdx,:,:),3)); % The last '3' means 'Take mean across the third dimension (i.e. trials)' so do not change.
    elecLabels{elecIdx} = EEG.chanlocs(plotElecIdx(elecIdx)).labels;
end
legend(elecLabels) % This gives you annotation of which color is which electrode.