% Matrices of EEG-fMRI correlation across delays
% Figure 6

clear all
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
delays = string(0 : 1 : 20);

% Update and create output directories 
path_out = fullfile(path_out, metric); 
path_img_out = fullfile(path_out, 'imgs');

if ~exist(path_out, 'dir'); mkdir(path_out); end
if ~exist(path_img_out, 'dir'); mkdir(path_img_out); end

% Correlation data
load(fullfile(path, 'DATASETS\consist\', metric, '\eeg_fmri_corr_lags.mat'));

q = 0.05; % significance level
%% Retreive data  

% Retreive correlation data 
corr_data = nan(length(datasets), length(rsns), ...
    length(bands), length(delays), n_chans, n_subjs);

for d = 1 : length(datasets)
    n_chans = eeg_fmri_corr(d).n_chans;
    n_subjs = eeg_fmri_corr(d).n_subjs;
    corr_data(d, :, :, :, 1:n_chans, 1:n_subjs) = ...
        permute(eeg_fmri_corr(d).pcorr_scalp, [1 3 5 4 2]);
end % datasets

% Mean across channels 
corr_data = squeeze(mean(corr_data, 5, 'omitnan')); 


%% Plot data - Correlation evolution with delay 
% One figure for each space
% Datasets x RSNs

% Just so it is the same as topoplots 
data_lims =   [-0.0786    0.0786; ...
               -0.0441    0.0441; ...
               -0.1146    0.1146];

% T-test against zero and decision 
pval = zeros(size(mean(corr_data, 5)));
decision = zeros(size(pval));
q_corrected = zeros(length(datasets), 1);

for d = 1 : length(datasets)

    % T-test and FDR correction 
    corr_data_d = squeeze(corr_data(d, :, :, :, :));
    [~, pval_d, ~, ~] = ttest(permute(corr_data_d, [4 1 2 3]));
    [decision_d, q_corrected_d, ~, ~] = ...
        fdr_bh(pval_d(:), q, 'pdep', 'no');

    % Global variables
    pval(d, :, :, :) = pval_d;
    decision(d, :, :, :) = reshape(decision_d, size(pval_d));
    q_corrected(d) = q_corrected_d;

end % datasets
decision = logical(decision);

% Uncorrected 
decision_un = zeros(size(pval)); decision_un(pval<q) = 1;
decision_un = decision_un - decision;
decision_un = logical(decision_un);

fig = figure();
fig.Position(3) = 1400;
fig.Position(4) = 600;
t = tiledlayout(length(eeg_fmri_corr), length(rsns), 'TileSpacing', 'compact');      

for d = 1 : length(eeg_fmri_corr)

    data_img = squeeze(corr_data(d, :, :, :, :));
    data_img = permute(data_img, [1 3 2 4]);

    % Mean across subjects
    data_img = squeeze(mean(data_img, 4, 'omitnan'));         

    for r = 1 : length(rsns)

        nexttile;

        data_img_current = squeeze(data_img(r, :, :));
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
        ax.YTick = 1 : 2 : length(delays);  
        ax.YTickLabel = "";

%            % Band labels 
%             if (d == length(eeg_fmri_corr))
%                 ax.XTickLabel = bands;
%                 ax.FontSize = 24;
%             end

        % Band labels
        if (d == 1)
            ax.XTickLabel = bands;
            ax.FontSize = 10;
            ax.FontWeight = 'bold';
            ax.XAxisLocation = 'top';
            ax.XTickLabelRotation = 45;
        end

        % Delay labels
        if (r == 1)
            ax.YTickLabel = strcat(delays(1 : 2 : end), 's');   
            ax.FontSize = 10;
            ax.FontWeight = 'bold';
        end         

         % Space title 
         if (d == 1)
             title(rsns(r), 'FontWeight', 'bold', 'FontSize', 20);
         end

         % Dataset title 
         if (r == 1)
             ylabel(erase(eeg_fmri_corr(d).dataset, '64Ch'), ...
                 'FontWeight', 'bold', 'FontSize', 20)
         end

         hold on;
         decision_un_current = squeeze(decision_un(d, r, :, :));
         [row, col] = find(decision_un_current);
         plot(row, col, '.', 'MarkerEdgeColor', ...
             'r', 'MarkerFaceColor', 'none');

    end % rsns

end % datasets

%    c = colorbar;
%    c.Layout.Tile = 'east';
%      ylabel(c, 'Corr.', 'FontSize', 14, 'FontWeight', 'bold', ...
%          'Rotation', 270, 'Position', [5 0.05 0.5]);
%    title(t, 'Correlation - Mean Across Subjects and Channels/Nodes');

img_out = strcat('eeg_fmri_corr_', metric, '_delay_evol.png');
print(gcf, fullfile(path_img_out, img_out), '-dpng', '-r1000');  
