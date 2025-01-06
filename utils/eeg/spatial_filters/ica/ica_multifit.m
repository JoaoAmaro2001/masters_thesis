% Test on a test struct
EEG1 = EEG;

% Specify head model paramaters
headmodel = {
            'hdmfile','standard_BESA/standard_vol.mat',...
            'coordformat','Spherical',...
            'mrifile','standard_BESA/standard_mri.mat',...
            'chanfile','standard_BESA/standard-10-5-cap385.elp',...
            'coord_transform',[0 0 0 0 0 -1.5708 1 1 1] ,...
            'chansel',1:EEG.nbchan, ...
            };

% Set the standard head model
EEG1 = pop_dipfit_settings(EEG1, headmodel{:});

% Fit dipoles to the independent components
EEG1 = pop_multifit(EEG1, 1:size(EEG.icaweights,1) ,'threshold',100,'plotopt',{'normlen' 'on'});

% % This section is updated. I confirmed with Dipfit4.3 that EEG.dipfit.model now has the following fields (just an example)
% % 
% %        posxyz: [-49.0329 45.5410 23.2540]
% %        momxyz: [-2.4949e+04 -1.3269e+03 -1.7305e+04]
% %            rv: 0.0132
% %        active: 1
% %        select: 1
% %       diffmap: [21×1 double]
% %     sourcepot: [21×1 double]
% %       datapot: [21×1 double]