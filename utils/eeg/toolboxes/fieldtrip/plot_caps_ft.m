% Function to plot all available layouts in FieldTrip

[ftver, ftpath] = ft_version;
dirlist = dir(fullfile(ftpath, 'template', 'layout', '*.*')); % here you can make a selection
filename = {dirlist(~[dirlist.isdir]).name}';

for i=1:length(filename)
  cfg = [];
  cfg.layout = filename{i};
  cfg.skipcomnt = 'yes';
  cfg.skipscale = 'yes';
  layout = ft_prepare_layout(cfg);

  figure
  ft_plot_layout(layout);
  title(filename{i}, 'Interpreter', 'none');

  [p, f, x] = fileparts(filename{i});
  print([lower(f) x '.png'], '-dpng');
  
  close all
end