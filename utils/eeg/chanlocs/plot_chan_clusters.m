function plot_chan_clusters(EEG, clusters, plot_type, show_labels, view_mode)
    % Function to plot EEG.chanlocs with different colors for specified clusters.
    % Now includes options to show electrode labels and use EEGLAB's head model.
    %
    % Usage:
    %   plot_chan_clusters(EEG, clusters, plot_type, show_labels, view_mode)
    %
    % Inputs:
    %   - EEG: EEGLAB structure containing EEG.chanlocs.
    %   - clusters: A list of indices, a cell array of channel labels, or a cell array
    %               where each cell contains indices or labels for a cluster.
    %   - plot_type: '2d' for 2D plot or '3d' for 3D plot.
    %   - show_labels: (optional) true or false to display electrode labels. Default is false.
    %   - view_mode: (optional) 'scatter' (default) or 'headplot' to use EEGLAB's head model.
    %
    % Examples:
    %   % Highlight a single cluster using indices, show labels, and use default scatter plot
    %   cluster_indices = [1, 2, 3, 4];
    %   plot_chan_clusters(EEG, cluster_indices, '2d', true);
    %
    %   % Highlight multiple clusters using labels, use headplot viewing mode
    %   clusters_labels = {{'Fz', 'Cz'}, {'Pz', 'Oz'}};
    %   plot_chan_clusters(EEG, clusters_labels, '3d', false, 'headplot');
    
    % Check inputs
    if nargin < 4
        show_labels = false;
    end
    if nargin < 5
        view_mode = 'scatter';
    end
    
    % Extract channel locations and labels
    chanlocs = EEG.chanlocs;
    chan_labels = {chanlocs.labels};
    
    % Standardize clusters input to a cell array of indices
    if ~iscell(clusters)
        clusters = {clusters};
    end
    
    % Initialize cell array to hold cluster indices
    cluster_indices_list = cell(size(clusters));
    
    % Process each cluster to get indices
    for c = 1:length(clusters)
        cluster = clusters{c};
        if iscell(cluster) % Cluster specified as labels
            % Find indices for the given labels
            [found, cluster_indices] = ismember(cluster, chan_labels);
            % Remove any labels that were not found
            cluster_indices = cluster_indices(found);
        elseif isnumeric(cluster) % Cluster specified as indices
            cluster_indices = cluster;
        else
            error('Clusters must be specified as indices or channel labels.');
        end
        cluster_indices_list{c} = cluster_indices;
    end
    
    % Define colors for each cluster
    num_clusters = length(cluster_indices_list);
    colors = lines(num_clusters); % Use MATLAB's "lines" colormap for distinct colors
    
    % Ensure the nose is in the Y+ direction
    % This is the default orientation in EEGLAB's topoplot and headplot
    
    % Check if EEGLAB functions are available
    eeglab_available = exist('topoplot', 'file') == 2;
    
    % Plotting
    if strcmpi(view_mode, 'headplot')
        % Use EEGLAB's headplot function
        if ~eeglab_available
            error('EEGLAB functions are required for headplot view mode.');
        end
        fprintf('Using EEGLAB''s headplot for plotting.\n');
        
        % Set up the headplot if not already set up
        spl_file = 'headplot_temp.spl';
        if ~exist(spl_file, 'file')
            % You may need to adjust 'transform' and 'meshfile' parameters according to your data
            headplotparams = {'meshfile', 'mheadnew.mat', 'transform', [0 0 0 0 0 0 1 1 1]};
            headplot('setup', chanlocs, spl_file, headplotparams{:});
            close; % Close the setup figure
        end
        
        % Prepare data for headplot
        data = zeros(length(chanlocs), 1);
        % Assign cluster numbers to the corresponding channels
        for i = 1:num_clusters
            cluster_indices = cluster_indices_list{i};
            data(cluster_indices) = i;
        end
        
        % Prepare colormap
        cmap = [0.8 0.8 0.8; colors]; % Background channels are light gray
        
        % Plot using headplot
        figure;
        headplot(data, spl_file, 'maplimits', [0 num_clusters+1], 'cbar', 0);
        colormap(cmap);
        colorbar('Ticks', (1:num_clusters)+0.5, 'TickLabels', arrayfun(@(x) ['Cluster ' num2str(x)], 1:num_clusters, 'UniformOutput', false));
        title('EEG Electrode Clusters (Headplot)');
        
        % Optionally show labels (Note: headplot does not support labels directly)
        if show_labels
            % As a workaround, overlay the labels using text()
            hold on;
            for idx = 1:length(chanlocs)
                % Get 3D coordinates
                coord = [chanlocs(idx).X, chanlocs(idx).Y, chanlocs(idx).Z];
                % Transform coordinates if necessary (depending on headplot setup)
                % For simplicity, assume no transformation
                text(coord(1), coord(2), coord(3), chan_labels{idx}, 'HorizontalAlignment', 'center', 'FontSize', 8);
            end
            hold off;
        end
        
    else
        % Use scatter plot
        fprintf('Using scatter plot for plotting.\n');
        % Create figure
        figure; hold on;
        
        % Extract coordinates
        x_all = [chanlocs.X];
        y_all = [chanlocs.Y];
        z_all = [chanlocs.Z];
        
        % Plot all channels in a default color
        if strcmpi(plot_type, '2d')
            % 2D Plot of all channels with nose in Y+ direction
            scatter(y_all, x_all, 50, 'MarkerFaceColor', [0.8, 0.8, 0.8], 'MarkerEdgeColor', 'k', 'DisplayName', 'All Channels');
        elseif strcmpi(plot_type, '3d')
            % 3D Plot of all channels with nose in Y+ direction
            scatter3(y_all, x_all, z_all, 50, 'MarkerFaceColor', [0.8, 0.8, 0.8], 'MarkerEdgeColor', 'k', 'DisplayName', 'All Channels');
        else
            error('Invalid plot type. Use ''2d'' or ''3d''.');
        end
        
        % Loop through each cluster and highlight the channels
        for i = 1:num_clusters
            cluster_indices = cluster_indices_list{i};
            
            % Extract X, Y, and Z coordinates of these channels
            x = [chanlocs(cluster_indices).X];
            y = [chanlocs(cluster_indices).Y];
            z = [chanlocs(cluster_indices).Z];
            
            % Plot according to the plot type
            if strcmpi(plot_type, '2d')
                % 2D Plot with nose in Y+ direction
                scatter(y, x, 100, 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'DisplayName', ['Cluster ' num2str(i)]);
                if show_labels
                    % Add labels
                    for j = 1:length(cluster_indices)
                        idx = cluster_indices(j);
                        text(y_all(idx), x_all(idx), chan_labels{idx}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 8, 'Color', colors(i, :));
                    end
                end
            elseif strcmpi(plot_type, '3d')
                % 3D Plot with nose in Y+ direction
                scatter3(y, x, z, 100, 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'DisplayName', ['Cluster ' num2str(i)]);
                if show_labels
                    % Add labels
                    for j = 1:length(cluster_indices)
                        idx = cluster_indices(j);
                        text(y_all(idx), x_all(idx), z_all(idx), chan_labels{idx}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 8, 'Color', colors(i, :));
                    end
                end
            end
        end
        
        % Add labels and legend
        xlabel('Y');
        ylabel('X');
        if strcmpi(plot_type, '3d')
            zlabel('Z');
        end
        title('EEG Electrode Clusters');
        legend('show');
        grid on;
        axis equal;
        hold off;
        rotate3d on;
    end
end
