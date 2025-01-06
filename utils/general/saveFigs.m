function saveFigs(h, outdir, figname, html)
    % SAVEFIGS Save figures in various formats including interactive HTML (optional).
    %
    %   saveFigs(h, outdir, figname, html)
    %
    %   Inputs:
    %       h        - Handle of the figure to save.
    %       outdir   - Output directory for saving the files.
    %       figname  - Name of the figure file (without extension).
    %       html     - Optional flag to save as interactive HTML using Plotly (default: true).
    %
    %   Example:
    %       saveFigs(gcf, './output', 'myfigure', true);
    %       saveFigs(gcf, './output', 'myfigure'); % defaults to HTML saving

    % Default the html flag to true if not provided
    if nargin < 4
        html = true;
    end

    % Get current directory
    cdir = pwd;

    % Make figure full screen
    set(h, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);

    % Save as .fig
    saveas(h, fullfile(outdir, figname), 'fig');

    % Save as .png
    saveas(h, fullfile(outdir, figname), 'png');

    % Save as interactive .html (requires Plotly), if html flag is true
    if html
        cd(outdir)
        try
            fig2plotly(h, 'offline', true, 'filename', figname, 'open', false, 'fileopt', 'append');
        catch
            warning('Plotly not found. Interactive .html not saved.');
        end
        cd(cdir)
    end
end
