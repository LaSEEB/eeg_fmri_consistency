function [features_delayed] = convolve_features_fast_expanded_v2(features, fs, ...
    delay_range, kern_seconds)
% 
%   function [feature_delay] = convolve_features_fast(feature, fs, 
%   delay_range, kern_seconds) convolves each feature in variable 
%   'feature' with a set of HRF functions, characterized by a set of
%   overshoot delays specified in 'delay_range'. Fast version. 
%
%   INPUTS:
%
%   feature         the features to be convolved  
%   fs              the sampling frequency of the features
%   delay_range     the vector specifying the delays (sec)
%   kern_seconds    the size of the hrf kernel to be used for 
%                    convolution (sec)
%
%   OUTPUTS:
%
%   feature_delay   the features after being convolved
%                   (time x chans x bands x delays)
%
% Expanded for 'negative' and 'zero' overshoot delays 
% 
% ------------------------------------------------------------
% Read input information
% ------------------------------------------------------------     

% Read size of input data
siz = size(features);
n_pnts = size(features, 1);
n_features = numel(features(1, :, :));
n_delays = length(delay_range);

% Compute the length of the convolution 
n_pnts_kern = floor(kern_seconds*fs) + 1;
n_conv = n_pnts + n_pnts_kern - 1;

% ------------------------------------------------------------
% Preallocate matrices 
% ------------------------------------------------------------     

% Reshape the features matrix to have only 2 dimensions 
features = reshape(features, [n_pnts n_features]);

features_delayed = zeros(n_pnts, siz(2), n_delays);

% ------------------------------------------------------------
% Convolve matrices with hrf kernel
% ------------------------------------------------------------     

n = 1;

% Go through overshoot delays 
for d = 1 : length(delay_range)

    overshoot_delay = abs(delay_range(d));
    if delay_range(d) == 0
        overshoot_delay = 1;
    end

    % Assign parameters of the response function.
    % for overshoot delay (p1) = 6, undershoot delay (p2) = 16,
    % dispersion of response (p3) = 1, dispersion of undershoot (p4) = 1,
    % ratio of response to undershoot (p5) = 6, onset (p6) = 0, 
    % length of kernel (p7) = 32 (default)
    % maintain a linear relation between the parameters’ values
    % of the five variants HRFs and the canonical HR
    s = overshoot_delay/6; % scale factor 
    p = [overshoot_delay 16*s 1*s 1*s 6 0 kern_seconds];
    
    % Assign scan repetition time
    % this should result in a function 
    % with the same temporal resolution 
    % as the original dataset (0.004 s)
    rt = 1/fs;

    % Build hrf function for current overshoot delay 
    % each column corresponds to hrf with a given overshoot delay
    hrf = spm_hrf(rt, p);

    % Normalize overshoot 
    hrf = hrf ./ max(hrf);

    n = n + 1;

    % Compute FFT along each column 
    hrfF = fft(hrf, n_conv);

    featuresF = fft(features, n_conv);
    hrfF = repmat(hrfF, 1, n_features);
    
    % Perform time-domain convolution by frequency domain multiplication 
    features_delayed_d = ifft(featuresF .* hrfF, n_conv) ./ n_conv;    

    % Shift the signal if overshoot delay is negative
    if delay_range(d) < 0
        features_delayed_d = delayseq(features_delayed_d,...
           - 2*overshoot_delay, fs);
    elseif delay_range(d) == 0
        features_delayed_d = delayseq(features_delayed_d,...
           - overshoot_delay, fs);
    end

    % NOTE: should we use the central part of the convolution (matlab default)
    %       or should we use the first part of the convolution (spm_volterra)
    features_delayed(:, :, d) = features_delayed_d(1 : n_pnts, :);

end

% ------------------------------------------------------------
% Plot the HRFs   
% ------------------------------------------------------------     

% % Assign time vector with fs 250 Hz 
% time_hrf = 0 : 1/fs : kern_seconds;
% 
% %Plot hrfs 
% figure('Name','Hemodynamic Response Functions (HRFs)')
% 
% for d = 1 : length(delay_range)
%     plot(time_hrf, hrf(:,d)); hold on 
% end
% 
% title('Hemodynamic Response Functions (HRFs)','FontSize',16);
% xlabel('Time (s)','FontSize',16); ylabel('Amplitude','FontSize',16);
% legend("10 seconds", "8 seconds", "6 seconds",...
%     "5 seconds", "4 seconds", "2 seconds",'FontSize',14)
% grid on 


end
