function labels = assign_electrode_labels(EEG, scheme)
    % assign_electrode_labels - Assign labels to electrode positions in EEG.chanlocs
    % and plot in 3D with color based on region labels.
    %
    % Usage:
    %   labels = assign_electrode_labels(EEG, 'basic')   % for basic regions
    %   labels = assign_electrode_labels(EEG, 'complex') % for detailed regions
    %
    % Inputs:
    %   EEG - EEG structure with EEG.chanlocs containing x, y, z coordinates
    %   scheme - 'basic' for larger clusters, 'complex' for more specific clusters
    %
    % Outputs:
    %   labels - Cell array of labels assigned to each electrode
    
    % Validate input for scheme
    if nargin < 2
        scheme = 'complex'; % Default to complex if no scheme specified
    end
    
    % Extract electrode coordinates
    X = [EEG.chanlocs.X];
    Y = [EEG.chanlocs.Y];
    Z = [EEG.chanlocs.Z];
    
    numElectrodes = length(EEG.chanlocs);
    labels = cell(numElectrodes, 1);

    % Define region-based colors for complex and basic schemes
    if strcmp(scheme, 'complex')
        regionColors = containers.Map();
        regionColors('Frontal Left') = [1, 0, 0];
        regionColors('Frontal Midline') = [1, 0.5, 0.2];
        regionColors('Frontal Right') = [1, 0.6, 0];
        regionColors('Central Left') = [0.6, 0.8, 0];
        regionColors('Central Midline') = [0, 1, 0];
        regionColors('Central Right') = [0.3, 0.7, 0.5];
        regionColors('Parietal Left') = [0, 0.5, 1];
        regionColors('Parietal Midline') = [0, 0, 1];
        regionColors('Parietal Right') = [0.5, 0.3, 0.8];
        regionColors('Occipital Left') = [0.6, 0.3, 0.9];
        regionColors('Occipital Midline') = [0.5, 0, 1];
        regionColors('Occipital Right') = [0.3, 0, 0.6];
        regionColors('Temporal Left') = [0.5, 0.5, 0.5];
        regionColors('Temporal Right') = [0.7, 0.7, 0.7];
    else
        regionColors = containers.Map();
        regionColors('Frontal') = [1, 0.4, 0.4];
        regionColors('Central') = [0.5, 1, 0.5];
        regionColors('Parietal') = [0.4, 0.4, 1];
        regionColors('Occipital') = [0.8, 0.5, 1];
        regionColors('Temporal') = [0.7, 0.7, 0.7];
    end

    % Assign labels and colors based on scheme
    colors = zeros(numElectrodes, 3);
    for i = 1:numElectrodes
        % Normalize coordinates for label assignment
        xi = X(i);
        yi = Y(i);
        zi = Z(i);
        
        % Determine label based on selected scheme
        if strcmp(scheme, 'complex')
            % Complex labeling with hemispheres and midlines
            if yi > 0 % Frontal
                if xi < 0
                    label = 'Frontal Left';
                elseif xi > 0
                    label = 'Frontal Right';
                else
                    label = 'Frontal Midline';
                end
            elseif yi <= 0 && yi > -0.5 % Central
                if xi < 0
                    label = 'Central Left';
                elseif xi > 0
                    label = 'Central Right';
                else
                    label = 'Central Midline';
                end
            elseif yi <= -0.5 && yi > -1 % Parietal
                if xi < 0
                    label = 'Parietal Left';
                elseif xi > 0
                    label = 'Parietal Right';
                else
                    label = 'Parietal Midline';
                end
            else % Occipital
                if xi < 0
                    label = 'Occipital Left';
                elseif xi > 0
                    label = 'Occipital Right';
                else
                    label = 'Occipital Midline';
                end
            end
        else
            % Basic labeling with larger regions
            if yi > 0 % Frontal
                label = 'Frontal';
            elseif yi <= 0 && yi > -0.5 % Central
                label = 'Central';
            elseif yi <= -0.5 && yi > -1 % Parietal
                label = 'Parietal';
            else % Occipital
                label = 'Occipital';
            end
        end

        % Store label and color
        labels{i} = label;
        if isKey(regionColors, label)
            colors(i, :) = regionColors(label);
        else
            colors(i, :) = [0.5, 0.5, 0.5]; % default color for undefined regions
        end
    end

    % Plot electrodes in 3D with colors based on labels
    figure;
    scatter3(X, Y, Z, 50, colors, 'filled');
    hold on;
    for i = 1:numElectrodes
        text(X(i), Y(i), Z(i), EEG.chanlocs(i).labels, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title('3D Electrode Positions with Region-Based Colors');
    rotate3d on;
    axis square;

    % Add legend for region colors
    uniqueLabels = unique(labels);
    legendEntries = cell(1, length(uniqueLabels));
    for j = 1:length(uniqueLabels)
        color = regionColors(uniqueLabels{j});
        scatter3(nan, nan, nan, 50, color, 'filled'); % Invisible points for legend
        legendEntries{j} = uniqueLabels{j};
    end
    legend(legendEntries, 'Location', 'bestoutside');
end
