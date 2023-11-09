% Create a figure with the consistency barplots 
% Figure 3
% Correlation (avg. channel/node) bar/boxplots, w/ significance (t.-test)

%  Bar plots, fig. 4 -> boxplots or barplots w/ error bars (subjs),
%  and stars in different from zero topography

%% Data specification 

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
delays = ["2", "4", "5", "6", "8", "10"];

% Update and create output directories 
path_out = fullfile(path_out, metric); 
path_img_out = fullfile(path_out, 'imgs');

if ~exist(path_out, 'dir'); mkdir(path_out); end
if ~exist(path_img_out, 'dir'); mkdir(path_img_out); end

% Correlation data
load(fullfile(path, 'DATASETS\consist\', metric, '\eeg_fmri_corr.mat'));

q = 0.05; % significance level

%% Retreive data  

% Retreive correlation data 
corr_data = nan(length(datasets), length(rsns), ...
    length(bands), length(delays), n_chans, n_subjs);

for d = 1 : length(datasets)
    n_chans = eeg_fmri_corr(d).n_chans;
    n_subjs = eeg_fmri_corr(d).n_subjs;
    corr_data(d, :, :, :, :, :) = permute(eeg_fmri_corr(d).pcorr_scalp, [1 3 5 4 2]);
end % datasets

% Mean across channels 
corr_data = squeeze(mean(corr_data, 5, 'omitnan')); 

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

%% Color settings 

% Define colors to plot 
colors = ["#0072bd" "#2084c5" "#4095ce" "#60a7d6" "#80b9de" "#9fcae6"; ...
    "#d95319" "#de6936" "#e37e53" "#e7946f" "#eca98c" "#f1bfa9"; ...
    "#edb120" "#efbb3c" "#f2c458" "#f4ce74" "#f6d890" "#f8e2ab"; ...
    "#7e2f8e" "#8e499c" "#9e63aa" "#ae7db8" "#bf97c7" "#cfb1d5"; ...
    "#77ac30" "#88b64a" "#99c164" "#aacb7e" "#bbd597" "#cce0b1"; ... 
    "#4dbee0" "#4dbee0" "#7acee8" "#90d6ec" "#bce7f3" "#d3eff7"; ...
    "#a21400" "#ae3120" "#b94f40" "#c56c60" "#d18a80" "#dca79f"];

colors = colors(1:length(bands), :);
colors_f = flip(flip(colors, 1), 2);

%% Correlation bar plots 
% One for each dataset 

fig = figure(); 
fig.Position(3) = fig.Position(3)*100;
fig.Position(4) = fig.Position(4)*100;
t = tiledlayout(length(eeg_fmri_corr), 1, 'TileSpacing','compact');

% Decision legend - corrected 
star = string(size(decision));
star(decision) = '*';
star(~decision) = '';
star = reshape(star, size(decision));

% Decision legend - uncorrected 
star_un = string(size(decision_un));
star_un(decision_un) = '*';
star_un(~decision_un) = '';
star_un = reshape(star_un, size(decision_un));

for d = 1 : length(eeg_fmri_corr)

    % Define data limits 
%     data_max = max(mean(corr_data(:, d, :, :, :, :), 6, 'omitnan'), [], 'all');
%     data_min = min(mean(corr_data(:, d, :, :, :, :), 6, 'omitnan'), [], 'all'); 
%     data_lims = [-round(max(abs(data_min), data_max), 2) ...
%         round(max(abs(data_min), data_max), 2)];
    data_lims = [-0.2 0.2];

    dataset = eeg_fmri_corr(d).dataset;
       
    data_img = squeeze(corr_data(d, :, :, :, :));
    data_img = permute(data_img, [1 3 2 4]);

    % Max. and min. across subjects 
    max_data_img = squeeze(max(permute(data_img, [4 1 2 3]))); 
    min_data_img = squeeze(min(permute(data_img, [4 1 2 3]))); 

    % Mean across subjects
    data_img = squeeze(mean(data_img, 4, 'omitnan')); 

    % Error bar
    err_high = abs(max_data_img - data_img);
    err_low  = abs(min_data_img - data_img);
    err_high = err_high(:, :); err_low = err_low(:, :);
    
    % Signficance legend
    star_img = permute(squeeze(star(d, :, :, :)), [1 3 2]);
    star_img = star_img(:, :);
    star_un_img = permute(squeeze(star_un(d, :, :, :)), [1 3 2]);
    star_un_img = star_un_img(:, :);

    nexttile;
    ba = bar(data_img(:, :), 'grouped');

    % RSN label
    if d == length(eeg_fmri_corr)
        set(gca,'xticklabel', rsns, 'FontSize', 12, ...
            'FontWeight', 'bold'); xtickangle(45)
        xlabel('RSNs', 'FontSize', 16, 'FontWeight', 'bold'); 
    else
        set(gca,'xticklabel', '', 'FontSize', 12, 'FontWeight', 'bold');
    end

    ylabel(erase(dataset, '64Ch'), 'FontSize', 16, ...
        'FontWeight', 'bold');
    ax = gca; ax.YGrid = 'on'; ylim(data_lims); 
    
    cat = ax.Children;
    cte = 1;
    for b = 1 : length(bands)
      for del = 1 : length(delays)
         set(cat(cte), 'FaceColor', colors_f(b, del));
         leg(cte) = strcat(bands(b), ',', " ", delays(del), 's');
         cte = cte + 1;
      end
    end          

    for b = 1 : length(ba)

        star_img_b = star_img(:, b);
        star_un_img_b = star_un_img(:, b);
        err_high_b = err_high(:, b);
        err_low_b = err_low(:, b);

        % Error bar 
%             hold on
%             xerr = ba(b).XEndPoints;
%             yerr = ba(b).YEndPoints; 
%             er = errorbar(xerr, yerr, err_low_b, err_high_b);    
%             er.Color = [0 0 0];                            
%             er.LineStyle = 'none';  

        % Sig. legend
        xtips = ba(b).XEndPoints;
        ytips = ba(b).YEndPoints + 0.01.*sign(ba(b).YEndPoints);
        text(xtips, ytips, star_img_b, ...
            'HorizontalAlignment', ...
            'center', 'FontSize', 8); hold on 
        text(xtips, ytips, star_un_img_b, ...
            'HorizontalAlignment', ...
            'center', 'FontSize', 8, ...
            'Color', 'r'); hold off
    end
    %hold off 

end % dataset
         
l = legend(leg, 'FontSize', 12);
l.Layout.Tile = 'east';
title(t, 'EEG-fMRI Avg. Channel Correlation Across Subjects', ...
    'FontSize', 16);

img_out = strcat('eeg_fmri_corr_', metric, '_barplots.png');
print(gcf, fullfile(path_img_out, img_out), '-dpng', '-r1000');   
close
