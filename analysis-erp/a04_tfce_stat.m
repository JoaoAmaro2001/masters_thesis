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

% % % % % % % % % % % %
%% Define neighbours %%
% % % % % % % % % % % %

if strcmpi(mcfg.analysis.channels.neighbors_matrix,'egi')

    % 1st option - using mff layout info. only eeglab required
    neighbours = struct();
    for chanind = 1:length(EEG.etc.layout.neighbors)
        neighbours(chanind).label = ['E' num2str(chanind)];
        tmp = EEG.etc.layout.neighbors(chanind).neighbors;
        neighbours(chanind).neighblabel = cellfun(@(x) ['E' num2str(x)], num2cell(tmp), 'UniformOutput', false);
    end

elseif strcmpi(mcfg.analysis.channels.neighbors_matrix,'triangulation')

    % 2st option - using default fieldtrip layout file with triangulation
    % method (might have to delete fiducials)
    cfg = [];
    cfg.layout = 'GSN-HydroCel-257.mat';
    cfg.method = 'triangulation';
    cfg.compress = 'yes';
    cfg.feedback = 'yes';
    neighbours = ft_prepare_neighbours(cfg);

elseif strcmpi(mcfg.analysis.channels.neighbors_matrix,'distance')

    % 3rd option - using default fieldtrip layout file with distance
    % method (might have to delete fiducials)
    cfg = [];
    cfg.layout = 'GSN-HydroCel-257.mat';
    cfg.method = 'distance';
    cfg.feedback = 'yes';
    neighbours = ft_prepare_neighbours(cfg);    

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%% Compute cluster-based permutation test for first condition  %%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

cfg = [];
cfg.channel          = 'all';                     % Use all channels
cfg.latency          = 'all';                     % Use all time points
cfg.parameter        = 'trial';                   % Between-trial analysis
cfg.method           = 'montecarlo';              % Monte Carlo method
cfg.statistic        = 'indepsamplesT';           % Dependent samples T-test
cfg.correctm         = 'tfce';                    % TFCE correction
cfg.clusteralpha     = 0.05;                      % Alpha level for cluster formation
cfg.clusterstatistic = 'maxsum';                  % Test statistic for clusters
cfg.minnbchan        = 2;                         % Minimum number of neighboring channels
cfg.tail             = 0;                         % Two-tailed test
cfg.clustertail      = 0;
cfg.alpha            = 0.025;                     % Since we are testing two tails
cfg.numrandomization = 500;                      % Number of permutations
cfg.neighbours       = neighbours;                % Neighboring channels structure

% Create the design matrix for the statistical test
design = zeros(1,size(timelock_n.trial,1) + size(timelock_u.trial,1));
design(1,1:size(timelock_n.trial,1)) = 1;
design(1,(size(timelock_n.trial,1)+1):(size(timelock_n.trial,1)+...
size(timelock_u.trial,1))) = 2;

cfg.design = design;
cfg.ivar   = 1; % Independent variable (trials)

stat_natural_urban = ft_timelockstatistics(cfg, timelock_n, timelock_u);
save(fullfile(DATA,fname,'stat_natural_urban_clusstats.mat'), 'stat_natural_urban');

% % % % % % % % % % % %
%% Plot the results  %%
% % % % % % % % % % % %

% Plot masked statistics
try
    % Optional: visualize the significant clusters
    cfg = [];
    cfg.alpha  = 0.05; % Alpha level for plotting
    cfg.parameter = 'stat';
    cfg.layout = 'GSN-HydroCel-257.mat'; % Use the same layout for visualization
    ft_clusterplot(cfg, stat_natural_urban);
    saveFigs(gcf, fullfile(FIGURES,fname), 'Significant_clusters_natural_urban',false);    
catch ME
    ME.message;
    fprintf('No significant clusters found for condition natural vs urban!\n')
end

figure;
imagesc(linspace(-200, 996, 300), 1:257, stat_natural_urban.mask);
colormap('jet'); % Use more steps for smooth gradient
colorbar;
hold on;
plot([0 0], ylim, 'k--', 'LineWidth', 1.5);
xlabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold'); % X-axis label
ylabel('EEG Channels', 'FontSize', 12, 'FontWeight', 'bold'); % Y-axis label
title('EEG Statistical Map', 'FontSize', 14, 'FontWeight', 'bold'); % Title
c = colorbar;
c.Label.String = 't-value';
c.Label.FontSize = 12;
c.Label.FontWeight = 'bold';
set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'Box', 'on', 'LineWidth', 1.2);
set(gca, 'YDir', 'normal'); % Ensure normal orientation
xlim([-200, 996]);
ylim([1, 257]);
saveFigs(gcf, fullfile(FIGURES,fname), 'Masked_map_stat_natural_urban',false);

% Plot displaying t- and p-value distribution across channels and time
plot_clus = zeros(size(stat_natural_urban.prob));
plot_clus(stat_natural_urban.negclusterslabelmat==1) = -1; % negative cluster
plot_clus(stat_natural_urban.posclusterslabelmat==1) =  1; % positive cluster

