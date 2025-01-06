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

% Select trials
EEG_n               = pop_select(EEG_ep, 'trial', find(n_ind));
EEG_u               = pop_select(EEG_ep, 'trial', find(u_ind));
EEG_c               = pop_select(EEG_ep, 'trial', find(c_ind));
EEG_nc              = pop_select(EEG_ep, 'trial', find(nc_ind));
% Trandform into fieldtrip
eegn_ft             = eeglab2fieldtrip(EEG_n, 'preprocessing', 'none');
eegu_ft             = eeglab2fieldtrip(EEG_u, 'preprocessing', 'none');
eegc_ft             = eeglab2fieldtrip(EEG_c, 'preprocessing', 'none');
eegnc_ft            = eeglab2fieldtrip(EEG_nc, 'preprocessing', 'none');
% Timelock analysis
cfg                 = [];
cfg.channel         = 'all';
cfg.keeptrials      = 'yes'; % Keep individual trials for statistical analysis
timelock_n          = ft_timelockanalysis(cfg, eegn_ft);
timelock_u          = ft_timelockanalysis(cfg, eegu_ft);
timelock_c          = ft_timelockanalysis(cfg, eegc_ft);
timelock_nc         = ft_timelockanalysis(cfg, eegnc_ft);
save(fullfile(DATA, fname, 'timelock_natural.mat'), 'timelock_n');
save(fullfile(DATA, fname, 'timelock_urban.mat'), 'timelock_u');
save(fullfile(DATA, fname, 'timelock_crowded.mat'), 'timelock_c');
save(fullfile(DATA, fname, 'timelock_noncrowded.mat'), 'timelock_nc');
% ERPs
cfg                 = [];
cfg.layout          = 'GSN-HydroCel-257.mat'; % Check layouts on github
cfg.interactive     = 'yes';
cfg.showoutline     = 'yes';
cfg.showlabels      = 'yes';
ft_multiplotER(cfg, timelock_n, timelock_u)
ft_multiplotER(cfg, timelock_c, timelock_nc)
saveFigs(gcf, fullfile(FIGURES, fname), 'topoplot_crowded_noncrowded', true); % Save the figure
close all

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                            Wrapping up                                  %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

if called; stopLogging(); end

