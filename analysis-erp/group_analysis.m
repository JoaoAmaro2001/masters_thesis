%% Helpers

% clear all; clc; close all
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
config_exp2;
eeglab; ft_defaults; close all;
dir2get = fullfile(study.path.scripts, 'analysis', 'analysis-erp');
cd(dir2get); config_ana_erp; cd(scripts);
datename  = char(datetime, 'yyyyMMdd_HHmmss');
mkdir(fullfile(GROUPFIGURES,datename)); 
mkdir(fullfile(GROUPDATA,datename));
mkdir(fullfile(GROUPLOGS,datename));
called    = manualOrCalled(); 
if called; startLogging(fullfile(GROUPLOGS, datename,'cli')); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% Parameters
from_scratch = 0; % truncates list of scripts to run
studies = {'exp2'}; % or 'exp2opt'

% Preprocessing scripts' names
dirlist     = dir(dir2get);
dirlist     = {dirlist.name};
dirlist     = dirlist(startsWith(dirlist,'a') & endsWith(dirlist,'.m'));
dirlist     = sort(dirlist); 
tmp_dirlist = dirlist;
if ~from_scratch 
    tmp_dirlist = dirlist(1:4); % change here upper and lower scripts
end

% Loop over single subjects from the various studies
fprintf('\n')
disp('------------------------------------')
disp ('Doing group analysis')
disp('------------------------------------')
fprintf('\n')

for expi=1:length(studies)
    
    if strcmpi(studies{expi},'exp2')
        clear study info BIDS
        setpath_exp2;
        config_exp2;
        t           = readtable([bidsroot filesep 'participants.tsv'], 'FileType', 'text');
        subjectlist = t.participant_id;        
    elseif strcmpi(studies{expi},'exp2opt')
        clear study info BIDS
        setpath_exp2_optimized;
        config_exp2opt;
        t           = readtable([bidsroot filesep 'participants.tsv'], 'FileType', 'text');
        subjectlist = t.participant_id;
    end

    for subi = 1:size(subjectlist,1)
    
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
        %                            Progress Bar                             %
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        updateProgressBar(subi,size(subjectlist,1))
        % ---------------------------------------------------------------------  
        
        % Fetch subject (both studies) ------------------------------------
        info.process.sub = subjectlist{subi}(5:end);
        % -----------------------------------------------------------------

        % ---------------------------------------------------------------------          
        if strcmpi(studies{expi},'exp2') % Run for exp.2
            cd(dir2get); config_ana_erp; % run pipeline config
            for scripti = 1:length(tmp_dirlist)
                updateProgressBarSimple(scripti,length(tmp_dirlist)) % update progress bar
                run(fullfile(dir2get,tmp_dirlist{scripti})); % run file
            end % end scripts loop
        end
        % ---------------------------------------------------------------------  
    
    end % end subject loop

end % end study loop

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
if called; stopLogging(); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Add scripts to grouplog

% Add current script
copyfile(fullfile(dir2get, fname), fullfile(GROUPLOGS, datename, fname));
% Add analysis scripts
for i = 1:length(tmpdirlist)
    script_name = tmpdirlist{i};
    script_path = fullfile(dir2get, script_name);
    destination_path = fullfile(GROUPLOGS, datename, script_name);
    if exist(script_path, 'file')
        copyfile(script_path, destination_path);
        fprintf('Copied: %s to %s\n', script_path, destination_path);
    else
        warning('File not found: %s', script_path);
    end
end

% Add second-level scripts


% % % % % % 
return  %
% % % % % % 

% % % % % % % % %
%% Fetch data  %%
% % % % % % % % %

% Two main statistical approaches for this study:
% Group statistics -> ERP prior parametric approach 
% Group statistics -> Full epoch non-parametric approach 

% Studies from which to get data
studies = {'exp2', 'exp2opt'}
% init condition variables (1st approch)
erps_natural    = {};
erps_urban      = {};
erps_crowded    = {};
erps_noncrowded = {};
% Init table in long format for ERP metrics (Sub, Condition, PeakAmp, PeakLat)
epn_table = table();
lpp_table = table();

