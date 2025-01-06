% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
fname = fetchScriptName; mkdir(fullfile(FIGURES, fname)); mkdir(fullfile(LOGS, fname));
mkdir(fullfile(DATA, fname)); called = manualOrCalled(); 
if called; startLogging(fullfile(LOGS, fname,'cli')); end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Compute ICA (or load)

% load(fullfile(DATA,fname,strcat(mcfg.ica.type,'_ica.mat'))); % load EEG with ica
if mcfg.ica.epoch
    % Epoch (confirm by computing EEG.pnts/EEG.srate)
    type_strs = {EEG.event.type}';
    for i = 1:length(type_strs)
        try
        split_str = strsplit(type_strs{i}, '_');
        type_strs{i} = split_str{1};
        EEG.event(i).type = type_strs{i};
        catch
        fprintf('Boundary event.\n')
        end
    end
    [EEG_epoched, indices] = pop_epoch(EEG, 'DI11', [-1 1]);
    EEG_epoched = pop_runica(EEG_epoched, 'icatype', 'runica', 'extended',0,'concatcond','on','interrupt','on','pca', EEG_epoched.nbchan);
    save(fullfile(DATA,fname,strcat(mcfg.ica.type,'_ica_epoched.mat')),'EEG_epoched'); % save ica
    % % Reshape back to continuous (if necessary) -> there is a function
    % for it
    % EEG.data = reshape(EEG_epoched.data, size(EEG_epoched.data, 1), []);
    % EEG.pnts = size(EEG.data, 2);
    % EEG.trials = 1;
    % EEG.event = EEG_epoched.event;
    % EEG = eeg_checkset(EEG);
end
switch mcfg.ica.type
    case 'amica'
    EEG = pop_runamica(EEG,'pcakeep', EEG.nbchan);
    case 'runica'
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',0,'interrupt','on','pca', EEG.nbchan);
end
save(fullfile(DATA,fname,strcat(mcfg.ica.type,'_ica.mat')),'EEG'); % save ica


%% ICLABEL
if isempty(EEG.icachansind)
    EEG.icachansind = 1:EEG.nbchan; % FIX BUG
end
EEG = pop_iclabel(EEG, 'default');

%% Visualize

% Plot individual ICs
for ic_num = 1:size(EEG.icaweights, 1)
    pop_prop(EEG, 0, ic_num, NaN, {'freqrange', [1 50]}); 
    saveFigs(gcf,fullfile(FIGURES,fname),strcat('ica_comp_',num2str(ic_num)))
end

% Plot ICA spectral
figure; 
pop_spectopo(EEG, 0, [EEG.times(1) EEG.times(end)], 'EEG' , 'freq', 10, 'plotchan', 0,...
'percent', 20, 'icacomps', 1:size(EEG.icawinv,2), 'nicamaps', 10, 'freqrange',[1 50],'electrodes','off');
saveFigs(gcf,fullfile(FIGURES,fname),'psd_ics')

% Fit Components to Dipole
[eeglab_path,~,~] = fileparts(which('eeglab')); 
EEG = pop_dipfit_settings( EEG, 'hdmfile',fullfile(eeglab_path,'plugins\dipfit\standard_BEM\standard_vol.mat'),'mrifile',fullfile(eeglab_path,'plugins\dipfit\standard_BEM\standard_mri.mat'),'chanfile',fullfile(eeglab_path,'plugins\dipfit\standard_BEM\elec\standard_1005.elc'),'coordformat','MNI','coord_transform',[0.58064 -17.1219 2.4633 0.10205 0.0070796 -1.5764 1.165 1.0609 1.1535] );
EEG = pop_multifit(EEG, 1:size(EEG.icaweights, 1) ,'threshold',100,'dipplot','on','plotopt',{'normlen','on'});
saveFigs(gcf,fullfile(FIGURES,fname),'dipfit_ics', false)

% Save RV in structure
rv = [EEG.dipfit.model.rv];
text2struct(mcfg, 'dipfit.model.rv', rv)


%% Flag components

% Order of components- 'Brain'  'Muscle'  'Eye'  'Heart'  'Line Noise'  'Channel Noise'  'Other' 
EEG = pop_icflag(EEG, [NaN NaN;0.8 1;0.8 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
try
    EEG = pop_subcomp(EEG, EEG.reject.gcompreject);
    % Plot grouped ICs
    pop_selectcomps(EEG, 1:size(EEG.icawinv,2))
    saveFigs(gcf,fullfile(FIGURES,fname),'selected_ics')
catch
    disp('No rejected components')    
end

%% Save ICA information
% EEG_ica = EEG;
txtout = struct2text(1, EEG.etc,'   ');
saveTextOutput(txtout, fullfile(LOGS,fname), 'ica_information')
% Close all figs
close all

% Quick check of freqs
figure;
pop_spectopo(EEG, 1, [], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 EEG.srate/2],'electrodes','on');
saveFigs(gcf, fullfile(FIGURES,fname), 'psd_after_ica', false); close all


if ~called

%% Plot ICA activations
pop_eegplot( EEG, 0, 1, 1); % Plot ICAact

    
%% Compute ICAACT

% Init
EEG.icaact = zeros(size(EEG.data));

for comp=1:size(EEG.icawinv,1)
    % Use eeglab function
    EEG.icaact(comp,:) = eeg_getica(EEG, comp);
    % Plot icaact
    eegplot(EEG.icaact(comp,:), 'winlength', 30, 'dispchans', 30, 'events', EEG.event, 'ploteventdur', 'on')
    % saveFigs(gcf,fullfile(FIGURES,fname),strcat('icaact_',num2str(comp)), false)
end

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
stopLogging();
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %