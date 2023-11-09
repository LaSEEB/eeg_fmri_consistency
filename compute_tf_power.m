% Compute time-frequency power in the defined freq. bands 

clear all

% Input and output directories 
path_in = strcat('C:\Users\marta\OneDrive\Documentos\LASEEB\', ...,
    'ICD\DATASETS\data\eeg');
path_out = strcat('C:\Users\marta\OneDrive\Documentos\LASEEB\', ...,
    'ICD\DATASETS\derivatives\eeg');

% Define
data_in = 'ContinuousEEG.mat';
data_out = 'eeg_tf_power';
datasets = "ICD";
run = "ses-DMT";

% TF definitions
tf_method = 'wavelet';
f_min = 1;
f_max = 60;
n_freq = 60;
tf_sliding_win_seconds = 4;  
tf_wavelet_kernel_seconds = 2; 
n_wins_welch = 8;
fs_eeg = 250;

% Frequency bands 
bands = [2 4; 5 7; 8 12; 15 29; 30 60]; 

%% Perform TF decomposition 

for d = 1 : length(datasets)

    dataset = config_dataset(datasets(d));

    runs = dataset.runs;
    subjs = dataset.subjs;
    n_chans = dataset.n_chans;
    fs_pre = dataset.fs_pre;
    fs_tr = dataset.fs_tr;    

    data_out = strcat(data_out, '_', num2str(round(fs_pre, 1)), 'Hz.mat');

    for s = 11 : length(subjs)

        % Load data for current subject 
        data = load(fullfile(path_in, subjs(s), run, data_in));
        data = data.EEG_continuous;
       
        [power, f_vector] = tf_analysis_power_spectrum...
                    (data', [f_min f_max], n_freq, tf_method, ...
                    tf_wavelet_kernel_seconds, tf_sliding_win_seconds, ...
                    n_wins_welch, fs_eeg, fs_eeg);

        % Average into frquency bands
        band_power = zeros([size(data') length(bands)]);
        for  b = 1 : length(bands)
            ids = logical(f_vector >= bands(b, 1) ...
                    & f_vector < bands(b, 2));   
            band_power(:, :, b) = mean(power(:, :, ids), 3);
        end 
        data = band_power; 
        clear band_power power

        % Save output data 
        if ~exist(fullfile(path_out, datasets(d), subjs(s)), 'dir')
            mkdir(fullfile(path_out, datasets(d), subjs(s)));
        end
        save(fullfile(path_out, datasets(d), subjs(s), data_out), 'data');
        clear data

    end % subjects 

end % datasets 