% Get output from results folders
for studidx=1:length(studies)
    if strcmpi(studies{studidx},'exp2')
        setpath_exp2;
        t             = readtable([bidsroot filesep 'participants.tsv'], 'FileType', 'text');
        subjectlist   = t.participant_id;   
        for subidx = 1:length(subjectlist)
            if contains(mcfg.analysis.subjects_to_remove, subjectlist{subidx})
                continue;
            else
            % first approach
            data_folder   = fullfile(results, 'analysis_erp_pipeline-esi_literature', subjectlist{subidx}, 'data', 'a03_ft_conversion.m')        
            load(fullfile(data_folder, 'timelock_natural.mat'))
            [~,c,~] = size(timelock_n.trial); if c~=257; error('CHECK CHANS'); end
            erps_natural{end+1} = timelock_n;
            load(fullfile(data_folder, 'timelock_urban.mat'))
            [~,c,~] = size(timelock_u.trial); if c~=257; error('CHECK CHANS'); end
            erps_urban{end+1} = timelock_u;
            load(fullfile(data_folder, 'timelock_crowded.mat'))
            [~,c,~] = size(timelock_c.trial); if c~=257; error('CHECK CHANS'); end
            erps_crowded{end+1} = timelock_c;
            load(fullfile(data_folder, 'timelock_noncrowded.mat'))
            [~,c,~] = size(timelock_nc.trial); if c~=257; error('CHECK CHANS'); end
            erps_noncrowded{end+1} = timelock_nc;
            % second approach
            erp_metrics_folder = fullfile(results, 'analysis_erp_pipeline-esi_literature', subjectlist{subidx}, 'data', 'a02_compute_export_erp.m')
            erp_tab = readtable(fullfile(erp_metrics_folder, 'EPN_LPP_summary.csv'))
            erp_tab.Subject = repmat(string(subjectlist{subidx}), height(erp_tab),1);
            % Partition EPN rows vs. LPP rows
            epnMask = strcmp(erp_tab.Comp,'EPN');
            lppMask = strcmp(erp_tab.Comp,'LPP');
            % Append to the big table
            epn_table = [epn_table; erp_tab(epnMask,:)]; 
            lpp_table = [lpp_table; erp_tab(lppMask,:)]; 
            end
        end
    elseif strcmpi(studies{studidx},'exp2opt')
        setpath_exp2_optimized;
        t             = readtable([bidsroot filesep 'participants.tsv'], 'FileType', 'text');
        subjectlist   = t.participant_id;   
        for subidx = 1:length(subjectlist)
            data_folder   = fullfile(results, 'analysis_erp_pipeline-esi_literature', subjectlist{subidx}, 'data', 'a03_ft_conversion.m')                  
            load(fullfile(data_folder, 'timelock_natural.mat'))
            [~,c,~] = size(timelock_n.trial); if c~=257; error('CHECK CHANS'); end
            erps_natural{end+1} = timelock_n;
            load(fullfile(data_folder, 'timelock_urban.mat'))
            [~,c,~] = size(timelock_u.trial); if c~=257; error('CHECK CHANS'); end
            erps_urban{end+1} = timelock_u;
            load(fullfile(data_folder, 'timelock_crowded.mat'))
            [~,c,~] = size(timelock_u.trial); if c~=257; error('CHECK CHANS'); end
            erps_crowded{end+1} = timelock_c;
            load(fullfile(data_folder, 'timelock_noncrowded.mat'))
            [~,c,~] = size(timelock_nc.trial); if c~=257; error('CHECK CHANS'); end
            erps_noncrowded{end+1} = timelock_nc;
            % second approach
            erp_metrics_folder = fullfile(results, 'analysis_erp_pipeline-esi_literature', subjectlist{subidx}, 'data', 'a02_compute_export_erp.m')
            erp_tab = readtable(fullfile(erp_metrics_folder, 'EPN_LPP_summary.csv'))
            erp_tab.Subject = repmat(string(subjectlist{subidx}), height(erp_tab),1);
            % Partition EPN rows vs. LPP rows
            epnMask = strcmp(erp_tab.Comp,'EPN');
            lppMask = strcmp(erp_tab.Comp,'LPP');
            % Append to the big table
            epn_table = [epn_table; erp_tab(epnMask,:)]; 
            lpp_table = [lpp_table; erp_tab(lppMask,:)];            
        end
    end
end

% Tidy erp table and export
writetable(epn_table, fullfile(GROUPDATA,'epn_table_long.csv'));
writetable(lpp_table, fullfile(GROUPDATA,'lpp_table_long.csv'));

% % % % % % % % % % % % % % % % % % %
%% Compute and plot Grand average  %%
% % % % % % % % % % % % % % % % % % %

% Number of subjects
n_subjects = 29;

% Initialize cell arrays to store averaged data
avg_erps_natural    = cell(1, n_subjects);
avg_erps_urban      = cell(1, n_subjects);
avg_erps_noncrowded = cell(1, n_subjects);
avg_erps_crowded    = cell(1, n_subjects);

