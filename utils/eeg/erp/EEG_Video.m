% clear 
% close all
% clc
% eeglab nogui

% cd '/Users/pedrorocha/Documents/EEG/Clean Data';
% EEG = pop_loadset('filename', 'BAP001012TASK1_clean.set', 'filepath', '/Users/pedrorocha/Documents/EEG/Clean Data/BAP001012TASK1');

% load BAP001012TASK1_20230130_113241;
% EEG = pop_mffimport('BAP001012TASK1_20230130_113241_obs.mff');

pnts1 = round(eeg_lat2point(-100/1000, 1, EEG.srate, [EEG.xmin EEG.xmax]));
pnts2 = round(eeg_lat2point( 600/1000, 1, EEG.srate, [EEG.xmin EEG.xmax]));
pnts1 = max(pnts1, 1);
pnts2 = max(pnts2, 1);
scalpERP = mean(EEG.data(:,pnts1:pnts2),3);
% scalpERP = zeros(size(EEG.data, 1), pnts2-pnts1+1);
% scalpERP([149, 150, 158, 159], :) = mean(EEG.data([20, 21, 26, 27], pnts1:pnts2), 3);

% Smooth data
%for iChan = 1:size(scalpERP,1)
%    scalpERP(iChan,:) = conv(scalpERP(iChan,:) ,ones(1,5)/5, 'same');
%end

headplotparams1 = { 'meshfile', 'mheadnew.mat'       , 'transform', [0.664455     -3.39403     -14.2521  -0.00241453     0.015519     -1.55584           11      10.1455           12] };
headplotparams2 = { 'meshfile', 'colin27headmesh.mat', 'transform', [0          -13            0          0.1            0        -1.57         11.7         12.5           12] };
headplotparams  = headplotparams1; % switch here between 1 and 2

% set up the spline file
headplot('setup', EEG.chanlocs, 'STUDY_headplot.spl', headplotparams{:}); close
 
% check scalp topo and head topo
figure; headplot(scalpERP(:,end-50), 'STUDY_headplot.spl', headplotparams{:}, 'maplimits', 'absmax', 'lighting', 'on');
colorbar
figure; topoplot(scalpERP(:,end-50), EEG.chanlocs); %2D
colorbar

% video
figure('color', 'w'); [Movie,Colormap] = eegmovie( scalpERP, EEG.srate, EEG.chanlocs, 'framenum', 'off', 'vert', 0,...
'startsec', -0.1, 'mode', '3d',...
'headplotopt', { headplotparams{:}, 'material', 'metal'}, 'camerapath', [-127 2 30 0]); % orig function had headplotparams{:} in heaedplotopt first input
seemovie(Movie,-5,Colormap);
vidObj = VideoWriter('erpmovie3d1.mp4', 'MPEG-4');
open(vidObj);
writeVideo(vidObj, Movie);
close(vidObj);