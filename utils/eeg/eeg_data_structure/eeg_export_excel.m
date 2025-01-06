% Obtain electrode labels.
chLabels            = {EEG.chanlocs.labels}';
 
% If the electrode labels are just numbers, you have to add non-numeric
% characters before that, otherwise writetable() fails. Very Dumb.
for chIdx           = 1:length(chLabels)
    chLabels{chIdx} = ['Ch' chLabels{chIdx}];
end
 
% Obtain ERP latency.
latency             = cellstr(num2str(EEG.times'));
 
% Obtain all-electrode ERP.
ERP                 = mean(EEG.data,3)';
 
% Prepare output table.
outputTable         = array2table(ERP, 'VariableNames', chLabels, 'RowNames', latency);
 
% Write the output table. Using '.xlsx' automatically specifies Excel
% format so no need to use 'FileType', 'spreadsheet' option.
writetable(outputTable, 'savePath/test.xlsx',...
           'WriteVariableNames', true, 'WriteRowNames', true);