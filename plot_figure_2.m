% Create a figure with the topographies of the avg. (subjs.) correlations
% Figure 2 - Part 1 (Topoplots)

clear all 

%% Data specification 

path = 'C:\Users\marta\OneDrive\Documentos\LASEEB\ICD';
path_out = fullfile(path, 'DATASETS\consist'); 

% Define  
metric = 'tf_power'; 

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

%% Load data and settings

% Correlation data
load(fullfile(path, 'DATASETS\consist\', metric, '\eeg_fmri_corr.mat'));

plot_delay = 4; % 6s 
sig_thr = 0.05;
cmap = colormap('parula');
consist_font_lims = [10 14];

sig_thr_corr = 'none'; % 'bon', 'fdr', 'none' 

%% Topographies - Corr., Scalp 

topo_settings = {'whitebk', 'on', 'gridscale', 100, 'conv', 'on', ...
    'colormap', cmap};

% One for all datasets 
data_lims = zeros(1, 2);
for d = 1 : length(eeg_fmri_corr)
    data = squeeze(mean(eeg_fmri_corr(d).pcorr_scalp(:, :, :, :, plot_delay), 2));
    max_min_data = max(quantile(data(:), 0.99), abs(quantile(data(:), 0.01)));
    max_min_data = max(max_min_data, data_lims(2));
    data_lims = [-max_min_data max_min_data];
end
data_lims = repmat(data_lims, length(eeg_fmri_corr), 1);

% One for each dataset
% data_lims = zeros(length(datasets), 2);
% for d = 1 : length(eeg_fmri_corr)
%     data = squeeze(mean(eeg_fmri_corr(d).pcorr_scalp(:, :, :, :, 4), 2));
%     max_min_data = max(quantile(data(:), 0.99), abs(quantile(data(:), 0.01)));
%     data_lims(d, :) = [-max_min_data max_min_data];
% end

for r = 1 : length(rsns)

    % Figure settings
    fig = figure(); 
    fig.Position(4) = fig.Position(4)*1000;
    fig.Position(3) = fig.Position(3)*80;
    t = tiledlayout(length(eeg_fmri_corr), length(bands) + 1, 'TileSpacing', 'compact');   

    %ct = length(bands) + 2; % start in the second row of the grid 
    %ct = 1;

    for d = 1 : length(eeg_fmri_corr)

        dataset = eeg_fmri_corr(d).dataset;
        for b = 1 : length(bands)

            %subplot(length(eeg_fmri_corr)+1, length(bands)+1, ct);
            %subplot(length(eeg_fmri_corr), length(bands), ct);
            nexttile

            % Data to plot 
            chanlocs = eeg_fmri_corr(d).chanlocs;
            data = squeeze(mean(eeg_fmri_corr(d).pcorr_scalp(r, :,...
                b, :, plot_delay), 2)); 

            % Plot
            topoplot(data, chanlocs, topo_settings{:}); 
            clim(data_lims(d, :)); 
            
            % Band title
            if d == 1
                title(bands(b), 'FontWeight', 'bold', ...
                    'FontSize', 14, 'Position', [0, 0.96, 1]);
            end

            axis on        
            h(1) = xlabel(" ");

            % Dataset subtitle (y axis)
            if b == 1
                h(2) = ylabel(dataset, 'FontSize', 14, ...
                    'Fontweight', 'bold');
                set(gca, 'Xcolor', 'none', 'Ycolor', 'w', 'Color', 'none', ...
                    'XTick', [], 'YTick', [], 'XAxisLocation', 'top');
                set(h, 'Color', 'k');      
            else
                h(2) = ylabel(" ");
                set(gca, 'Xcolor', 'none', 'Ycolor', 'none', 'Color', 'none', ...
                    'XTick', [], 'YTick', [], 'XAxisLocation', 'top');
                set(h, 'Color', 'k');   
            end

            %ct = ct + 1;

        end % bands

        %ct = ct + 1; % skip last column of the grid
        c = colorbar;
        nexttile;
        set(gca, 'Xcolor', 'none', 'Ycolor', 'none', 'Color', 'none', ...
            'XTick', [], 'YTick', [], 'XAxisLocation', 'top');   
        colormap(c, cmap); clim(data_lims(d, :));

    end % datasets 

    h = axes(fig, 'visible', 'off'); 
    h.Title.Visible = 'off';
    h.XLabel.Visible = 'off';
    h.YLabel.Visible = 'on';
%     ylabel(h, 'Scalp', 'FontWeight', 'bold', 'FontSize', 16, ...
%         'Position', [-0.06, ...
%         0.5*length(eeg_fmri_corr)/(length(eeg_fmri_corr) + 1) 0]);
    title(h, strcat('EEG-fMRI', " ", rsns(r), ' Correlation'), ...
        'FontWeight', 'bold', 'FontSize', 18);

     %c = colorbar(h, 'Position', [0.82 0.13 0.02 0.78]);  
     %ylabel(c, 'Corr.', 'FontSize', 16, 'Rotation', 270, ...
     %    'Position', [3.1 0 0]);
     %colormap(c, cmap); 
     %clim(h, data_lims(1, :));          

    img_out = strcat('eeg-fmri_corr_', ...
        metric, '_', string(rsns(r)), '_scalp_', ...
        num2str(delays(plot_delay)), 's_topo');  
    print(gcf, fullfile(path_img_out, img_out), '-dpng', '-r500'); 

end % rsns