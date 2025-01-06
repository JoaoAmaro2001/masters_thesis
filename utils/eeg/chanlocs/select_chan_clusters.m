function clusters = select_chan_clusters(EEG, plot_type)
    % Function to plot EEG.chanlocs and let the user interactively select channels to create clusters.
    %
    % Usage:
    %   clusters = select_chan_clusters(EEG, plot_type)
    %
    % Inputs:
    %   - EEG: EEGLAB structure containing EEG.chanlocs.
    %   - plot_type: '2d' for 2D plot or '3d' for 3D plot.
    %
    % Output:
    %   - clusters: Cell array where each cell contains the indices of channels in a cluster.
    %
    % Example:
    %   clusters = select_chan_clusters(EEG, '2d');
    %
    % After running the function, you can use the clusters for further analysis or plotting.

    % Check if EEGLAB functions are available
    eeglab_available = exist('topoplot', 'file') == 2;

    % Extract channel locations and labels
    chanlocs = EEG.chanlocs;
    chan_labels = {chanlocs.labels};

    % Extract X, Y, and Z coordinates for all channels
    x_all = [chanlocs.X];
    y_all = [chanlocs.Y];
    z_all = [chanlocs.Z];

    % Initialize variables
    clusters = {};
    num_clusters = 0;
    finished = false;

    % Define colors for clusters
    colors = lines(10); % Up to 10 clusters; adjust if more clusters are needed

    % Ensure the nose is in the Y+ direction
    % This is the default orientation in EEGLAB's topoplot

    % Create figure
    figure('Name', 'Select Channels for Clusters', 'NumberTitle', 'off');
    hold on;

    % Plot all channels
    if eeglab_available
        % Use EEGLAB's topoplot function
        fprintf('Using EEGLAB functions for plotting.\n');
        % Plot empty head map
        topoplot([], chanlocs, 'style', 'blank', 'electrodes', 'on', 'plotchans', 1:length(chanlocs), 'emarker', {'.','k',10,1});
    else
        % Use custom plotting method
        fprintf('EEGLAB not available. Using custom plotting function.\n');

        if strcmpi(plot_type, '2d')
            % 2D Plot with nose in Y+ direction
            scatter(y_all, x_all, 50, 'MarkerFaceColor', [0.8, 0.8, 0.8], 'MarkerEdgeColor', 'k');
        elseif strcmpi(plot_type, '3d')
            % 3D Plot with nose in Y+ direction
            scatter3(y_all, x_all, z_all, 50, 'MarkerFaceColor', [0.8, 0.8, 0.8], 'MarkerEdgeColor', 'k');
        else
            error('Invalid plot type. Use ''2d'' or ''3d''.');
        end
    end

    % Set plot properties
    title('EEG Channel Selection for Clusters');
    xlabel('Y');
    ylabel('X');
    if strcmpi(plot_type, '3d')
        zlabel('Z');
    end
    grid on;
    axis equal;
    hold on;

    % Instructions
    fprintf('Instructions:\n');
    fprintf('- Left-click to select channels for the current cluster.\n');
    fprintf('- Press Enter to finish the current cluster and start a new one.\n');
    fprintf('- Press Esc to finish cluster selection.\n');

    % Main loop for cluster selection
    while ~finished
        num_clusters = num_clusters + 1;
        fprintf('\nStarting selection for Cluster %d\n', num_clusters);
        cluster_indices = [];

        % Inner loop for selecting channels in the current cluster
        while true
            % Wait for user input
            [x_click, y_click, button] = ginput(1);

            if isempty(button) % Enter key pressed
                fprintf('Finished selecting channels for Cluster %d\n', num_clusters);
                break;
            elseif button == 27 % Esc key pressed
                fprintf('Exiting channel selection.\n');
                finished = true;
                break;
            else
                % Find the nearest channel to the click
                if strcmpi(plot_type, '2d')
                    % For 2D plot
                    distances = hypot(y_all - x_click, x_all - y_click);
                elseif strcmpi(plot_type, '3d')
                    % For 3D plot (projected onto 2D)
                    distances = hypot(y_all - x_click, x_all - y_click);
                end
                [min_dist, idx] = min(distances);

                % Threshold to avoid accidental selections
                if min_dist < 0.05 % Adjust threshold as needed
                    if ~ismember(idx, cluster_indices)
                        cluster_indices(end+1) = idx;
                        % Highlight the selected channel
                        if strcmpi(plot_type, '2d')
                            scatter(y_all(idx), x_all(idx), 100, 'MarkerFaceColor', colors(num_clusters, :), 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
                        elseif strcmpi(plot_type, '3d')
                            scatter3(y_all(idx), x_all(idx), z_all(idx), 100, 'MarkerFaceColor', colors(num_clusters, :), 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
                        end
                        % Display selected channel label
                        text(y_all(idx), x_all(idx), chan_labels{idx}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 8, 'Color', colors(num_clusters, :));
                        fprintf('Selected channel: %s (Index %d) for Cluster %d\n', chan_labels{idx}, idx, num_clusters);
                    else
                        fprintf('Channel %s is already selected for Cluster %d\n', chan_labels{idx}, num_clusters);
                    end
                end
            end
        end

        % Store the cluster indices
        clusters{num_clusters} = cluster_indices;

        % Exit if user pressed Esc
        if finished
            break;
        end
    end

    % Add legend
    legend_entries = cell(1, num_clusters);
    for i = 1:num_clusters
        legend_entries{i} = ['Cluster ' num2str(i)];
    end
    % Create custom legend entries
    for i = 1:num_clusters
        scatter(NaN, NaN, 100, 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'k', 'DisplayName', legend_entries{i});
    end
    legend('show');

    % Final message
    fprintf('\nCluster selection completed.\n');
    for i = 1:num_clusters
        fprintf('Cluster %d contains %d channels.\n', i, length(clusters{i}));
    end

    hold off;
end
