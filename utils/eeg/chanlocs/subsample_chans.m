%  loc_subsets() - Separate channels into maximally evenly-spaced subsets. 
%                  This is achieved by exchanging channels between subsets so as to
%                  increase the sum of average of distances within each channel subset.
%  Usage:
%        >> subset = loc_subsets(chanlocs, nchans); % select an evenly spaced nchans
%        >> [subsets subidx pos] = loc_subsets(chanlocs, nchans, plotobj, plotchans, keepchans);

[subsets, subidx, pos] = loc_subsets(EEG.chanlocs, [32, 64, 128], 1, 1);