% Loop over each subject
for subj = 1:n_subjects

    % Compute the average for the noncrowded condition
    cfg = [];
    avg_erps_natural{subj} = ft_timelockanalysis(cfg, erps_natural{subj});

     % Compute the average for the noncrowded condition
    cfg = [];
    avg_erps_urban{subj} = ft_timelockanalysis(cfg, erps_urban{subj});

    % Compute the average for the noncrowded condition
    cfg = [];
    avg_erps_noncrowded{subj} = ft_timelockanalysis(cfg, erps_noncrowded{subj});
    
    % Compute the average for the crowded condition
    cfg = [];
    avg_erps_crowded{subj} = ft_timelockanalysis(cfg, erps_crowded{subj});
end

all_data_nu  = [avg_erps_natural, avg_erps_urban];      % Should have 60 elements
all_data_cnc = [avg_erps_noncrowded, avg_erps_crowded]; % Should have 60 elements

% % % % % % % % % % % % % % % % % % %
%% Cluster-Based Permutation Test  %%
% % % % % % % % % % % % % % % % % % %

% load neighbours (save(GROUPDATA, 'neighbours'))
load(fullfile(GROUP, 'neighbours.mat'))
cfg = [];
cfg.channel          = 'all'; % Use all channels
cfg.latency          = 'all';                     % Use all time points
cfg.parameter        = 'avg'                    % Use trials or average (2nd level)
cfg.method           = 'montecarlo';              % Monte Carlo method
cfg.statistic        = 'ft_statfun_depsamplesT';  % Dependent samples T-test
cfg.correctm         = 'tfce';                    % TFCE correction
% cfg.clusteralpha     = 0.05;                      % Alpha level for cluster formation
cfg.clustertail      = 0;                         % Two-tailed test
% cfg.clusterstatistic = 'maxsum';                  % Test statistic for clusters
% cfg.minnbchan        = 2;                         % Minimum number of neighboring channels
cfg.alpha            = 0.05;                     % Since we are testing two tails
cfg.tail             = 0;                         % Two-tailed test
cfg.numrandomization = 50000;                      % Number of permutations
cfg.neighbours       = neighbours;                % Neighboring channels structure

% Create the design matrix for the statistical test
design = zeros(2, 2 * n_subjects);
design(1, 1:n_subjects) = 1:n_subjects;          % Subject indices for condition 1
design(1, n_subjects + 1:2 * n_subjects) = 1:n_subjects; % Subject indices for condition 2
design(2, 1:n_subjects) = 1;                     % Condition labels (1 for nature)
design(2, n_subjects + 1:2 * n_subjects) = 2;    % Condition labels (2 for urban)

cfg.design = design;
cfg.uvar   = 1; % Unit of observation (subjects) - ignore for independent t-test
cfg.ivar   = 2; % Independent variable (conditions)

% Perform the Statistical Test
stat = ft_timelockstatistics(cfg, all_data_nu{:});
save(fullfile(GROUPDATA,datename,'stat_avg_nu'), 'stat')

% Optional: visualize the significant clusters
cfg = [];
cfg.alpha  = 0.05; % Alpha level for plotting
cfg.parameter = 'stat';
cfg.layout = 'GSN-HydroCel-257.mat'; % Use the same layout for visualization
ft_clusterplot(cfg, stat);

% figure;imagesc(stat.stat)
figure;
imagesc(linspace(-200, 996, 300),[1,257], stat.stat);
colormap(bluewhitered(32));
colorbar;
hold on;
plot([0 0], [1, 257], 'k--', 'LineWidth', 2); % Dashed vertical line at x=50
xlabel('Time (ms)'); % X-axis label
ylabel('EEG Channels'); % Y-axis label
title('Statistical Map of EEG Channels'); % Title
set(gca, 'YDir', 'normal'); % Flip the Y-axis to normal orientation if needed

figure;
imagesc(linspace(-200, 996, 300), 1:257, stat.stat);
colormap(bluewhitered(64)); % Use more steps for smooth gradient
colorbar;
hold on;

% Add a dashed vertical line at x=50
plot([50 50], ylim, 'k--', 'LineWidth', 1.5);

% Add labels and title
xlabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold'); % X-axis label
ylabel('EEG Channels', 'FontSize', 12, 'FontWeight', 'bold'); % Y-axis label
title('EEG Statistical Map', 'FontSize', 14, 'FontWeight', 'bold'); % Title

