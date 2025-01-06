function stopLogging()
    % stop_logging - Stops logging command window output
    %
    % Usage:
    %   stop_logging()
    %
    % This function stops capturing command window output using MATLAB's diary functionality.
    
        diary('off');
    
        % Display a message
        disp('Command window logging has been stopped.');
    end
    