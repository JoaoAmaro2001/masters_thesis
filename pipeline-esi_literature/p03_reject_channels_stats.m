% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
fname = fetchScriptName; mkdir(fullfile(FIGURES, fname)); mkdir(fullfile(LOGS, fname));
mkdir(fullfile(DATA, fname)); called = manualOrCalled(); 
if called; startLogging(fullfile(LOGS, fname,'cli')); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Reject channels based on statistics
methods = {'kurt', 'prob', 'spec'};     % Methods to use
sd_threshold = [3, 3, 3];                   % Thresholds for each method
idx_mat = cell(length(methods), 1);            % Matrix with indices for each method

% Drop Cz (reference -> zeroed out channel and other flat channels
[EEG, ~, ~, zeroed_channels] = clean_artifacts(EEG, ...
    'FlatlineCriterion', 30,...
    'ChannelCriterion', 'off', ...
    'LineNoiseCriterion', 'off', ...
    'BurstCriterion', 'off', ...
    'WindowCriterion', 'off', ...
    'Highpass', 'off');
% Find which channels are zeroed out
[~,zeroed_channels_indices] = setdiff({EEG.urchanlocs(1:257).labels}',{EEG.chanlocs.labels}','stable');

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
if length(unionIndices) >= round(EEG.nbchan * 0.5)
    % Calculate intersection only if union exceeds 50% and there are non-empty indices
    intersectIndices = nonEmptyIdx{1};
    for i = 2:numel(nonEmptyIdx)
        intersectIndices = intersect(intersectIndices, nonEmptyIdx{i});
    end
    % Overwrite unionIndices with intersected result
    unionIndices = intersectIndices;
end

% Drop channels and save in variable
EEG_rejected_channels = pop_select(EEG, 'nochannel', unionIndices);
EEG = EEG_rejected_channels;

% Append all removed channels
removed_channels = [unionIndices, zeroed_channels_indices'];

% Final output of unionIndices or intersectedIndices
disp('Final rejected channel indices:');
disp(removed_channels);
disp('Percentage of channels removed:')
disp(100*length(removed_channels)/257)

% Quick check of freqs
figure;
pop_spectopo(EEG, 1, [], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 EEG.srate/2],'electrodes','on');
saveFigs(gcf, fullfile(FIGURES,fname), 'psd_rejected_chans', false); close all

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
stopLogging();
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %