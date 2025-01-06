% High-level function that calls lower-level functions to plot ERP figures.

function do_plot_erp(eeg_data)

% Convert
df = check2convert(eeg_data);

% Butterfly plot
erp_butterfly(df);

end