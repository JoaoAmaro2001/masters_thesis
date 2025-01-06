% Plots a butterfly plot. 

function erp_butterfly(df, varargin)

    % Parse ERP inputs
    p = inputParser;
    addOptional(p,'channels', {})
    addOptional(p,'time',{})
    addOptional(p,'trials',{})
    parse(p,varargin{:})
    
    % Check optional inputs exist

    % Compute and plot
    if df.trials > 1
        warning('Data must be continuous, not epoched. Computing ERP...')
        df.data = mean(df.data, 3);
    end

    figure, clf
    plot(df.times,df.data,'linew',2)
    if ~isempty(df.times)
        set(gca,'xlim',[df.times(1) df.times(end)])
    end
    title('Butterfly plot')
    xlabel('Time (s)'), ylabel('Voltage (\muV)')
    grid on

end