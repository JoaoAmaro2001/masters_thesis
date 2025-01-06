% Compute rank of the eeg data
if ~isfield(data, 'rank')
    data.rank      = struct();
    data.rank.rank = struct();
    data.rank.eig  = struct();
end
if data.ndims == 2
data.rank.rank = rank(data.eeg);
data.rank.eig  = sum(eig(cov(data.eeg'))) > 1E-6; 

elseif data.ndims == 3
data.rank.rank = rank(data.erp);
data.rank.eig  = sum(eig(cov(data.erp'))) > 1E-6; 

end

fprintf('Rank of the data is %d.\n', data.rank.rank);
fprintf('Rank of the data via eigenvalue is %d.\n', data.rank.eig);

if data.rank.rank == data.nbchan
    fprintf('The rank is equal to the number of channels -> %d.\n', data.nbchan);
else
    fprintf('The rank is not equal to the number of channels -> %d.\n', data.nbchan);
end