function [dataset] = config_dataset(dataset_name)

% Upload chanlocs and labels
switch char(dataset_name)
    case 'ICD'
        dataset.subjs = {'sub-02', 'sub-03', 'sub-06', ...
            'sub-07', 'sub-10', 'sub-11', 'sub-12', 'sub-13', ...
            'sub-15', 'sub-17', 'sub-18', 'sub-19', 'sub-23', ...
            'sub-25'}; 
        dataset.runs = "ses-DMT";
        dataset.n_chans = 31;
        dataset.fs_tr = 1/2;
        dataset.fs_pre = 250;
        dataset.scrub = [0 0];
        dataset.n_vols = 840;
    case 'ICD-DMT'
        dataset.subjs = {'sub-02', 'sub-03', 'sub-06', ...
            'sub-07', 'sub-10', 'sub-11', 'sub-12', 'sub-13', ...
            'sub-15', 'sub-17', 'sub-18', 'sub-19', 'sub-23', ...
            'sub-25'}; 
        dataset.runs = "ses-DMT";
        dataset.n_chans = 31;
        dataset.fs_tr = 1/2; 
        dataset.fs_pre = 250;
        dataset.scrub = [0 0];
        dataset.n_vols = 840;
    case 'ICD-PCB'
        dataset.subjs = {'sub-02', 'sub-03', 'sub-06', ...
            'sub-07', 'sub-10', 'sub-11', 'sub-12', 'sub-13', ...
            'sub-15', 'sub-17', 'sub-18', 'sub-19', 'sub-23', ...
            'sub-25'}; 
        dataset.runs = "ses-DMT";
        dataset.n_chans = 31;
        dataset.fs_tr = 1/2;
        dataset.fs_pre = 250;
        dataset.scrub = [0 0];
        dataset.n_vols = 840;     
end % switch dataset

chanlocs = load(char(fullfile('DATASETS/labels', ...
    strcat('chanlocs_scalp_', dataset_name, '.mat'))), 'chanlocs');
dataset.chanlocs = chanlocs.chanlocs;