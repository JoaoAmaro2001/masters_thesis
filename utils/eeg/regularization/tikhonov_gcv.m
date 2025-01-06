%% Inputs

% Load the EEG dataset
EEG = pop_loadset('your_dataset.set');

% Define the problem
A = your_lead_field_matrix; % Replace this with your actual lead field matrix
b = EEG.data'; % Transpose the data to get the correct dimensions

% 13 matrices with increasing regularization factors from 0 (none) to 12 (for very noisy data)    % times a constant ALPHA, which depends on the selected inverse model.
lambda_grid = 10 .^ logspace(-12, 0, 100);

%% Using GCV to solve the Tikhonov regularization problem

% Initialize the GCV score
gcv_score = inf;

% Initialize the optimal solution
x_opt = [];

% Iterate over the regularization parameter grid
for lambda = lambda_grid
    % Solve the Tikhonov regularization problem
    x = (A'*A + lambda*eye(size(A, 2))) \ (A'*b);
    
    % Calculate the GCV score
    gcv = norm(A*x - b)^2 / (1 - trace(A / (A'*A + lambda*eye(size(A, 2))) * A'))^2;
    
    % Update the optimal solution and the GCV score
    if gcv < gcv_score
        gcv_score = gcv;
        x_opt = x;
    end
end

% Print the optimal solution
disp(x_opt);

%% Using the L-curve to solve the Tikhonov regularization problem

% Initialize the norms of the solutions
norms = zeros(size(lambda_grid));

% Iterate over the regularization parameter grid
for i = 1:length(lambda_grid)
    lambda = lambda_grid(i);
    
    % Solve the Tikhonov regularization problem
    x = (A'*A + lambda*eye(size(A, 2))) \ (A'*b);
    
    % Store the norm of the solution
    norms(i) = norm(x);
end

% Plot the norm of the solution as a function of the regularization parameter
loglog(lambda_grid, norms);
xlabel('Regularization parameter');
ylabel('Norm of the solution');

% Find the L-corner
[~, idx] = max(diff(log(norms)) ./ diff(log(lambda_grid)));

% The optimal regularization parameter is the one at the L-corner
lambda_opt = lambda_grid(idx);

% Print the optimal regularization parameter
disp(lambda_opt);