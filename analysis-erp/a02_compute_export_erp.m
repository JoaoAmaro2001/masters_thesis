% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                           Run helpers                                   %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
fname = fetchScriptName; called = manualOrCalled();
mkdir(fullfile(FIGURES,fname)); mkdir(fullfile(DATA,fname));
mkdir(fullfile(LOGS,fname)); 
if called; startLogging(fullfile(LOGS, fname,'cli')); end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                             Main Script                                 %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % %
%%  Compute ERPs %%
% % % % % % % % % %

ERP_n      = mean(EEG_n.data, 3);
ERP_u      = mean(EEG_u.data, 3);
ERP_c      = mean(EEG_c.data, 3);
ERP_nc     = mean(EEG_nc.data, 3);
ERP_nminu  = ERP_n - ERP_u;
ERP_cminnc = ERP_c - ERP_nc;
times      = EEG_n.times;  

% % % % % % % % % % % % % % %
%% Plot topographical Maps %%
% % % % % % % % % % % % % % %

% Define intervals of 100 ms from -200 ms to 1000 ms
start_time   = -100;
end_time     = 1000;
times2plot   = start_time:100:end_time; 
tidx         = dsearchn(times',times2plot'); 
cond_suffix  = {'n'; 'u'; 'c'; 'nc'; 'nminu'; 'cminnc'};

% Loop over each condition
for c = 1:length(cond_suffix)
    data = eval(strcat('ERP_',cond_suffix{c}));
    cond_name = cond_suffix{c};
    % Create a figure and clear it
    figure(c), clf
    set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
    set(gcf, 'Color', 'w');
    
    % Define subplot geometry
    subgeomR = ceil(sqrt(length(tidx))); 
    subgeomC = ceil(length(tidx)/subgeomR);
    
    for i = 1:length(tidx)
        % Define plot geometry
        subplot(subgeomR, subgeomC, i)
    
        % topoplot for the mean amplitude at the chosen time point
        topoplot(data(:, tidx(i)), EEG_n.chanlocs, 'electrodes', 'on', 'numcontour', 1);
    
        % Set color limits for comparability across subplots
        set(gca, 'CLim', [-1 1]*10) 
        title([num2str(times2plot(i)) ' ms'], 'FontSize', 10, 'FontWeight', 'bold');
        
        % Colors
        colorbar;
        colormap(bluewhitered(64))
    end
    % Save
    saveFigs(gcf,fullfile(FIGURES,fname),strcat('topoplot_',cond_name), false)
end
close all;

% % % % % % % % % % % % % % % % % % % % % % % % % % % %
%% Plot ERP difference for conditions and Trial Maps %%
% % % % % % % % % % % % % % % % % % % % % % % % % % % %

% Find time indices for chosen window
lowlim  = 0;
highlim = 996;
[~, idx_min] = min(abs(times - lowlim));
[~, idx_max] = min(abs(times - highlim));

% Define the time window indices
time_window = idx_min:idx_max;
% Compute mean absolute difference in the time window for each channel
mean_diff_nu = mean(abs(ERP_nminu(:, time_window)), 2);  % For diff_erp_nu
mean_diff_cn = mean(abs(ERP_cminnc(:, time_window)), 2);  % For diff_erp_cn
% Get channel labels
chan_labels = {EEG_n.chanlocs.labels};

% Find the channel with the maximum difference for each pair
[~, max_chan_idx_nu] = max(mean_diff_nu);
[~, max_chan_idx_cn] = max(mean_diff_cn);

% Get the labels of the channels with the maximum difference
max_chan_label_nu = chan_labels{max_chan_idx_nu};
max_chan_label_cn = chan_labels{max_chan_idx_cn};

% Display the channels
disp(['Channel with maximum difference (EEG_n - EEG_u): ' max_chan_label_nu]);
disp(['Channel with maximum difference (EEG_c - EEG_nc): ' max_chan_label_cn]);

% Compute neighbours
neighbours = struct();
for chanind = 1:length(EEG.etc.layout.neighbors)
    neighbours(chanind).label = ['E' num2str(chanind)];
    tmp = EEG.etc.layout.neighbors(chanind).neighbors;
    neighbours(chanind).neighblabel = cellfun(@(x) ['E' num2str(x)], num2cell(tmp), 'UniformOutput', false);
end

% Find neighboring channels for max difference channels
neighbor_idxs_nu = neighbours(max_chan_idx_nu).neighblabel;
neighbor_idxs_cn = neighbours(max_chan_idx_cn).neighblabel;

