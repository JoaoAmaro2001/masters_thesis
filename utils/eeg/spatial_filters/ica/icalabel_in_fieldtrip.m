% Run ICLabel in Fieldtrip
% First install EEGLAB (it includes the ICLabel plugin by default). Then use the script below.

cfg = [];
cfg.datafile = '~/data/matlab/eeglab/sample_data/eeglab_data.set';
cfg.headerfile = '~/data/matlab/eeglab/sample_data/eeglab_data.set';
my_ft_data = ft_preprocessing(cfg);

eeglab; close; % add paths to EEGLAB
EEG = fieldtrip2eeglab(my_ft_data, my_ft_data.trial);
EEG = eeg_checkset(EEG);
EEG = pop_runica(EEG, 'icatype', 'runica');
EEG = pop_icflag(EEG, [0 0;0 0; 0.001 1; 0 0; 0 0; 0 0; 0 0]); % see function help message
rejected_comps = find(EEG.reject.gcompreject > 0);
EEG = pop_subcomp(EEG, rejected_comps);
EEG = eeg_checkset(EEG);

curPath = pwd;
p = fileparts(which('ft_read_header'));
cd(fullfile(p, 'private'));
hdr = read_eeglabheader( EEG );
data = read_eeglabdata( EEG, 'header', hdr );
event = read_eeglabevent( EEG, 'header', hdr );
cd(curPath);