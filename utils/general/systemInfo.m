% Get system information using the system function
% status is a number that indicates whether the command was successful (0 means success), and cmdout is a string that contains the output of the command.
[status, cmdout] = system('systeminfo');

% Print the system information
disp(cmdout);