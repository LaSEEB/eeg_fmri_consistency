% Get EEG TF power signals in the TR frequency or an intermediate ('mid') frequency
% Convolve EEG features with a range of HRF functions
% Normalize EEG features to have zero mean and standard deviation 1
% Save output EEG features
% More lags

path = 'C:\Users\marta\OneDrive\Documentos\LASEEB\ICD';

% Change 
metric = 'tf_power'; % tf_power, tf_rmsf_tp, tf_power_norm, tf_rmsf_norm_tp
hrf_T = 32; % 32-second HRF
fs_pos_type = 'fs_tr';

% Datasets, delays
datasets = "ICD";
delays = 0:1:20;
fs_mid = 4; % 4 Hz 
    
for d = 1 : length(datasets)

    dataset = config_dataset(datasets(d));
    subjs = dataset.subjs;
    runs = dataset.runs;
    n_chans = dataset.n_chans;
    fs_tr = dataset.fs_tr;
    fs_pre = dataset.fs_pre;
    
    if strcmp(fs_pos_type, 'fs_tr'); fs_pos = fs_tr; ...
    elseif strcmp(fs_pos_type, 'fs_mid'); fs_pos = fs_mid; end
    
    for s = 1 : length(subjs)

        for r = 1 : length(runs)

            % Load data 
            load(fullfile(path, 'DATASETS/derivatives/eeg', ...
                datasets(d), subjs(s), ...
                strcat('eeg_', metric, '_', num2str(round(fs_pre, 1)), ...
                'Hz.mat')));

            % HRF convolution
            data_conv = zeros([size(data) length(delays)]);
            for c = 1 : n_chans
                data_conv(:, c, :, :) = ...
                    convolve_features_fast_expanded(squeeze(abs(data(:, c, :))), ...
                    fs_pre, delays, 32);
            end
            data = data_conv;         

            % Downsample - this is not tested yet 
            n_pnts_pre = size(data, 1);
            time_pre =  0 : 1/fs_pre : (n_pnts_pre - 1)/fs_pre;
            time_pos = 0 : 1/fs_pos : (n_pnts_pre - 1)/fs_pre;
            data = permute(data, [2 3 4 1]); % time must be last dimension 

            data_down = zeros([size(data,1) size(data, 2) size(data, 3) length(time_pos)]);  
            for c = 1 : n_chans
                data_down(c, :, :, :) = spline(time_pre, squeeze(data(c, :, :, :)), time_pos);   
            end
            data = permute(data_down, [4 1 2 3]); % permute back
            n_pnts_pos = size(data, 1);

            % Normalize 
            data_norm = zscore(reshape(data, [n_pnts_pos, numel(data(1, :, :, :))]));
            data = reshape(data_norm, size(data));

            %if (~isreal(data)); error('data not real'); end

            % Save
            save(fullfile(path, 'DATASETS\derivatives\eeg', datasets(d), ...
                subjs(s), strcat('eeg_', metric, '_conv_lags_', ...
                num2str(round(fs_pos, 1)), 'Hz.mat')), 'data');

        end % runs 

    end % subjects

end % datasets