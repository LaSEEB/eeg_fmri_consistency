% Check normality of data with the Shapiro-Wilk test

clear all
path = 'C:\Users\marta\OneDrive\Documentos\LASEEB\EEG-fMRI Consistency';
path_data = fullfile(path, 'DATASETS\consist'); 

% Change  
metric = 'tf_power_norm'; %

% RSNs, frequency bands, HRF delays, spaces
rsns = ["VN" "SMN" "DAN" "VAN" "LN" "FPN" "DMN"];
bands = ["Delta", "Theta", "Alpha", "Beta", "Gamma"];
delays = ["2", "4", "5", "6", "8", "10"];
datasets = ["64Ch1.5T", "64Ch3T", "64Ch7T"];
spaces = ["Scalp", "Desikan"];

n_dk = 68;
n_subjs_max = 23; % change 

% How it's called in the manuscript 
datasets_id = erase(datasets, '64Ch');
delays_id = strcat(delays,'s');

% Update and create output directories 
path_data = fullfile(path_data, metric); 

% Consistency data 
load(fullfile(path_data, 'eeg_fmri_corr.mat'));

%% Correlations

corr_data = nan(length(spaces), length(datasets), length(rsns), ...
    length(bands), length(delays), n_dk, n_subjs_max);

for sp = 1 : length(spaces)
    for d = 1 : length(datasets)
        n_chans = eeg_fmri_corr(d).n_chans;
        n_subjs = eeg_fmri_corr(d).n_subjs;
        if strcmp(spaces(sp), 'Desikan')
            n_chans = n_dk; 
            corr_data(sp, d, :, :, :, 1:n_chans, 1:n_subjs) =  permute(eeg_fmri_corr(d).pcorr_dk, [1 3 5 4 2]);
        elseif strcmp(spaces(sp), 'Scalp')
            corr_data(sp, d, :, :, :, 1:n_chans, 1:n_subjs) = permute(eeg_fmri_corr(d).pcorr_scalp, [1 3 5 4 2]);
        end
    end % datasets
end % spaces 

corr_data = squeeze(mean(mean(corr_data, 6, 'omitnan'), 1, 'omitnan')); 

%% Check normality 

norm_test = zeros(size(squeeze(mean(corr_data, 5))));
norm_test_pval = norm_test;

for a = 1 : size(corr_data, 1)
    for b = 1 : size(corr_data, 2)
        for c = 1 : size(corr_data, 3) 
            for d = 1 : size(corr_data, 4)
                [norm_test(a, b, c, d), norm_test_pval(a, b, c, d)] = ...
                    swtest(squeeze(corr_data(a, b, c, d, :)));
            end
        end
    end
end

norm_test_custom = norm_test_pval > 0.01;