% Adjust colorbar label
c = colorbar;
c.Label.String = 't-value';
c.Label.FontSize = 12;
c.Label.FontWeight = 'bold';

% Set axis properties for clarity
set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'Box', 'on', 'LineWidth', 1.2);
set(gca, 'YDir', 'normal'); % Ensure normal orientation

% Fine-tune axes and layout
xlim([-200, 996]);
ylim([1, 257]);

figure;

% Original statistical map
subplot(1, 2, 1);
imagesc(linspace(-200, 996, 300), 1:257, stat.stat);
colormap(bluewhitered(64));
colorbar;
hold on;

% Dashed vertical line at x=50
plot([0 0], ylim, 'k--', 'LineWidth', 1.5);

% Labels and title
xlabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('EEG Channels', 'FontSize', 12, 'FontWeight', 'bold');
title('EEG Statistical Map', 'FontSize', 14, 'FontWeight', 'bold');

% Adjust colorbar label
c1 = colorbar;
c1.Label.String = 't-value';
c1.Label.FontSize = 12;
c1.Label.FontWeight = 'bold';

% Set axis properties
set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'Box', 'on', 'LineWidth', 1.2);
set(gca, 'YDir', 'normal');
xlim([-200, 996]);
ylim([1, 257]);

% Masked statistical map (significant points)
subplot(1, 2, 2);
imagesc(linspace(-200, 996, 300), 1:257, stat.stat .* stat.mask);
colormap(bluewhitered(64));
colorbar;
hold on;

% Dashed vertical line at x=50
plot([0 0], ylim, 'k--', 'LineWidth', 1.5);

% Labels and title
xlabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('EEG Channels', 'FontSize', 12, 'FontWeight', 'bold');
title('Significant Points (Masked)', 'FontSize', 14, 'FontWeight', 'bold');

% Adjust colorbar label
c2 = colorbar;
c2.Label.String = 't-value (Masked)';
c2.Label.FontSize = 12;
c2.Label.FontWeight = 'bold';

% Set axis properties
set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'Box', 'on', 'LineWidth', 1.2);
set(gca, 'YDir', 'normal');
xlim([-200, 996]);
ylim([1, 257]);

% Overall layout
sgtitle('EEG Statistical Analysis', 'FontSize', 16, 'FontWeight', 'bold');

% % % % % % % % % %
%% Grand-average %%
% % % % % % % % % %

% Concatenate trials for each condition
cfg = [];
countidx = 1;
dataset_num_natural = length(erps_natural)
while countidx<=dataset_num_natural
    if countidx==1
        natural_trials = erps_natural{countidx};
        urban_trials = erps_urban{countidx};
        crowded_trials = erps_crowded{countidx};
        noncrowded_trials = erps_noncrowded{countidx};
        countidx = countidx + 1;
    else
        natural_trials = ft_appendtimelock(cfg, natural_trials, erps_natural{countidx});
        urban_trials = ft_appendtimelock(cfg, urban_trials, erps_urban{countidx});
        crowded_trials = ft_appendtimelock(cfg, crowded_trials, erps_crowded{countidx});
        noncrowded_trials = ft_appendtimelock(cfg, noncrowded_trials, erps_noncrowded{countidx});
        countidx = countidx + 1;
    end
end

% % Get the number of trials for both analysis
% n_trials_nature = size(natural_trials.trial, 1);
% n_trials_urban  = size(urban_trials.trial, 1);
% n_trials_crowded = size(crowded_trials.trial, 1);
% n_trials_noncrowded = size(noncrowded_trials.trial, 1);
% nat_urb_trials_min = min([n_trials_nature, n_trials_urban]);
% crowd_nocrowd_trials_min = min([n_trials_crowded, n_trials_noncrowded]);
% 
% if n_trials_nature ~= n_trials_urban
% 
%     % Determine the smaller number of trials between the two conditions
%     n_trials_min = min(n_trials_nature, n_trials_urban);
% 
%     % Randomly select trials to match the smaller number of trials
%     rng('default'); % Setting the random seed for reproducibility
% 
%     % Generate random permutations of trial indices for each condition
%     selected_trials_nature = randperm(n_trials_nature, n_trials_min);
%     selected_trials_urban  = randperm(n_trials_urban, n_trials_min);
% 
%     % Subsample trials using ft_selectdata
%     cfg_select = [];
%     cfg_select.trials = selected_trials_nature;
%     natural_trials = ft_selectdata(cfg_select, natural_trials);
%     cfg_select.trials = selected_trials_urban;
%     urban_trials = ft_selectdata(cfg_select, urban_trials);
% 
% end
% 
% % Update the number of subjects (trials) for the design matrix
% n_subjects = n_trials_min;

