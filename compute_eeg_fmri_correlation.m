% Temporally correlate EEG features and FMRI RSN signals 
% Bad epochs (TRs) from EEG and FMRI are not accounted in correlation 

clear all
path = 'C:\Users\marta\OneDrive\Documentos\LASEEB\ICD';

% Define 
metric = 'tf_power'; % tf_power, tf_rmsf_tp, tf_power_norm, tf_rmsf_norm_tp
fs_pos_type = 'fs_tr';

% Datasets, rsns, bands, delays
datasets = "ICD";
rsns = ["VN" "SMN" "DAN" "VAN" "LN" "FPN" "DMN"];
bands = ["Delta", "Theta", "Alpha", "Beta", "Gamma"];
delays = [2, 4, 5, 6, 8, 10];
fs_mid = 4; % 4 Hz 

% For plotting 
colours = ["#0072BD", "#D95319", "#EDB120", ...
    "#7E2F8E", 	"#77AC30", "#4DBEEE"];

% Output directories  
path_img_out = fullfile(path, 'DATASETS/derivatives/imgs');
if ~exist(path_img_out, 'dir'); mkdir(path_img_out); end

for d = 1 : length(datasets)
    
    for rsn = 1 : length(rsns)

        dataset = config_dataset(datasets(d));
        subjs = dataset.subjs;
        runs = dataset.runs;
        n_chans = dataset.n_chans;
        fs_tr = dataset.fs_tr;
        
        if strcmp(fs_pos_type, 'fs_tr'); fs_pos = fs_tr; ...
        elseif strcmp(fs_pos_type, 'fs_mid'); fs_pos = fs_mid; end            

        eeg_fmri_corr = zeros(length(subjs), n_chans, ...
            length(bands), length(delays));
        eeg_fmri_corr_pcb = eeg_fmri_corr;
        eeg_fmri_corr_dmt = eeg_fmri_corr;

        for s = 1 : length(subjs)

            fmri = []; eeg = [];

            % Compute temporal correlations
            for r = 1 : length(runs)

                % Load EEG data and rejected epochs
                path_data_eeg = fullfile(path, 'DATASETS\derivatives\eeg', ...
                    datasets(d), subjs(s));
                path_badtrs = fullfile(path, 'DATASETS\data\eeg', ...
                    subjs(s), runs(r));
                file = strrep(strjoin({'eeg', metric, 'conv', ...
                    strcat(num2str(round(fs_pos, 1)), 'Hz')}, ...
                    '_'), '__', '_');
                load(fullfile(path_data_eeg, strcat(file, '.mat')));
                data(:, 32:end, :, :) = [];
                eeg = reshape(data, [size(data, 1), numel(data(1, :, :, :))]);
                load(fullfile(path_badtrs, 'badtrs.mat'), 'badtrs');

                % Load FMRI data 
                path_data_fmri = fullfile(path, 'DATASETS\derivatives\fmri', ...
                    datasets(d), subjs(s));
                fmri = readmatrix(fullfile(path_data_fmri, strcat('ic_', rsns(rsn), ...
                    '_group_norm_', num2str(round(fs_pos, 1)), 'Hz.txt')));

                % Remove badtrs from first 8 min (pcb)
                id_pcb = 1:240; 
                [id, ~] = (ismember(id_pcb, badtrs));
                id_pcb(id) = []; 

                % Remove badtrs from 8-16 min (dmt)
                id_dmt = 240 : 240 + 239; 
                [id, ~] = (ismember(id_dmt, badtrs));
                id_dmt(id) = [];

                % Reject from analysis eeg and fmri rejected epochs combined 
                fmri(badtrs) = [];
                
                id_pcb = 1 : length(id_pcb); % ids after rem badtrs 
                id_dmt = length(fmri) - length(id_dmt) + 1 : length(fmri); 
                
                % Get PCB and DMT trials 
                fmri_pcb = fmri(id_pcb);
                fmri_dmt = fmri(id_dmt);

                eeg_pcb = eeg(id_pcb, :);
                eeg_dmt = eeg(id_dmt, :);

            end

            eeg_fmri_corr(s, :, :, :) = ...
                reshape(corr(fmri, eeg), ...
                size(squeeze(data(1, :, :, :))));
         
            eeg_fmri_corr_pcb(s, :, :, :) = ...
                reshape(corr(fmri_pcb, eeg_pcb), ...
                size(squeeze(data(1, :, :, :))));

            eeg_fmri_corr_dmt(s, :, :, :) = ...
                reshape(corr(fmri_dmt, eeg_dmt), ...
                size(squeeze(data(1, :, :, :))));

