%% How to obtain practically reproducible ICA results (Parameters matter!)


% This one is less stable.
pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'lrate', 1.8755e-04, 'maxsteps', 512); % lrate is determined as 0.00065/log(EEG.nbchan) from ''runica''() line 178. 280th iterations to converge.

% This one is more stable (i.e. top 7 ICs (i.e. largest variances) across 10 runs were the same).
pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'lrate', 1e-5, 'maxsteps', 2000); % 1300th iterations to converge.