% Compute grand average
cfg = [];
cfg.channel = 'all';
cfg.keeptrials = 'no'; % Keep individual trials for statistical analysis
erp_n_gavg  = ft_timelockanalysis(cfg, natural_trials);
erp_u_gavg  = ft_timelockanalysis(cfg, urban_trials);
erp_c_gavg  = ft_timelockanalysis(cfg, crowded_trials);
erp_nc_gavg = ft_timelockanalysis(cfg, noncrowded_trials);

% Plot ERP components -> EPN and LPP
cfg            = [];
cfg.channel    = LPP_egichans_labs;
cfg.showlegend = 'yes'
cfg.linewidth  = 2;
figure; ft_singleplotER(cfg, erp_n_gavg, erp_u_gavg)
hold on
yline(0,'k--','linew',2)
xline(0,'k--','linew',2)
hold off
xlabel('Time (s)', 'FontSize', 12);
ylabel('Voltage (\muV)', 'FontSize', 12);
figure_name = 'Grandaverage ERP for LPP Channels';
title(figure_name, 'FontSize', 14, 'FontWeight', 'bold');
legend('Nature', 'Urban', 'FontSize', 12, 'Location', 'northeast');
legend(BackgroundAlpha=.7)
saveFigs(gcf,fullfile(GROUPFIGURES),figure_name,false)

% % % % % % % % % %
%% Grand-average %%
% % % % % % % % % %

% Plot grand average
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'avg';
% cfg.nanmean   = 'yes';
cfg.keepindividual = 'no';
grandavg_n   = ft_timelockgrandaverage(cfg, avg_erps_natural{:});
grandavg_u   = ft_timelockgrandaverage(cfg, avg_erps_urban{:});
grandavg_c   = ft_timelockgrandaverage(cfg, avg_erps_crowded{:});
grandavg_nc  = ft_timelockgrandaverage(cfg, avg_erps_noncrowded{:});

% Plot ERP components -> EPN and LPP
cfg            = [];
cfg.channel    = LPP_egichans_labs;
cfg.showlegend = 'yes'
cfg.linewidth  = 2;
% % Optional - plot SEM (compute manuallly)
% cfg.maskparameter = 'sd'; % field in the first dataset to be used for marking significant data
% cfg.maskstyle     = 'box'; % style used for masking of data, 'box', 'thickness' or 'saturation' (default = 'box')
% cfg.maskfacealpha = 0.5; % mask transparency value between 0 and 1
figure; ft_singleplotER(cfg, grandavg_n, grandavg_u)
hold on
yline(0,'k--','linew',2)
xline(0,'k--','linew',2)
hold off
xlabel('Time (ms)', 'FontSize', 12);
ylabel('Voltage (\muV)', 'FontSize', 12);
figure_name = 'Grandaverage ERP for LPP Channels';
title(figure_name, 'FontSize', 14, 'FontWeight', 'bold');
legend('Nature', 'Urban', 'FontSize', 12, 'Location', 'northeast');
legend(BackgroundAlpha=.7)

%% Plot topographical maps

% Import chanlocs (run a00_fetch_data.m)
% EEG_n = eeg_emptyset;
% EEG_n.times = grandavg_n.time.*1000

EEG_n = grandavg_n.avg;
EEG_u = grandavg_u.avg;
EEG_nminu = EEG_n - EEG_u;

% Define intervals of 100 ms from -200 ms to 1000 ms
start_time   = -100;
end_time     = 1000;
times2plot   = start_time:100:end_time; 
tidx         = dsearchn(times',times2plot'); 
cond_suffix  = {'n'; 'u'; 'nminu'};

% Loop over each condition
for c = 1:length(cond_suffix)

    % Get condition data
    data = eval(strcat('EEG_',cond_suffix{c}));
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
        topoplot(data(:, tidx(i)), EEG.chanlocs, 'electrodes', 'on', 'numcontour', 1);
    
        % Set color limits for comparability across subplots
        set(gca, 'CLim', [-1 1]*3) 
        title([num2str(times2plot(i)) ' ms'], 'FontSize', 10, 'FontWeight', 'bold');
        
        % Colors
        colorbar;
        colormap(bluewhitered(64))
    end
    % Save
    saveFigs(gcf,fullfile(GROUPFIGURES),strcat('topoplot_',cond_name), false)
end
close all;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
cd(scripts); if called; stopLogging(); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                            Functions                                    %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %