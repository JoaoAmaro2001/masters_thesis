% Re-reference to average and estime the PARE (finish)

% Assuming you have a matrix 'data' of size [n_channels, n_samples]
% and a matrix 'chanlocs' of size [n_channels, 3] containing the 3D coordinates of each electrode

% Create a scattered interpolant
F = scatteredInterpolant([EEG.chanlocs.X]', [EEG.chanlocs.Y]', [EEG.chanlocs.Z]', double(EEG.data(:,1,1)), 'natural');

% Define a grid of points on the scalp
[xq, yq, zq] = sphere(50);

% Extrapolate the data at the grid points
vq = F(xq, yq, zq);

% Plot the interpolated data
figure;
surf(xq, yq, zq, vq);

% Create a scattered interpolant
F = scatteredInterpolant([EEG.chanlocs.X]', [EEG.chanlocs.Y]', [EEG.chanlocs.Z]', double(EEG.data(:,1,1)), 'natural');

% Define a grid of points on the scalp
[xq, yq, zq] = sphere(50);

% Interpolate the data at the grid points
vq = F(xq, yq, zq);

% Create a gridded interpolant for extrapolation
G = griddedInterpolant({xq(:), yq(:), zq(:)}, vq(:), 'spline');

% Define the points where you want to extrapolate
% [xe, ye, ze] = ... % define your points here

% Extrapolate the data at the new points
ve = G(xe, ye, ze);

% Plot the extrapolated data
figure;
surf(xe, ye, ze, ve);