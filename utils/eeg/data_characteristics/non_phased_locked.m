check2validate;

% run the same calculations for a specific time window
timer   = dsearchn(data.times',[data.times(0) data.times(end)]');
covin   = zeros(size(data.eeg,1));
covintn = zeros(size(data.eeg,3),1); % matrix with distance of variances
for triali=1:size(data.eeg,3)
    covin = covin + cov ( squeeze(data.eeg(:,timer(1):timer(2),triali))' );
    covintn(triali,1) = sqrt( trace (cov ( squeeze(data.eeg(:,timer(1):timer(2),triali))' ) ) );
end

data.cov.eeg = covin/size(data.eeg,3);

figure(1),clf
subplot(121)
imagesc(data.cov.eeg)
set(gca,'clim',[-1 1]*100)
colormap turbo
colorbar
title('Covariance of the data by averaging the covariance of each trial')

data.cov.erp = cov(data.erp'); % taking the erp first will kill all the non-phase locked acitvity
subplot(122)
imagesc(data.cov.erp)
set(gca,'clim',[-1 1]*20)
colormap turbo
colorbar
title('Covariance of the data by taking the covariance of the ERP')

% Explain the whole script
fprintf('We are taking the covariance across all channels and all trials for a specific time window. Interestingly, this is a good test to check the ammount of non-phased locked activity in the data when compared to taking the covariance of the erp. \n')