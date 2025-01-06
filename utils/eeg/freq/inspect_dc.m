if data.ndims == 2
dataEEG = data.eeg;
elseif data.ndims == 3
dataEEG = data.erp;
end

dcComponent = mean(dataEEG,2);
isDCZero = abs(dcComponent) < 1e-5; % Use a small threshold to account for floating-point precision

if isDCZero
    fprintf('The DC component is zero.\n');
else
    fprintf('The DC component is not zero.\n');
end