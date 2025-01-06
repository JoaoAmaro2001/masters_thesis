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

% % % % % % % % % % % % % % % % % % % % % % %
%% Within-trials analysis for time-domain  %%
% % % % % % % % % % % % % % % % % % % % % % %

% Get active data
cfg = [];
cfg.toilim = [0 1];
natural_activation = ft_redefinetrial(cfg, timelock_n);

% Get baseline data
cfg = [];
cfg.toilim = [-1.0 -0.005];
natural_baseline = ft_redefinetrial(cfg, timelock_n);

% Assert same time vector
natural_baseline.time = natural_activation.time;

% Permutation
cfg = [];
cfg.channel          = 'all';
cfg.latency          = 'all';
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_actvsblT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 1000;
cfg.neighbours       = neighbours;   

% design
ntrials                       = size(natural_activation.trial,1);
design                        = zeros(2,2*ntrials);
design(1,1:ntrials)           = 1;
design(1,ntrials+1:2*ntrials) = 2;
design(2,1:ntrials)           = 1:ntrials;
design(2,ntrials+1:2*ntrials) = 1:ntrials;
cfg.design                    = design;
cfg.ivar                      = 1;
cfg.uvar                      = 2;

% Compute
[stat_time] = ft_timelockstatistics(cfg, natural_activation, natural_baseline);
save(fullfile(DATA,fname,'within_trial_nature_clusstats_time.mat'), 'stat_time');

% Plot masked statistics
try
    % Optional: visualize the significant clusters
    cfg = [];
    cfg.alpha  = 0.05; % Alpha level for plotting
    cfg.parameter = 'stat';
    cfg.layout = 'GSN-HydroCel-257.mat'; % Use the same layout for visualization
    ft_clusterplot(cfg, stat_time);
    saveFigs(gcf, fullfile(FIGURES,fname), 'Significant_clusters_crowded_noncrowded',false);    
catch ME
    ME.message;
    fprintf('No significant clusters found for condition crowded vs non-crowded!')
end


% % % % % % % % % % % % % % % % % % % % % % % % %
%% Within-trials analysis for frequency-domain %%
% % % % % % % % % % % % % % % % % % % % % % % % %

% Compute freqs
cfg = [];
cfg.output = 'pow';
cfg.channel = 'all';
cfg.method = 'mtmconvol';
cfg.taper = 'hanning';
cfg.foi = 1:30;               % Frequencies of interest (1 to 30 Hz)
cfg.t_ftimwin = 3 ./ cfg.foi; % Sliding time window (7 cycles per frequency)
cfg.toi = natural_baseline.time;      % Time points of interest (start to end of epoch)
cfg.pad = 'nextpow2';         % Padding to the next power of 2 for FFT
cfg.keeptrials = 'yes';       % Keep individual trials

freq_natural_activation  = ft_freqanalysis(cfg, natural_activation);
freq_baseline_activation = ft_freqanalysis(cfg, natural_baseline);

% Permutation
cfg = [];
cfg.channel          = study.eeg.channels.clusters.frontal;
cfg.avgoverchan      = 'yes';
cfg.latency          = 'all';
cfg.method           = 'montecarlo';
cfg.frequency        = 'all';
cfg.statistic        = 'ft_statfun_actvsblT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 5000;
cfg.neighbours       = neighbours;

cfg.design   = design;
cfg.ivar     = 1;
cfg.uvar     = 2;

[stat_freq] = ft_freqstatistics(cfg, freq_natural_activation, freq_baseline_activation);
save(fullfile(DATA,fname,'within_trial_nature_clusstats_freq.mat'), 'stat_freq');

% Plot masked statistics
try
    % Optional: visualize the significant clusters
    cfg = [];
    cfg.alpha  = 0.05; % Alpha level for plotting
    cfg.parameter = 'stat';
    cfg.layout = 'GSN-HydroCel-257.mat'; % Use the same layout for visualization
    ft_clusterplot(cfg, stat_freq);
    saveFigs(gcf, fullfile(FIGURES,fname), 'Significant_clusters_nature_freq',false);    
catch ME
    ME.message;
    fprintf('No significant clusters found for condition nature!\n')
end

figure;
imagesc(squeeze(stat_freq.stat));
colormap('jet'); % Use more steps for smooth gradient
colorbar;
hold on;
xlabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold'); % X-axis label
ylabel('Frequencies', 'FontSize', 12, 'FontWeight', 'bold'); % Y-axis label
title('EEG Statistical Map', 'FontSize', 14, 'FontWeight', 'bold'); % Title
c = colorbar;
c.Label.String = 't-value';
c.Label.FontSize = 12;
c.Label.FontWeight = 'bold';
set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'Box', 'on', 'LineWidth', 1.2);
set(gca, 'YDir', 'normal'); % Ensure normal orientation
saveFigs(gcf, fullfile(FIGURES,fname), 'T_map_stat_natural',false);

try
    % Plot displaying t- and p-value distribution across channels and time
    plot_clus = zeros(size(stat_freq.prob));
    plot_clus(stat_freq.negclusterslabelmat==1) = -1; % negative cluster
    plot_clus(stat_freq.posclusterslabelmat==1) =  1; % positive cluster
    
    figure
    subplot(2,1,1)
    imagesc(stat_freq.time, 1:size(stat_freq.label,1),plot_clus)
    colormap(jet)
    colorbar
    title('Largest positive and negative cluster');
    subplot(2,1,2)
    imagesc(stat_freq.time, 1:size(stat_freq.label,1),  stat_freq.stat)
    colorbar
    title('T-values per channel x time');
    saveFigs(gcf, fullfile(FIGURES,fname), 'T_and_Pvalues_stat_natural_clusstats',false);
catch ME
    ME.message;
    fprintf('No clusters...\n')
end

% % % % % % % % % % % % % % % % % % % % % % % % %
%% Within-trials analysis for frequency-domain %%
% % % % % % % % % % % % % % % % % % % % % % % % %


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                            Wrapping up                                  %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

if called; stopLogging(); end