%% Check if everything is ok (eeglab)

% If the answer shows only one entry, [eeglab_root]\functions\adminfunc\eeg_options.m, you got this problem. 
% Usually, you have to find two of them, one under the adminfunc, which is like a read-only architype, 
% and the other one under userpath, which is actively overwirtten by EEGLAB every time user change the option settings. 
% If EEGLAB cannot access to this eeg_options.m, 'precompute ICA activations...' is unselected (I guess), 
% hence EEG.icaact is NEVER calculated by eeg_checkcet(). 
% Here is the update by Jake Garetti, one of the EEGLAB workshop attendees who ran into the problem and solved it! 
% He told me that "Instead of just copying the options file to the userpath, 
% I had to go into functions/sigprocfunc/icadefs.m and manually set EEGOPTION_PATH = userpath;" - done (João)!

which -all eeg_options 
% userpath('reset') % reset the userpath to the default