% Display neighboring channels
disp('Neighboring channels for EEG_n vs. EEG_u:');
disp(neighbor_idxs_nu');
disp('Neighboring channels for EEG_c vs. EEG_nc:');
disp(neighbor_idxs_cn');

% Names for conditions
condition1_name = 'EEG_n';
condition2_name = 'EEG_u';

% Loop over neighboring channels
for i = 1:length(neighbor_idxs_nu)
    
    % Get channel info
    chan_label = neighbor_idxs_nu{i};
    chan_idx = str2double(chan_label(2:end));

    % Now plot all trials from this channel
    figure, clf
    h = subplot(4,1,1);
    imagesc(EEG_n.times,[],squeeze(EEG_n.data(strcmpi({EEG_n.chanlocs.labels},chan_label),:,:))') 
    title(['Natural condition: Trial maps for channel ' chan_label], 'FontSize', 14, 'FontWeight', 'bold');    
    tidy_erp_map(h)
    h = subplot(4,1,2);
    imagesc(EEG_u.times,[],squeeze(EEG_u.data(strcmpi({EEG_u.chanlocs.labels},chan_label),:,:))')     
    title(['Urban condition: Trial maps for channel ' chan_label], 'FontSize', 14, 'FontWeight', 'bold');    
    tidy_erp_map(h)
    
    % Call the plotting function
    plot_erps_and_difference(times, ERP_n, ERP_u, chan_idx, chan_label, condition1_name, condition2_name);    

    % Save figs
    saveFigs(gcf, fullfile(FIGURES,fname), strcat(condition1_name,'_',condition2_name,'_',chan_label), false);

end
if ~called; close all; end

% Names for conditions
condition1_name = 'EEG_c';
condition2_name = 'EEG_nc';

% Loop over neighboring channels
for i = 1:length(neighbor_idxs_cn)

    % Get channel info    
    chan_label = neighbor_idxs_cn{i};
    chan_idx = str2double(chan_label(2:end));
    
    % Now plot all trials from this channel
    figure, clf
    h = subplot(4,1,1);
    imagesc(EEG_c.times,[],squeeze(EEG_c.data(strcmpi({EEG_c.chanlocs.labels},chan_label),:,:))') 
    title(['Crowded condition: Trial maps for channel ' chan_label], 'FontSize', 14, 'FontWeight', 'bold');    
    tidy_erp_map(h)
    h = subplot(4,1,2);
    imagesc(EEG_nc.times,[],squeeze(EEG_nc.data(strcmpi({EEG_nc.chanlocs.labels},chan_label),:,:))')     
    title(['Non-crowded condition: Trial maps for channel ' chan_label], 'FontSize', 14, 'FontWeight', 'bold');    
    tidy_erp_map(h)
    
    % Call the plotting function
    plot_erps_and_difference(times, ERP_c, ERP_nc, chan_idx, chan_label, condition1_name, condition2_name); 

    % Save figs
    saveFigs(gcf, fullfile(FIGURES,fname), strcat(condition1_name,'_',condition2_name,'_',chan_label), false);

end
if ~called; close all; end

% % % % % % % % % % % % % % % % % % % % % % % %
%% Check metrics for EPN and LPP components  %%
% % % % % % % % % % % % % % % % % % % % % % % %

% Channels for EPN & LPP
EPN_chan2plot = {'P7', 'PO7', 'O1', 'O2', 'PO8', 'P8'};
LPP_chan2plot = {'Cz', 'CPz', 'CP1', 'CP2', 'Pz'};
EPN_inds      = ismember(standard2egi(:,1), EPN_chan2plot');
LPP_inds      = ismember(standard2egi(:,1), LPP_chan2plot');
EPN_egichans  = standard2egi(EPN_inds,2);
LPP_egichans  = standard2egi(LPP_inds,2);

% Choose whether to add neighbouring channels (increase SNR)
add_neighbour_channels = 1;
if add_neighbour_channels
    for chanidx = 1:length(EPN_egichans)
        chan_index = str2double(EPN_egichans{chanidx}(2:end));
        tmp = EEG.etc.layout.neighbors(chan_index).neighbors;
        tmp = cellfun(@(x) ['E' num2str(x)], num2cell(tmp), 'UniformOutput', false);
        EPN_egichans = [EPN_egichans; tmp'];
        tmp = {};
    end
    for chanidx = 1:length(LPP_egichans)
        chan_index = str2double(LPP_egichans{chanidx}(2:end));
        tmp = EEG.etc.layout.neighbors(chan_index).neighbors;
        tmp = cellfun(@(x) ['E' num2str(x)], num2cell(tmp), 'UniformOutput', false);
        LPP_egichans = [LPP_egichans; tmp'];
        tmp = {};
    end
    % Remove duplicates
    EPN_egichans_labs = unique(EPN_egichans);
    LPP_egichans_labs = unique(LPP_egichans);
end

% From labels to indices
EPN_egichans = find(ismember({EEG_n.chanlocs.labels}, EPN_egichans_labs));
LPP_egichans = find(ismember({EEG_n.chanlocs.labels}, LPP_egichans_labs));
% plot_chan_clusters(EEG, EPN_egichans, '3d', true)
% plot_chan_clusters(EEG, LPP_egichans, '3d', true)

% Time windows for EPN & LPP
EPN_timewindow = [150 300];   % in ms
LPP_timewindow = [400 900];   % in ms

% EPN -> negative peak
EPN_stats = computeERPcomponent(EEG_n, EEG_u, EPN_egichans, EPN_timewindow, 'negpeak');
plotERPcomponent(EEG_n, EEG_u, EPN_egichans, EPN_timewindow, 'negpeak','EPN ERP');
saveFigs(gcf,fullfile(FIGURES,fname),'EPN',false); if called; close all; end
try
fprintf('\nEPN peak: p=%.4f, t=%.3f (df=%d)\n', EPN_stats.p_peak, EPN_stats.tval_peak, EPN_stats.df_peak);
fprintf('EPN mean: p=%.4f, t=%.3f (df=%d)\n', EPN_stats.p_mean, EPN_stats.tval_mean, EPN_stats.df_mean);
catch; fprintf('Could not compute t-test...\n');
end

% LPP -> positive peak
LPP_stats = computeERPcomponent(EEG_n, EEG_u, LPP_egichans, LPP_timewindow, 'pospeak');
plotERPcomponent(EEG_n, EEG_u, LPP_egichans, LPP_timewindow, 'pospeak','LPP ERP');
saveFigs(gcf,fullfile(FIGURES,fname),'LPP',false); if called; close all; end
try
fprintf('\nLPP peak: p=%.4f, t=%.3f (df=%d)\n', LPP_stats.p_peak, LPP_stats.tval_peak, LPP_stats.df_peak);
fprintf('LPP mean: p=%.4f, t=%.3f (df=%d)\n', LPP_stats.p_mean, LPP_stats.tval_mean, LPP_stats.df_mean);
catch; fprintf('Could not compute t-test...\n');
end

% Export
D = {
'EPN','Nat','PeakAmp', EPN_stats.nat.peak_amp, EPN_stats.nat.peak_lat, EPN_stats.nat.mean_amp
'EPN','Urb','PeakAmp', EPN_stats.urb.peak_amp, EPN_stats.urb.peak_lat, EPN_stats.urb.mean_amp
'LPP','Nat','PeakAmp', LPP_stats.nat.peak_amp, LPP_stats.nat.peak_lat, LPP_stats.nat.mean_amp
'LPP','Urb','PeakAmp', LPP_stats.urb.peak_amp, LPP_stats.urb.peak_lat, LPP_stats.urb.mean_amp
};
tbl = cell2table(D, 'VariableNames',{'Comp','Cond','Metric','Peak','Lat','Mean'});
writetable(tbl, fullfile(DATA,fname,'EPN_LPP_summary.csv'));

% % % % % % % % % % % % % % % % % %
%% Export ERP for source imaging %%
% % % % % % % % % % % % % % % % % %

export2mff = 0;
if export2mff

    % Compute ERP data structure from epoched data (CRUCIAL STEP!)
    EEG_n  = createERPTrial(EEG_n);
    EEG_u  = createERPTrial(EEG_u);
    EEG_nc = createERPTrial(EEG_nc);
    EEG_c  = createERPTrial(EEG_c);
    
    % Now, export to MFF for Net Station
    pop_mffexport(EEG_n, fullfile(DATA, fname, strcat(info.specific.sub,'_nature.mff')));
    pop_mffexport(EEG_u, fullfile(DATA, fname, strcat(info.specific.sub,'_urban.mff')));
    pop_mffexport(EEG_c, fullfile(DATA, fname, strcat(info.specific.sub,'_crowded.mff')));
    pop_mffexport(EEG_nc, fullfile(DATA, fname, strcat(info.specific.sub,'_noncrowded.mff')));

end

% Then export to LORETA Key, using eeglab2loreta
try
    % Import sfp from digitized channel locations
    geoscan_folder = fullfile(sourcedata, 'supp', 'geoscan', info.specific.sub(5:end));
    geoscan_file = dir(fullfile(geoscan_folder, '*.sfp'));
    EEG = pop_chanedit(EEG, 'load',{fullfile(geoscan_folder, geoscan_file(1).name),'filetype','sfp'});
    EEG.chanlocs = EEG.urchanlocs;
    % Loop
    EEG_list = {EEG_n, EEG_u, EEG_c, EEG_nc};
    condition_names = {'condition_n', 'condition_u', 'condition_c', 'condition_nc'};
    timerange = [-200 996];
    [~, minind1] = min(abs(EEG.times-timerange(1)));
    [~, minind2] = min(abs(EEG.times-timerange(2)));
    for i = 1:length(EEG_list)
        % Select the current EEG dataset and condition name
        EEG2exp = EEG_list{i};
        cond_name = condition_names{i};
        mkdir(fullfile(DATA, fname, strcat('loreta_', cond_name)))
        cd(fullfile(DATA, fname, strcat('loreta_', cond_name)))
        eeglab2loreta(EEG2exp.chanlocs, mean(EEG_n.data(:, minind1:minind2, :), 3), 'exporterp', 'on');
        % type erp.txt; type loreta_chanlocs.txt; type loreta_chanlocs.xyz
    end
catch ME
    ME.message; % you most likely need don't have LORETA's plugin installed
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                            Wrapping up                                  %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

cd(scripts); if called; stopLogging(); end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                            Manual checks                                %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

if ~called
    eegplot(EEG_u.data, 'winlength', 2, 'dispchans', 30, 'events', EEG_n.event, 'ploteventdur', 'off')
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                            Functions                                    %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


function tidy_erp_map(h)
    set(h,'xlim',[-200 996])
    set(h, 'clim', [-1 1]* 50)
    xlabel('Time (ms)')
    ylabel('Trials')
    hold on
    plot([0 0],get(h,'ylim'),'k--','linew',3)
    plot([0 0]+500,get(h,'ylim'),'k--','linew',3)
    hold off
    colorbar
    colormap turbo
end

function plot_erps_and_difference(times, erp1, erp2, chan_idx, chan_label, condition1_name, condition2_name)
    % Extract ERPs for the specified channel
    erp_cond1 = erp1(chan_idx, :);
    erp_cond2 = erp2(chan_idx, :);
    diff_erp = erp_cond1 - erp_cond2;
    
    % % Create figure
    % figure('Name', ['Channel ' chan_label], 'NumberTitle', 'off', 'Color', 'w');
    
    % Plot ERPs overlayed
    subplot(4,1,3);
    plot(times, erp_cond1, 'b', 'LineWidth', 2);
    hold on;
    plot(times, erp_cond2, 'r', 'LineWidth', 2);
    xlabel('Time (ms)', 'FontSize', 12);
    ylabel('Amplitude (\muV)', 'FontSize', 12);
    title(['ERPs at Channel ' chan_label], 'FontSize', 14, 'FontWeight', 'bold');
    legend(condition1_name, condition2_name, 'FontSize', 12, 'Location', 'northwest');
    legend(BackgroundAlpha=.7)
    grid on;
    xlim([-200, times(end)]);
    
    % Plot difference ERP
    subplot(4,1,4);
    plot(times, diff_erp, 'k', 'LineWidth', 2);
    xlabel('Time (ms)', 'FontSize', 12);
    ylabel('Amplitude Difference (\muV)', 'FontSize', 12);
    title(['Difference ERP at Channel ' chan_label], 'FontSize', 14, 'FontWeight', 'bold');
    grid on;
    xlim([-200, times(end)]);
end

function stats = computeERPcomponent(EEG_n, EEG_u, chans, tw, peaktype)
    % Compute mean amplitude and peak amplitude+latency across trials for both Natural/Urban.
    % peaktype='negpeak' uses min(); 'pospeak' uses max().
    % stats for each condition: .mean_amp, .peak_amp, .peak_lat, plus per-trial arrays.
    
    stats = struct('nat',[],'urb',[]);
    stats.nat = erpPerCondition(EEG_n, chans, tw, peaktype);
    stats.urb = erpPerCondition(EEG_u, chans, tw, peaktype);
    
    % if EEG_n.trials ~= EEG_u.trials
    %     n_trials_min = min(EEG_n.trials, EEG_u.trials);
    %     rng('default'); % Setting the random seed for reproducibility
    %     % Generate random permutations of trial indices for each condition
    %     selected_trials_nature = randperm(EEG_n.trials, n_trials_min);
    %     selected_trials_urban  = randperm(EEG_u.trials, n_trials_min);
    % end
    
    try
    [~, p, ~, tstat] = ttest(stats.nat.perTrial_peakAmp, stats.urb.perTrial_peakAmp);
    stats.p_peak    = p;
    stats.tval_peak = tstat.tstat;
    stats.df_peak   = tstat.df;
    
    [~, p2, ~, tstat2] = ttest(stats.nat.perTrial_meanAmp, stats.urb.perTrial_meanAmp);
    stats.p_mean    = p2;
    stats.tval_mean = tstat2.tstat;
    stats.df_mean   = tstat2.df;
    catch; fprintf('Different number of trials...\n');
    end
    
    stats.used_chanidx = chans;
    stats.used_timewin = tw;
    stats.peaktype     = peaktype;
end

function sc = erpPerCondition(EEG, chans, tw, peaktype)

    % Init vars
    ERP = mean(EEG.data,3);
    times = EEG.times; 
    [~, i1] = min(abs(times - tw(1)));
    [~, i2] = min(abs(times - tw(2)));
    
    % Get peak and latency
    x = ERP(chans, i1:i2);
    x = mean(x,1);
    switch peaktype
        case 'negpeak'
            [pk, idx] = min(x);
        case 'pospeak'
            [pk, idx] = max(x);
        otherwise
            error('peaktype must be ''negpeak'' or ''pospeak''.');
    end
    Peak = pk;
    Lat  = times(i1 + idx - 1);
    Mean = mean(x);
    
    % Save in struct
    sc.mean_amp         = Mean;
    sc.peak_amp         = Peak;
    sc.peak_lat         = Lat;
end

function [GA, lowCI, highCI] = erpWithCI(EEG, chans)
    times = EEG.times; 
    nPts  = length(times);
    nTr   = size(EEG.data,3);
    m     = zeros(nTr, nPts);
    for t=1:nTr
        tmp = EEG.data(chans, :, t);
        m(t,:) = mean(tmp,1);
    end
    GA = mean(m,1);
    sem= std(m,0,1)/sqrt(nTr);
    lowCI = GA - 1.96*sem;
    highCI= GA + 1.96*sem;
end

function plotERPcomponent(EEG_n, EEG_u, chans, tw, peaktype, figname)
    [GA_n, ciN_l, ciN_h] = erpWithCI(EEG_n, chans);
    [GA_u, ciU_l, ciU_h] = erpWithCI(EEG_u, chans);
    times = EEG_n.times;
    figure('Name', figname, 'Color','w','Position',[100,100,600,400]);
    hold on
    fill([times fliplr(times)],[ciN_l fliplr(ciN_h)],'b','FaceAlpha',0.1,'EdgeColor','none');
    plot(times,GA_n,'b','LineWidth',2);
    fill([times fliplr(times)],[ciU_l fliplr(ciU_h)],'r','FaceAlpha',0.1,'EdgeColor','none');
    plot(times,GA_u,'r','LineWidth',2);
    xline(0,'k--'); grid on;
    legend({'Nat 95%CI','Natural','Urb 95%CI','Urban'},'Location','best');
    title([figname ' (' peaktype ')']);
    xlabel('Time (ms)'); ylabel('\muV');
    yl=ylim;
    patchHandle = patch('XData',[tw(1) tw(2) tw(2) tw(1)], ...
                        'YData',[yl(1) yl(1) yl(2) yl(2)], ...
                        'FaceColor',[.9 .9 .9], ...
                        'FaceAlpha',0.5, ...
                        'EdgeColor','none');
    % Exclude the patch from the legend
    patchHandle.Annotation.LegendInformation.IconDisplayStyle = 'off';
    uistack(findobj(gca,'Type','line'),'top');
    ylim(yl);
    grid off
end

% Function to process EEGLAB EEG structure and create an ERP trial
function EEG_erp = createERPTrial(EEG)

    % Compute ERP (average across trials)
    ERP_data = mean(EEG.data, 3); % Average across the 3rd dimension (trials)

    % Create a new EEG structure for the ERP
    EEG_erp = EEG; % Copy the original EEG structure
    EEG_erp.data = ERP_data; % Replace data with the ERP
    EEG_erp.trials = 1; % Set number of trials to 1
    EEG_erp.event = []; % Clear events (not applicable for ERP)
    EEG_erp.epoch = []; % Clear epoch structure

    % Update time and size-related fields
    EEG_erp.pnts = size(ERP_data, 2); % Number of points in one trial
    EEG_erp.xmin = EEG.xmin; % Start time (unchanged)
    EEG_erp.xmax = EEG.xmax; % End time (unchanged)

    % Check set
    EEG_erp = eeg_checkset(EEG_erp);
    EEG_erp = eeg_checkset(EEG_erp,'eventconsistency');
end