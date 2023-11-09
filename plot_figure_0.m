% Plot EEG-fMRI Correlations
% One plot per dataset, per space 
% Each plot (imagesc) is # subjects x # channels
% 1 figure per dataset, space 
% Each figure is # EEG metrics x RSNs 
% Figure 0 (just for us)

clear all 
path = 'C:\Users\marta\OneDrive\Documentos\LASEEB\ICD';
path_out = fullfile(path, 'DATASETS\consist\sanity'); 

% Define  
metric = 'tf_power'; 

% Datasets, RSNs, Bands, HRF delays
datasets = ["ICD", "ICD-PCB", "ICD-DMT"];
rsns = ["VN" "SMN" "DAN" "VAN" "LN" "FPN" "DMN"];
bands = ["Delta", "Theta", "Alpha", "Beta", "Gamma"];
delays = ["2", "4", "5", "6", "8", "10"];

fs_mid = 4; % 4 Hz 

% Update and create output directories 
path_img_out = path_out;

if ~exist(path_out, 'dir'); mkdir(path_out); end
if ~exist(path_img_out, 'dir'); mkdir(path_img_out); end

% Load data 
load(fullfile(path, 'DATASETS\consist\', metric, '\eeg_fmri_corr.mat'));


%% Plots
for d = 1 : length(datasets)

    dataset = config_dataset(datasets(d));
    subjs = dataset.subjs;

    fig = figure();
    fig.Position(3) = fig.Position(3)*100;
    fig.Position(4) = fig.Position(4)*100;
    t = tiledlayout(length(subjs), length(rsns), 'TileSpacing','compact');  

    data_img = eeg_fmri_corr(d).pcorr_scalp;

    for s = 1 : length(subjs)

        for r = 1 : length(rsns)

            nexttile;

            data_img_current = squeeze(data_img(r, s, :, :, :)); 
            data_img_current = permute(data_img_current, [2 1 3]);
            im = imagesc(data_img_current(:, :));
            colormap(parula);
            clim([-0.3 0.3]);      
            xticklabels(" ");
            yticklabels(" ");

            % RSN title
            if s == 1
                title(rsns(r));
            end

            % Subject title
            if r == 1
                ylabel(subjs(s));
            end

        end % rsns

    end % subjects 

    c = colorbar;
    c.Layout.Tile = 'east';
    ylabel(c, 'Corr.', 'FontSize', 12, 'Rotation', 270);
    title(t, strcat('EEG-fMRI Correlation -', " ", datasets(d)));  
    ylabel(t, 'Channels'); xlabel(t, 'Bands x HRF delays');

    img_out = strcat('eeg_fmri_corr_', metric, '_', datasets(d), ...
        '.png');
    print(gcf, fullfile(path_img_out, img_out), '-dpng', '-r1000');          
  
end % datasets 