%                 % Plot and save the signals being correlated 
%                 times = 0 : 1/fs_pos : (length(fmri) - 1)/fs_pos;
%                 eeg_plot = reshape(eeg, [length(fmri) size(squeeze(data(1, :, :, :)))]);
% 
%                 for i = 1 : size(eeg_fmri_corr, 3)
%                     fig = figure();
%                     fig.Position(3:4) = fig.Position(3:4)*8;
%                     data_plot = cat(2, squeeze(eeg_plot(:, :, i, 4)), fmri);
%                     data_scale = 5*std(data_plot, [], 2);
% 
%                     for k = 1 : size(eeg_fmri_corr, 4)   
%                         data_plot = cat(2, squeeze(eeg_plot(:, :, i, k)), fmri);
%                         hold on
%                         plot(times', (1:size(data_plot,2)).*...
%                             ones(size(data_plot))+(data_plot./(data_scale)), ...
%                             "Color", colours(k));
%                     end 
% 
%                     xlabel('Time (seconds)', 'FontSize', 18); xlim([0 times(end)]);
%                     title(strcat('EEG', ' (', spaces(sp), ',', " ", ...
%                         bands(i), ')', ' and fMRI', ' (', rsns(rsn), ')', ...
%                         ' data -', " ", datasets(d), ',', ...
%                         " ", subjs(s)), 'FontSize', 24);
%                     yticks(1:size(data_plot, 2));
%                     ylabels = (cat(2, string(1:size(eeg_plot, 2)), "fmri"));
%                     set(gca,'YTickLabel', ylabels, 'Fontsize', 8);
%                     box off     
%                      data_out = strcat('eeg_fmri_', datasets(d), '_', subjs(s), ...
%                         '_', rsns(rsn), '_', spaces(sp), '_', bands(i), '.png');
%                      saveas(gcf, fullfile(path_img_out, data_out));
%                  end
% % 
        end % subjs
        
            % Save output files in output directory 
           file = strrep(strjoin({'eeg-fmri', char(rsns(rsn)), 'corr', ...
                metric, 'conv', strcat(num2str(round(fs_pos, 1)), 'Hz'), ...
                char(datasets(d))}, '_'), '__', '_');
            save(fullfile('DATASETS/derivatives', ...
                strcat(file, '.mat')), 'eeg_fmri_corr');   

            % Save as different datasets PCB and DMT results 
            eeg_fmri_corr = eeg_fmri_corr_pcb;
            file = strrep(strjoin({'eeg-fmri', char(rsns(rsn)), 'corr', ...
                metric, 'conv', strcat(num2str(round(fs_pos, 1)), 'Hz'), ...
                char("ICD-PCB")}, '_'), '__', '_');
            save(fullfile('DATASETS/derivatives', ...
                strcat(file, '.mat')), 'eeg_fmri_corr');  

            eeg_fmri_corr = eeg_fmri_corr_dmt;
            file = strrep(strjoin({'eeg-fmri', char(rsns(rsn)), 'corr', ...
                metric, 'conv', strcat(num2str(round(fs_pos, 1)), 'Hz'), ...
                char("ICD-DMT")}, '_'), '__', '_');
            save(fullfile('DATASETS/derivatives', ...
                strcat(file, '.mat')), 'eeg_fmri_corr');                    

    end % rsns
  
end % datasets
