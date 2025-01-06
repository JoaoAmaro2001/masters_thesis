% How to send email from Matlab to report progress - Thanks Makoto!

% Set up Matlab preferences.
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','E_mail','joao-amaro@edu.ulisboa.pt');
setpref('Internet','SMTP_Username','joao-amaro@edu.ulisboa.pt');
password = input('Enter your email password: ', 's');
setpref('Internet','SMTP_Password', password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

% % % % % % % % % % % % % % % % % % % % % % % Testing (works!)
% sendmail({'joaopvamaro@gmail.com'},...
%     'From Matlab', 'This is a test email from Matlab.');
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% Process all sets in a folder. 
allSets = dir('/data/projects/example/p0100_imported/*.set');
ticTocList = nan(length(allSets),1);
for setIdx = 1:length(allSets)
 
    ticStart = tic;
 
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Your process here. %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    
 
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Calculate time lapse. %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ticTocList(setIdx) = toc(ticStart);
 
    if mod(setIdx, 100) == 0
 
        meanProcessingDurationInSec = nanmean(ticTocList);
        stdProcessingDurationInSec  = nanstd(ticTocList);
        meanRemainingProcessingDurationInDay = (length(allSets)-setIdx)*meanProcessingDurationInSec/(60*60*24);
        stdRemainingProcessingDurationInDay  = (length(allSets)-setIdx)*stdProcessingDurationInSec/(60*60*24);
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Send email for update. %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        sendmail({'joao-amaro@edu.ulisboa.pt'},...
            sprintf('From Matlab running batch: %.0f/%.0f done', setIdx, length(allSets)),...
            sprintf('Estimated remaining time: %.1f days (SD %.1f)', meanRemainingProcessingDurationInDay, stdRemainingProcessingDurationInDay));
    end
end