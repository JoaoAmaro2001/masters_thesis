% ----------------------------- PROGRESS BAR (Waitbar) -----------------------------

h = waitbar(0,'Please wait...');
steps = 100;

for i = 1:steps
    
    % % % % 
    % computations take place here
    % % % %

    pause(0.01) % this is just for demonstration, remove in your actual code
    waitbar(i/steps, h, sprintf('Progress: %3.1f%%', 100*i/steps));
end

close(h)


% ----------------------------- PROGRESS BAR (CLI) -----------------------------

% Total number of iterations
totalIter = 100;

% Start the timer
tic;

for i = 1:totalIter
    % Your process here
    pause(0.01); % Just for demonstration, remove this in your actual code

    % Calculate elapsed time and remaining time
    elapsedTime = toc;
    remainingTime = (totalIter - i) * (elapsedTime / i);

    % Print the progress bar and estimated time
    fprintf('Progress: %3.1f%%. Estimated time remaining: %3.1f seconds.\n', i / totalIter * 100, remainingTime);

    % Clear the command line for the next progress update
    if i < totalIter
        fprintf(repmat('\b', 1, length(sprintf('Progress: %3.1f%%. Estimated time remaining: %3.1f seconds.', i / totalIter * 100, remainingTime))));
    end
end