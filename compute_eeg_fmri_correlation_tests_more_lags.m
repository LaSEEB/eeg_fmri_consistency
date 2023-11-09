clear all
path = 'C:\Users\marta\OneDrive\Documentos\LASEEB\ICD';
path_out = fullfile(path, 'DATASETS\consist'); 

% Define 
metric = 'tf_power'; % tf_power, tf_rmsf_tp, tf_power_norm, tf_rmsf_norm_tp
fs_pos_type = 'fs_tr';

% Datasets, rsns, bands, delays
datasets = ["ICD", "ICD-PCB", "ICD-DMT"];
rsns = ["VN" "SMN" "DAN" "VAN" "LN" "FPN" "DMN"];
bands = ["Delta", "Theta", "Alpha", "Beta", "Gamma"];
delays = 0 : 1 : 20;
fs_mid = 4; % 4 Hz 

% Update and create output directories 
path_out = fullfile(path_out, metric); 
path_img_out = fullfile(path_out, 'imgs');

if ~exist(path_out, 'dir'); mkdir(path_out); end
if ~exist(path_img_out, 'dir'); mkdir(path_img_out); end

%% Retreive correlation data
% Save eeg-fmri correlation data 

eeg_fmri_corr_struct = struct;
for d = 1 : length(datasets)
    
    dataset = config_dataset(datasets(d));
    if strcmp(fs_pos_type, 'fs_tr'); fs_pos = dataset.fs_tr; ...
    elseif strcmp(fs_pos_type, 'fs_mid'); fs_pos = fs_mid; end    

    eeg_fmri_corr_struct(d).dataset = datasets(d);
    eeg_fmri_corr_struct(d).n_rsns = length(rsns);
    eeg_fmri_corr_struct(d).n_subjs = length(dataset.subjs);
    eeg_fmri_corr_struct(d).n_chans = dataset.n_chans;
    eeg_fmri_corr_struct(d).chanlocs = dataset.chanlocs;       
    eeg_fmri_corr_struct(d).pcorr_scalp = ...
        zeros(length(rsns), length(dataset.subjs), ...
        length(bands), dataset.n_chans, length(delays));

    for r = 1 : length(rsns)

        path_data = fullfile(path, 'DATASETS\derivatives');

        file = strrep(strjoin({'eeg-fmri', char(rsns(r)), ...
            'corr', metric, 'conv_lags', strcat(num2str(round(fs_pos, 1)), 'Hz'), ...
            char(datasets(d))}, '_'), '__', '_');

        load(fullfile(path_data, strcat(file, '.mat')));
        data = permute(eeg_fmri_corr, [1 3 2 4]);
        eeg_fmri_corr_struct(d).pcorr_scalp(r, :, :, :, :) =  data;        

    end % rsns
    
end % datasets

% Save eeg_fmri_corr structure
eeg_fmri_corr = eeg_fmri_corr_struct; clear eeg_fmri_corr_struct; 
save(fullfile(path_out, 'eeg_fmri_corr_lags.mat'), 'eeg_fmri_corr');
