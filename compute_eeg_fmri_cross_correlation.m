% Temporally correlate EEG features and FMRI RSN signals 
% EEG features without HRF convolution, but adding a delay from -20s to 20s
% If a dataset has more than one run, temporally concatenate data for each
% subject before computing correlation 
% 
clear all

path = 'C:\Users\marta\OneDrive\Documentos\LASEEB\EEG-fMRI Consistency';
path_out = fullfile(path, 'DATASETS\consist'); 

% Define 
metric = 'tf_power'; % tf_power, tf_rmsf_tp
fs_pos_type = 'fs_tr';
max_lag = 20;

% RSNs, bands, HRF delays
rsns = ["VN" "SMN" "DAN" "VAN" "LN" "FPN" "DMN"];
bands = ["Delta", "Theta", "Alpha", "Beta", "Gamma"];
datasets = ["64Ch1.5T", "64Ch7T"];
fs_mid = 4; % 4 Hz 

% Update and create output directories 
path_out = fullfile(path_out, metric); 
path_img_out = fullfile(path_out, 'imgs\cross');

if ~exist(path_out, 'dir'); mkdir(path_out); end
if ~exist(path_img_out, 'dir'); mkdir(path_img_out); end

%% Compute cross-correlation 
    
for d = 1 : length(datasets)
    
    for rsn = 1 : length(rsns)

        dataset = config_dataset(datasets(d));
        subjs = dataset.subjs;
        runs = dataset.runs;
        n_chans = dataset.n_chans;
        fs_tr = dataset.fs_tr;
        max_lag_n = round(max_lag*fs_tr);
        
        if strcmp(fs_pos_type, 'fs_tr'); fs_pos = fs_tr; ...
        elseif strcmp(fs_pos_type, 'fs_mid'); fs_pos = fs_mid; end            

        eeg_fmri_cross_corr = zeros(length(subjs), ...
            n_chans*length(bands), max_lag_n*2 + 1);

        for s = 1 : length(subjs)

            fmri = []; eeg = [];

            % Compute temporal correlations
            for r = 1 : length(runs)

                % Load eeg-fmri markers 
                load(fullfile(path, 'DATASETS\derivatives\EEG', ...
                    datasets(d), subjs(s), runs(r), ...
                    'markers_first-scan_last-scan.mat'));
                first = scan_first_last(1); last = scan_first_last(end);
                first = round(first*fs_pos + 1);
                last = round(last*fs_pos + 1);
                if first == 0
                    first = first + 1;
                    last = last + 1;
                end                    

                % Load EEG data
                path_data_eeg = fullfile(path, 'DATASETS\derivatives\EEG', ...
                    datasets(d), subjs(s), runs(r));
                file = strrep(strjoin({'eeg', metric, ...
                    strcat(num2str(round(fs_pos, 1)), 'Hz')}, ...
                    '_'), '__', '_');
                load(fullfile(path_data_eeg, strcat(file, '.mat')));
                eeg_run = reshape(data, [size(data, 1), numel(data(1, :, :, :))]);

                % Load FMRI data 
                path_data_fmri = fullfile(path, 'DATASETS\derivatives\FMRI', ...
                    datasets(d), subjs(s), runs(r));
                fmri_run = readmatrix(fullfile(path_data_fmri, strcat('ic_', rsns(rsn), ...
                    '_group_norm_', num2str(round(fs_pos, 1)), 'Hz.txt')));

                % Concatenate runs 
                fmri = cat(1, fmri, fmri_run);
                eeg = cat(1, eeg, eeg_run);

            end

            eeg = eeg(first:last, :);

            % Loop across eeg features
            for f = 1 : size(eeg, 2)
                [eeg_fmri_cross_corr(s, f, :), lags] = ...
                    xcorr(eeg(:, f), fmri,  max_lag_n, 'normalized');
            end

         end % subjs

            eeg_fmri_cross_corr_avg = reshape(eeg_fmri_cross_corr, ...
                [length(subjs) length(bands) n_chans max_lag_n*2+1]);
            eeg_fmri_cross_corr_avg = squeeze(mean(mean(eeg_fmri_cross_corr_avg, ...
                1), 3));
        
            % Plot          
            fig = figure(); 
            fig.Position(3) = fig.Position(3)*100;
            fig.Position(4) = fig.Position(4)*100;
            for b = 1 : length(bands)
                plot(lags*(1/fs_tr), eeg_fmri_cross_corr_avg(b,:), ...
                    'LineWidth', 1); hold on 
            end
            title('Avg. (chans/ROIs, subjs.) cross-corr. between EEG power and BOLD');
            xlabel('Lag (s) of EEG rel. to BOLD');
            ylabel('Correlation');  
            grid on;
            legend('Power Delta - BOLD', 'Power Theta - BOLD', ...
                'Power Alpha - BOLD', 'Power Beta - BOLD', 'Power Gamma - BOLD');
            img_out = strcat('cross-corr_', rsns(rsn), '_', ...
                datasets(d), '.png');
            saveas(gcf, fullfile(path_img_out, img_out), 'png');                

    end % rsns
  
end % datasets