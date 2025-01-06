function [EEG, rej_list, ica_class] = ica_criterion_test(EEG, elim_chans, varargin)
    % Perform ICA and reject components based on ICLabel classification.
    %
    % Usage:
    %   [EEG, rej_list, ica_class] = ica_criterion(EEG, elim_chans, 'Method1', Threshold1, 'Method2', Threshold2, ...)
    %
    % Inputs:
    %   EEG         - EEGLAB EEG data structure or array of EEG structures.
    %   elim_chans  - Number of channels eliminated (e.g., interpolated or removed).
    %   varargin    - Pairs of methods and thresholds. For example:
    %                 'Brain', 0.5, 'EMG', 0.3, 'Eye', 0.2
    %
    % Outputs:
    %   EEG         - EEG data structure with specified components rejected.
    %   rej_list    - Vector indicating which components were rejected (1 for rejected, 0 for retained).
    %   ica_class   - ICLabel classifications for each component.
    %
    % Example:
    %   [EEG_clean, rej_list, ica_class] = ica_criterion(EEG, 0, 'Brain', 0.5, 'EMG', 0.3);
    %
    % This function performs the following steps:
    %   1. Run ICA on the EEG data, reducing the rank if needed.
    %   2. Use ICLabel to classify the components.
    %   3. Reject components based on specified methods and thresholds.
    %   4. Return the modified EEG data, rejection list, and IC classifications.

    %% Input Validation and Parsing

    % Set default value for elim_chans if not provided
    if nargin < 2 || isempty(elim_chans)
        elim_chans = 0;
    end

    % Check that varargin has an even number of elements (method and threshold pairs)
    if mod(length(varargin), 2) ~= 0
        error('You must provide method and threshold pairs.');
    end

    % Extract methods and thresholds from varargin
    method = varargin(1:2:end);
    threshold = varargin(2:2:end);

    % Convert thresholds to numeric values and adjust if necessary
    threshold = cellfun(@(x) double(x), threshold);
    threshold(threshold > 1) = threshold(threshold > 1) / 100; % Convert percentages to fractions

    % Process method names: convert to lower case and remove extra spaces
    method = cellfun(@(x) strtrim(lower(x)), method, 'UniformOutput', false);

    %% Initialize Outputs
    rej_list = [];
    ica_class = [];

    %% Determine if EEG is an Array of Datasets
    if numel(EEG) > 1
        numDatasets = numel(EEG);
    else
        numDatasets = 1;
    end

    %% Process Each EEG Dataset
    for s = 1:numDatasets
        if numDatasets > 1
            EEG_current = EEG(s);
        else
            EEG_current = EEG;
        end

        % Determine data rank, accounting for eliminated channels
        dataRank = EEG_current.nbchan - elim_chans;

        %% Run ICA with PCA Dimension Reduction
        EEG_current = pop_runica(EEG_current, 'icatype', 'runica', 'pca', dataRank);

        %% Use ICLabel to Classify Components
        EEG_current = pop_iclabel(EEG_current, 'default');

        % Get ICLabel classifications
        ica_class = EEG_current.etc.ic_classification.ICLabel.classifications;

        % Number of Independent Components
        numICs = size(ica_class, 1);

        % Initialize rejection list
        rej_list = zeros(numICs, 1);

        %% Define Method Information Mapping
        method_info = struct(...
            'brain', struct('class_idx', 1, 'reject_if_less', true), ...
            'muscle', struct('class_idx', 2, 'reject_if_less', false), ...
            'emg', struct('class_idx', 2, 'reject_if_less', false), ...
            'eye', struct('class_idx', 3, 'reject_if_less', false), ...
            'heart', struct('class_idx', 4, 'reject_if_less', false), ...
            'line noise', struct('class_idx', 5, 'reject_if_less', false), ...
            'line_noise', struct('class_idx', 5, 'reject_if_less', false), ...
            'linenoise', struct('class_idx', 5, 'reject_if_less', false), ...
            'channel noise', struct('class_idx', 6, 'reject_if_less', false), ...
            'channel_noise', struct('class_idx', 6, 'reject_if_less', false), ...
            'other', struct('class_idx', 7, 'reject_if_less', false) ...
        );

        %% Apply Rejection Criteria
        for k = 1:length(method)
            method_name = method{k};
            thresh = threshold(k);

            % Get method info
            if isfield(method_info, method_name)
                class_idx = method_info.(method_name).class_idx;
                reject_if_less = method_info.(method_name).reject_if_less;

                if reject_if_less
                    % Reject components where class probability is less than threshold
                    rej_indices = find(ica_class(:, class_idx) < thresh);
                else
                    % Reject components where class probability is greater than threshold
                    rej_indices = find(ica_class(:, class_idx) > thresh);
                end
                % Mark these components for rejection
                rej_list(rej_indices) = 1;
            else
                error(['Unknown method name: ', method_name]);
            end
        end

        %% Reject Components
        % Find components to reject
        ic_rej_list = find(rej_list);

        % Reject components using pop_subcomp
        try
            EEG_current = pop_subcomp(EEG_current, ic_rej_list, 0);
        catch ME
            warning('ICA criteria too aggressive! Lower the threshold for ICA rejection.');
            rethrow(ME);
        end
        EEG_current = eeg_checkset(EEG_current);

        % Store the modified EEG dataset back
        if numDatasets > 1
            EEG(s) = EEG_current;
        else
            EEG = EEG_current;
        end
    end
end
