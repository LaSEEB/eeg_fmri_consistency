% Matrices of EEG-fMRI correlation across delays
% Figure 2 - Part 2 (Matrices)

clear all 

%% Data specification 

path = 'C:\Users\marta\OneDrive\Documentos\LASEEB\ICD';
path_out = fullfile(path, 'DATASETS\consist'); 

% Define  
metric = 'tf_power'; 
n_chans = 31;
n_subjs = 14;

% Datasets, RSNs, Bands, HRF delays
datasets = ["ICD", "ICD-PCB", "ICD-DMT"];
rsns = ["VN" "SMN" "DAN" "VAN" "LN" "FPN" "DMN"];
bands = ["Delta", "Theta", "Alpha", "Beta", "Gamma"];
delays = ["2", "4", "5", "6", "8", "10"];

% Update and create output directories 
path_out = fullfile(path_out, metric); 
path_img_out = fullfile(path_out, 'imgs');

if ~exist(path_out, 'dir'); mkdir(path_out); end
if ~exist(path_img_out, 'dir'); mkdir(path_img_out); end

% Correlation data
load(fullfile(path, 'DATASETS\consist\', metric, '\eeg_fmri_corr.mat'));

%% Retreive data  

% Retreive correlation data 
corr_data = nan(length(datasets), length(rsns), ...
    length(bands), length(delays), n_chans, n_subjs);

for d = 1 : length(datasets)
    n_chans = eeg_fmri_corr(d).n_chans;
    n_subjs = eeg_fmri_corr(d).n_subjs;
    corr_data(d, :, :, :, 1:n_chans, 1:n_subjs) = permute(eeg_fmri_corr(d).pcorr_scalp, [1 3 5 4 2]);
end % datasets

% Mean across channels 
corr_data = squeeze(mean(corr_data, 5, 'omitnan')); 

%% Plot data - Correlation evolution with delay 
% One figure for each RSN

% Just so it is the same as topoplots 

% One for all datasets 
data_lims = zeros(1, 2);
for d = 1 : length(eeg_fmri_corr)
    data = squeeze(mean(eeg_fmri_corr(d).pcorr_scalp(:, :, :, :, 4), 2));
    max_min_data = max(quantile(data(:), 0.99), abs(quantile(data(:), 0.01)));
    max_min_data = max(max_min_data, data_lims(2));
    data_lims = [-max_min_data max_min_data];
end
data_lims = repmat(data_lims, length(eeg_fmri_corr), 1);


% One for each dataset
% data_lims = zeros(length(datasets), 2);
% for d = 1 : length(eeg_fmri_corr)
%     data = squeeze(mean(eeg_fmri_corr(d).pcorr_scalp(:, :, :, :, 4), 2));
%     max_min_data = max(quantile(data(:), 0.97), abs(quantile(data(:), 0.03)));
%     data_lims(d, :) = [-max_min_data max_min_data];
% end

for r = 1 : length(rsns)

    fig = figure();
    fig.Position(3) = 600;
    fig.Position(4) = fig.Position(4)*100;
    t = tiledlayout(length(eeg_fmri_corr), 1, 'TileSpacing', 'compact');      

    for d = 1 : length(eeg_fmri_corr)

        data_img = squeeze(corr_data(d, r, :, :, :));
        data_img = permute(data_img, [2 1 3]);
    
        % Mean across subjects
        data_img = squeeze(mean(data_img, 3, 'omitnan'));         

        nexttile;

        data_img_current = data_img;
        im = imagesc(data_img_current);
        mycolor = 'parula';
        colormap(mycolor); 
        clim(data_lims(d, :));  
        im.AlphaData = 1;
        axis square;   
        ax = gca;
        ax.XAxisLocation = 'bottom';
        ax.XTick = 1 : length(bands);
        ax.XTickLabel = "";
        ax.YAxisLocation = 'left';
        ax.YTick = 1 : length(delays);  
        ax.YTickLabel = "";

%            % Band labels 
%             if (d == length(eeg_fmri_corr))
%                 ax.XTickLabel = bands;
%                 ax.FontSize = 24;
%             end

        % Band labels
        if (d == 1)
            ax.XTickLabel = bands;
            ax.FontSize = 24;
            ax.FontWeight = 'bold';
            ax.XAxisLocation = 'top';
            ax.XTickLabelRotation = 45;
        end

        % Delay labels
        ax.YTickLabel = strcat(delays, 's');   
        ax.FontSize = 24;
        ax.FontWeight = 'bold';     

          % Dataset title 
          ylabel(erase(eeg_fmri_corr(d).dataset, '64Ch'), ...
              'FontWeight', 'bold', 'FontSize', 20)

    end % datasets
    
%    c = colorbar;
%    c.Layout.Tile = 'east';
%     ylabel(c, 'Corr.', 'FontSize', 14, 'FontWeight', 'bold', ...
%         'Rotation', 270, 'Position', [5 0.05 0.5]);
%    title(t, 'Correlation - Mean Across Subjects and Channels/Nodes');
    
    img_out = strcat('eeg_fmri_corr_', metric, '_', rsns(r), '_delay_evol.png');
    print(gcf, fullfile(path_img_out, img_out), '-dpng', '-r1000');  

end % rsns