figure
subplot(2,1,1)
imagesc(stat_natural_urban.time, 1:size(stat_natural_urban.label,1),plot_clus)
colormap(jet)
colorbar
title('Largest positive and negative cluster');
subplot(2,1,2)
imagesc(stat_natural_urban.time, 1:size(stat_natural_urban.label,1),  stat_natural_urban.stat)
colorbar
title('T-values per channel x time');
saveFigs(gcf, fullfile(FIGURES,fname), 'T_and_Pvalues_stat_natural_urban_clusstats',false);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%% Compute cluster-based permutation test for second condition %%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

cfg = [];
cfg.channel          = 'all';                     % Use all channels
cfg.latency          = [-0.2 1];                  % Use all time points
cfg.parameter        = 'trial';                   % Between-trial analysis
cfg.method           = 'montecarlo';              % Monte Carlo method
cfg.statistic        = 'indepsamplesT';           % Dependent samples T-test
cfg.correctm         = 'cluster';                 % TFCE correction
cfg.clusteralpha     = 0.05;                      % Alpha level for cluster formation
cfg.clusterstatistic = 'maxsum';                  % Test statistic for clusters
cfg.minnbchan        = 2;                         % Minimum number of neighboring channels
cfg.tail             = 0;                         % Two-tailed test
cfg.clustertail      = 0;
cfg.alpha            = 0.025;                     % Since we are testing two tails
cfg.numrandomization = 1000;                      % Number of permutations
cfg.neighbours       = neighbours;                % Neighboring channels structure

% Create the design matrix for the statistical test
design = zeros(1,size(timelock_c.trial,1) + size(timelock_nc.trial,1));
design(1,1:size(timelock_c.trial,1)) = 1;
design(1,(size(timelock_c.trial,1)+1):(size(timelock_c.trial,1)+...
size(timelock_nc.trial,1))) = 2;

cfg.design = design;
cfg.ivar   = 1; % Independent variable (trials)

stat_crowded_noncrowded = ft_timelockstatistics(cfg, timelock_n, timelock_u);
save(fullfile(DATA,fname,'stat_crowded_noncrowded_clusstats.mat'), 'stat_crowded_noncrowded');

% % % % % % % % % % % %
%% Plot the results  %%
% % % % % % % % % % % %

% Plot masked statistics
try
    % Optional: visualize the significant clusters
    cfg = [];
    cfg.alpha  = 0.05; % Alpha level for plotting
    cfg.parameter = 'stat';
    cfg.layout = 'GSN-HydroCel-257.mat'; % Use the same layout for visualization
    ft_clusterplot(cfg, stat_crowded_noncrowded);
    saveFigs(gcf, fullfile(FIGURES,fname), 'Significant_clusters_crowded_noncrowded',false);    
catch ME
    ME.message;
    fprintf('No significant clusters found for condition crowded vs non-crowded!\n')
end

figure;
imagesc(linspace(-200, 996, 300), 1:257, stat_crowded_noncrowded.mask);
colormap('jet'); % Use more steps for smooth gradient
colorbar;
hold on;
plot([0 0], ylim, 'k--', 'LineWidth', 1.5);
xlabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold'); % X-axis label
ylabel('EEG Channels', 'FontSize', 12, 'FontWeight', 'bold'); % Y-axis label
title('EEG Statistical Map', 'FontSize', 14, 'FontWeight', 'bold'); % Title
c = colorbar;
c.Label.String = 't-value';
c.Label.FontSize = 12;
c.Label.FontWeight = 'bold';
set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'Box', 'on', 'LineWidth', 1.2);
set(gca, 'YDir', 'normal'); % Ensure normal orientation
xlim([-200, 996]);
ylim([1, 257]);
saveFigs(gcf, fullfile(FIGURES,fname), 'Masked_map_stat_crowded_noncrowded',false);

% Plot displaying t- and p-value distribution across channels and time
plot_clus = zeros(size(stat_crowded_noncrowded.prob));
plot_clus(stat_crowded_noncrowded.negclusterslabelmat==1) = -1; % negative cluster
plot_clus(stat_crowded_noncrowded.posclusterslabelmat==1) =  1; % positive cluster

figure
subplot(2,1,1)
imagesc(stat_crowded_noncrowded.time, 1:size(stat_crowded_noncrowded.label,1),plot_clus)
colormap(jet)
colorbar
title('Largest positive and negative cluster');
subplot(2,1,2)
imagesc(stat_crowded_noncrowded.time, 1:size(stat_crowded_noncrowded.label,1),  stat_crowded_noncrowded.stat)
colorbar
title('T-values per channel x time');
saveFigs(gcf, fullfile(FIGURES,fname), 'T_and_Pvalues_stat_crowded_noncrowded_clusstats',false);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                            Wrapping up                                  %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
close all
if called; stopLogging(); end
