clear all 
path = 'C:\Users\marta\OneDrive\Documentos\LASEEB\ICD';

% Define 
rsns_in = ["visual" "somatomotor" "dan" "van" "limbic" "fp" "dmn"];
rsns = ["VN" "SMN" "DAN" "VAN" "LN" "FPN" "DMN"];
datasets = "ICD";
runs = "ses-DMT";
fs_pos_type = 'fs_tr';
fs_mid = 4;

for d = 1 : length(datasets)
    
    dataset = config_dataset(datasets(d));
    subjs = dataset.subjs;
    runs = dataset.runs;
    fs_tr = dataset.fs_tr;
    
    if strcmp(fs_pos_type, 'fs_tr'); fs_pos = fs_tr; ...
    elseif strcmp(fs_pos_type, 'fs_mid'); fs_pos = fs_mid; end    
    
    for rsn = 1 : length(rsns)

        for s = 1 : length(subjs)

            for r = 1 : length(runs)

                path_data = fullfile(path, 'DATASETS\derivatives\fmri', ...
                    datasets(d), subjs(s));
                data_in = strcat('ic_', rsns_in(rsn), '_group.txt');
                data_out = strcat('ic_', rsns(rsn), '_group_norm_', ...
                    num2str(round(fs_pos, 1)), 'Hz.txt');
                fmri = readmatrix(fullfile(path_data, data_in));
                
                % Upsample if necessary
                if (fs_pos == fs_mid)
                    n_pnts_bold = length(fmri); 
                    time_pre = 0 : 1/fs_tr : (n_pnts_bold-1)/fs_tr;
                    time = 0 : 1/fs_mid : (n_pnts_bold-1)/fs_tr;
                    fmri = interp1(time_pre, fmri, time);        
                end                

                % Normalize
                fmri = zscore(fmri);                               

                % Save
                writematrix(fmri, fullfile(path_data, data_out));     

            end % runs 

        end % subjects

    end % rsns

end % datasets