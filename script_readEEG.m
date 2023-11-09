% Script to read EEG from all subjects and concatenate all trials to obtain a continuous
% signal and save in the subject folder

folder='C:\Users\marta\OneDrive\Documentos\LASEEB\ICL\DATA\data\eeg';

addpath(genpath(folder))

folder_subs=dir([folder '\sub*']);

for sub=1:length(folder_subs)
load([folder '\' folder_subs(sub).name '/ses-DMT/data_clean.mat'])
load([folder '\' folder_subs(sub).name '/ses-DMT/dataref.mat'])

dt=1/250;
[N_electrodes, N_time_points]=size(data_clean.trial{1,1});
n_trials=size(data_clean.trial,2);

disp(['Total time of EEG signals is ' num2str(n_trials*N_time_points*dt) 'seconds']) 

EEG_continuous=zeros(N_electrodes,n_trials*N_time_points);

for trial=1:n_trials
    
    EEG_continuous(:,(trial-1)*N_time_points+1:trial*N_time_points)=data_clean.trial{1,trial};
end

% normalize the signals in all electrodes for plot
% Plot one trial
figure 
plot(0:dt:dt*(n_trials*N_time_points-1),(1:N_electrodes)'.*ones([N_electrodes, n_trials*N_time_points])+EEG_continuous./(6*std(EEG_continuous,[],2)))
ylim([-1 N_electrodes+2])


% Same with reference electrode
% [N_electrodes, N_time_points]=size(dataref.trial{1,1});
% n_trials=size(dataref.trial,2);
% EEG_continuous_ref=zeros(N_electrodes,n_trials*N_time_points);
% 
% for trial=1:n_trials
%     
%     EEG_continuous_ref(:,(trial-1)*N_time_points+1:trial*N_time_points)=dataref.trial{1,trial};
% end
% 
% % normalize the signals in all electrodes for plot
% % Plot one trial
% figure 
% plot(0:dt:dt*(n_trials*N_time_points-1),(1:N_electrodes)'.*ones([N_electrodes, n_trials*N_time_points])+EEG_continuous_ref./(6*std(EEG_continuous_ref,[],2)))
% ylim([-1 N_electrodes+2])

save([folder '\' folder_subs(sub).name '/ses-DMT/ContinuousEEG.mat'],'EEG_continuous')
end