check2validate;

[Un,En,Vn] = svd(data.eeg); 

figure(1),clf
subplot(141)
imagesc(data.eeg)
subplot(142)
imagesc(Un)
subplot(143)
imagesc(En)
subplot(144)
imagesc(Vu)