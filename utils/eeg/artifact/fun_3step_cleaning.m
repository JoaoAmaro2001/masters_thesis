% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%            Remove uncorrelated or zeroed-out channels                   %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% Save original EEG
firstEEG = EEG;

% Drop Cz (reference -> zeroed out channel and other flat channels
[EEG, ~, ~, zeroed_channels] = clean_artifacts(EEG, ...
    'FlatlineCriterion', 5,...
    'ChannelCriterion', 0.4, ...
    'LineNoiseCriterion', 'off', ...
    'BurstCriterion', 'off', ...
    'WindowCriterion', 'off', ...
    'Highpass', 'off');
% Find which channels are zeroed out
[chan_labels,~] = setdiff({EEG.urchanlocs.labels}',{EEG.chanlocs.labels}','stable');
fprintf('Channel %s was removed\n',chan_labels{:})

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                Remove bad channels based on stats                       %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

methods      = {'kurt', 'prob', 'spec'}; % Methods to use
sd_threshold = [3, 3, 3];                % Thresholds for each method
idx_mat      = cell(length(methods), 1); % Matrix with indices for each method
% Loop through each method
for i = 1:numel(methods)
    try
        % Get indices and values
        [~, ind, vals, ~] = pop_rejchan(EEG, 'elec', 1:EEG.nbchan, 'threshold', sd_threshold(i), 'measure', methods{i}, 'norm', 'on');
        % Store indices in cell array
        idx_mat{i} = ind;
        % Save individual method results
        out_struct = struct('method', methods{i}, 'indices', ind, 'values', vals);
        save(fullfile(DATA, fname, strcat(methods{i}, '_reject_channels.mat')), 'out_struct');
    catch
        disp(['Error in method: ' methods{i}]);
    end
end

% Filter out empty cells
nonEmptyIdx = idx_mat(~cellfun('isempty', idx_mat));
% Calculate union of all non-empty rejected indices
if ~isempty(nonEmptyIdx)
    unionIndices = unique([nonEmptyIdx{:}]);
else
    unionIndices = [];
end
% Check if union of rejected indices exceeds 50% of channels
if length(unionIndices) >= round(EEG.nbchan * 0.15)
    % Calculate intersection only if union exceeds 50% and there are non-empty indices
    intersectIndices = nonEmptyIdx{1};
    for i = 2:numel(nonEmptyIdx)
        intersectIndices = intersect(intersectIndices, nonEmptyIdx{i});
    end
    % Overwrite unionIndices with intersected result
    unionIndices = intersectIndices;
end

% Drop channels and save in variable
EEG = pop_select(EEG, 'nochannel', unionIndices);
% Append all removed channels
removed_channels = sort([unionIndices, find(zeroed_channels)']);

% Final output of unionIndices or intersectedIndices
disp('Final rejected channel indices:');
disp(removed_channels);
fprintf('Channel %s was removed\n',EEG.urchanlocs(removed_channels).labels)
disp('Percentage of channels removed:')
disp(100*length(removed_channels)/length(EEG.urchanlocs))

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                           Remove bad time windows                       %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% Apply clean_rawdata(). Disable 'BurstRejection' that rejects bad windows instead of interpolates. (12/02/2024).
originalEEG = EEG;
EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off', ...
    'LineNoiseCriterion','off','Highpass','off', ...
    'BurstCriterion', 25, 'WindowCriterion', 0.3, ...
    'BurstRejection','off','Distance','Euclidian', ...
    'BurstCriterionRefMaxBadChns', 0, ...
    'BurstCriterionRefTolerances', [-Inf 8], ...
    'WindowCriterionTolerances',[-Inf 8], 'MaxMem', 4096);
survivedDataIdx           = find(EEG.etc.clean_sample_mask);
rejectedDataIdx           = find(~EEG.etc.clean_sample_mask);
asrBeforeAfterDiff        = sum(originalEEG.data(:,survivedDataIdx)-EEG.data,1);
unchangedDataIdx          = find(asrBeforeAfterDiff==0);
changedDataIdx            = find(asrBeforeAfterDiff~=0);
windowRejRate             = 1-EEG.pnts/originalEEG.pnts;
windowInterpolationRate   = 1-(EEG.pnts-length(unchangedDataIdx))/EEG.pnts;
asrPowerReductionDb       = 10*log10(var(EEG.data(:,changedDataIdx ),0,2)./var(originalEEG.data(:,changedDataIdx),0,2));
windowRejPowReducDb       = 10*log10(var(EEG.data(:,changedDataIdx ),0,2)./var(originalEEG.data(:,rejectedDataIdx),0,2));
EEG.etc.ASR.windowRejectionRate     = windowRejRate;
EEG.etc.ASR.windowInterpolationRate = windowInterpolationRate;
EEG.etc.ASR.varianceReductionInDbByWinRej = windowRejPowReducDb;
EEG.etc.ASR.varianceReductionInDbByAsr    = asrPowerReductionDb;
% {
% Visualize distribution of power reduction by ASR. 
figure
subplot(1,2,1)
topoplot(windowRejPowReducDb, EEG.chanlocs)
colorbar
title('Rejected window''s power')
subplot(1,2,2)
topoplot(asrPowerReductionDb, EEG.chanlocs)
title('Interpolated window''s power')
colorbar
% }