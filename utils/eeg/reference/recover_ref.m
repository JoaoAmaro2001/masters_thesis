%%

allSets = dir('/data/mobi/ilaria/p0100_imported/*.set');
 
for setIdx = 1:length(allSets)
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Create the new montage template. %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use the first dataset for the new template.
    if setIdx == 1
        loadName = allSets(setIdx).name;
        EEG = pop_loadset('filename', loadName, 'filepath', '/data/mobi/ilaria/p0100_imported');
 
        % Remove ICA-related info (if present) and insert Cz at ch64.
        EEG.nbchan      = 64;
        EEG.data(64,:)  = zeros(1,EEG.pnts);
        EEG.icaact      = [];
        EEG.icawinv     = [];
        EEG.icasphere   = [];
        EEG.icaweights  = [];
        EEG.icachansind = [];
        EEG.chanlocs(64).label = 'Cz';
        EEG = pop_chanedit(EEG, 'changefield',{64 'labels' 'Cz'},'lookup','C:/Users/joaoa/Desktop/Pessoal/Downloads/Packages/eeglab2024.0/plugins/dipfit/standard_BEM/elec/standard_1005.elc', ...
                           'eval','chans = pop_chancenter( chans, [],[]);');
 
        % Store it as EEG2.            
        EEG2 = pop_select(EEG,'time',[0 1]);
    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Batch-apply the new montage template. %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load a .set file.
    loadName = allSets(setIdx).name;
    EEG = pop_loadset('filename', loadName, 'filepath', '/data/mobi/ilaria/p0100_imported');
 
    % Just in case, re-apply the MNI template locations with chancenter. 
    EEG = pop_chanedit(EEG, 'lookup','C:/Users/joaoa/Desktop/Pessoal/Downloads/Packages/eeglab2024.0/plugins/dipfit/standard_BEM/elec/standard_1005.elc', ...
                       'eval','chans = pop_chancenter( chans, [],[]);');
 
    % Apply the new montage template.               
    EEG = pop_interp(EEG, EEG2.chanlocs, 'spherical');
 
    % Remove ICA-related results.
    EEG.icaact      = [];
    EEG.icawinv     = [];
    EEG.icasphere   = [];
    EEG.icaweights  = [];
    EEG.icachansind = [];
    EEG.dipfit      = [];
 
    % Save the data.
    pop_saveset(EEG, 'filename', loadName, 'filepath', '/data/mobi/ilaria/p0110_recoverCz');
end