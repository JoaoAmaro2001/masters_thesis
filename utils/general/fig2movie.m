function fig2movie(h, outdir, movname, frame_rate, numFrames)
    % FIG2MOVIE Convert a figure with a slider to a movie
    %   fig2movie(h, outdir, movname, frame_rate, numFrames)
    %
    %   Inputs:
    %   h          - Figure handle
    %   outdir     - Output directory (default: current directory)
    %   movname    - Name of the output movie file (default: 'output_movie')
    %   frame_rate - Frame rate of the output video (default: 30)
    %   numFrames  - Number of frames to generate (default: 100)
    
    % Input validation and default values
    if nargin < 2 || isempty(outdir), outdir = pwd; end
    if nargin < 3 || isempty(movname), movname = 'output_movie'; end
    if nargin < 4 || isempty(frame_rate), frame_rate = 30; end
    if nargin < 5 || isempty(numFrames), numFrames = 100; end
    
    % Find the slider handle
    hSlider = findobj(h, 'Style', 'slider');
    if isempty(hSlider)
        error('Slider not found in the figure.');
    end
    
    % Set up the video writer
    movie_filename = fullfile(outdir, [movname '.mp4']);
    v = VideoWriter(movie_filename, 'MPEG-4');
    v.FrameRate = frame_rate;
    v.Quality = 95;
    open(v);
    
    % Get slider callback
    sliderCallback = get(hSlider, 'Callback');
    
    % Preallocate frame struct for efficiency
    frame = struct('cdata', [], 'colormap', []);
    
    % Loop over the slider positions
    for i = 1:numFrames
        % Set slider position
        set(hSlider, 'Value', (i - 1) / (numFrames - 1));
        
        % Trigger the slider callback to update the plot
        if isa(sliderCallback, 'function_handle')
            sliderCallback(hSlider, []);
        elseif iscell(sliderCallback)
            sliderCallback{1}(hSlider, [], sliderCallback{2:end});
        end
        
        % Capture and write the frame
        drawnow;
        frame = getframe(h);
        writeVideo(v, frame);
    end
    
    % Close the video writer
    close(v);
    fprintf('Movie saved as %s\n', movie_filename);
    end