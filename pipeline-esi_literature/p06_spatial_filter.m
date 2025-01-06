% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
fname = fetchScriptName; mkdir(fullfile(FIGURES, fname)); mkdir(fullfile(LOGS, fname));
mkdir(fullfile(DATA, fname)); called = manualOrCalled(); 
if called; startLogging(fullfile(LOGS, fname,'cli')); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Spatial Filter

% Asset EEG.data as double
eeg_data                                  = double(EEG.data);
% Get the electrode coordinates
coords                                    = EEG.urchanlocs(1:257);
% Preallocate the filtered data
filteredData                              = zeros(size(EEG.data));

% Loop over each electrode
for chan = 1:length(coords)

    % Find the 6 closest neighbors + central electrode
    distances                             = sqrt(sum(bsxfun(@minus, [coords.X; coords.Y; coords.Z], [coords(chan).X; coords(chan).Y; coords(chan).Z]).^2, 1));
    [~, sortedIndices]                    = sort(distances);
    neighbors                             = sortedIndices(1:7);
    values                                = eeg_data(neighbors, :); 

    for t = 1:size(values, 2)
        % Store values along with their channel indices
        channelValues                     = [values(:, t), neighbors'];
        
        % Sort based on values
        sortedChannelValues               = sortrows(channelValues, 1);
        
        % Trim min and max
        trimmedChannelValues              = sortedChannelValues(2:end-1, :);
        
        % Extract trimmed values and corresponding channel indices
        trimmedValues                     = trimmedChannelValues(:, 1);
        trimmedIndices                    = trimmedChannelValues(:, 2);

        % Compute distances for the remaining channels
        trimmedDistances                  = distances(trimmedIndices); 
        trimmedDistances(trimmedDistances == 0) = 1; % Set central electrode distance to 1

        % Create the weight vector (inverse distance for neighbors, 1 for the central electrode)
        weights                           = 1 ./ trimmedDistances;
        weights(trimmedIndices == chan)   = 1;

        % Apply weighted averaging
        filteredData(chan, t)             = sum(trimmedValues .* weights') / sum(weights);
    end
end

% Clear vars
clear eeg_data
% Create new EEG
EEG_spatial_filter = EEG;
EEG_spatial_filter.data = double(filteredData);

% Compare later with EEG (interpolated and rereferenced after ica cleaning)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Quick check of freqs
figure;
pop_spectopo(EEG, 1, [], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 EEG.srate/2],'electrodes','on');
saveFigs(gcf, fullfile(FIGURES,fname), 'psd_after_interpolation', false); close all
% Quick check of freqs
figure;
pop_spectopo(EEG_spatial_filter, 1, [], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 EEG_spatial_filter.srate/2],'electrodes','on');
saveFigs(gcf, fullfile(FIGURES,fname), 'psd_spatial_filter', false); close all

% Save Dataset
bids_fname = strcat('sub-',info.subjects{index_sub}, '_task-',info.tasks{index_tsk}, '_eeg.set');
pop_saveset(EEG_spatial_filter, 'filename', bids_fname, 'filepath', fullfile(DATA,fname));

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
stopLogging();
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

if ~called

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename','sub-NSNP808_ses-_task-videorating_eeg.set','filepath','Z:\\Exp_2-video_rating\\derivatives\\pipeline-esi_literature\\sub-NSNP808\\run-1\\data\\p05_interp_reref.m\\');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = pop_loadset('filename','sub-NSNP808_task-videorating_eeg.set','filepath','Z:\\Exp_2-video_rating\\derivatives\\pipeline-esi_literature\\sub-NSNP808\\run-1\\data\\p06_spatial_filter.m\\');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

    EEG1 = ALLEEG(1); % interpolated
    EEG2 = ALLEEG(2); % spatial

    EEG = pop_eegfiltnew(EEG1, 'locutoff', [], 'hicutoff', 40, 'revfilt', 0, 'plotfreqz', 1);
    EEG = pop_chanedit(EEG,'nosedir','+Y'); % Otherwise plots will be rotated
    EEG_ep = eeg_checkset(f_epoch_by_images(EEG, 0)); % 1 -> remove baseline; 0 -> otherwise

    % Define intervals of 100 ms from -200 ms to 1000 ms
    start_time   = -100;
    end_time     = 1000;
    times2plot   = start_time:100:end_time; 
    tidx         = dsearchn(EEG_ep.times',times2plot'); 

    % Create a figure and clear it
    figure(4), clf
    set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
    set(gcf, 'Color', 'w');
    
    % Define subplot geometry
    subgeomR = ceil(sqrt(length(tidx))); 
    subgeomC = ceil(length(tidx)/subgeomR);
    
    for i = 1:length(tidx)
        % Define plot geometry
        subplot(subgeomR, subgeomC, i)
    
        % topoplot for the mean amplitude at the chosen time point
        topoplot(EEG_ep.data(:, tidx(i), 1), EEG_ep.chanlocs, 'electrodes', 'on', 'numcontour', 1);
    
        % Set color limits for comparability across subplots
        set(gca, 'CLim', [-1 1]*15) 
        title([num2str(times2plot(i)) ' ms'], 'FontSize', 10, 'FontWeight', 'bold');
        
        % Colors
        colorbar;
        colormap(bluewhitered(64))
    end

end
