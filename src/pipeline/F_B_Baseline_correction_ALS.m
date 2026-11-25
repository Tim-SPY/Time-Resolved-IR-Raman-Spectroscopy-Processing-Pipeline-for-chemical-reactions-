%% F_B_Baseline_correction_ALS.m
% -------------------------------------------------------------------------
% GUIDE
% -------------------------------------------------------------------------
% WHAT THIS DOES
%   Removes any remaining curved/sloped baseline from the background-
%   subtracted reaction-zone spectra using ALS (asymmetric least squares),
%   then smooths each spectrum with a Savitzky-Golay filter.
%
% WHEN TO RUN IT
%   After E_Reaction_back_remove.m, as ONE of three alternative baseline
%   methods (F_A / F_B / F_C). Run only one of the three before continuing
%   to G_PCA_Run_Analysis.m — don't run all three in sequence.
%
% REQUIRES
%   - data/processed/reaction_zone_without_background.mat (produced by
%     E_Reaction_back_remove.m), containing D, x, t
%   - ALS.m on the MATLAB path (src/functions/)
%   - Signal Processing Toolbox (sgolayfilt)
%
% HOW TO RUN
%   Open MATLAB with the repo root as the current folder (or add
%   src/functions to the path), then run this script directly.
%
% KEY PARAMETERS (edit if your baseline is under/over-corrected)
%   lambda   - ALS smoothness penalty; larger = stiffer, smoother baseline
%   p        - ALS asymmetry (0 < p < 1); smaller values make the baseline
%              hug the bottom of the spectrum more aggressively, which
%              suits spectra where peaks point upward
%   sg_frame - Savitzky-Golay window length (must be odd)
%   sg_poly  - Savitzky-Golay polynomial order (must be < sg_frame)
%
% OUTPUT
%   data/processed/ALS_corrected.mat  (variables: D, x, t)
%   A plot of all corrected spectra overlaid.
% -------------------------------------------------------------------------

clc
clear
close all;

% --- Resolve project data folders (works regardless of current folder) ---
scriptDir = fileparts(mfilename("fullpath"));
dataRaw = fullfile(scriptDir, "..", "..", "data", "raw");
dataProcessed = fullfile(scriptDir, "..", "..", "data", "processed");

load(fullfile(dataProcessed, "reaction_zone_without_background.mat")) % load the reaction zone file "without noise"

raw_spectra = D;      %  Important note that ALS function needs column wise spectra

% define parameter for ALS
lambda = 1000;
p = 0.01;
sg_frame = 15;
sg_poly = 6;
[m, n] = size(raw_spectra);
clean_spectra = zeros(m, n);

for i = 1:length(t) % for looping over the column length
    y_raw = raw_spectra(i, :);
    %corrections
    baseline_correct = ALS(y_raw,lambda ,p);
    baseline_correct = baseline_correct';
    y_clean = sgolayfilt(baseline_correct, sg_poly, sg_frame);

    %save
    clean_spectra(i,: ) = y_clean;
    fprintf("\n File Processed %d",i)
end

D = clean_spectra;

plot(x,D);
xlabel("Wavenumber [cm^{-1}]")
xlim([1750 2200])
ylabel("IR absorption intensity")
title('Reaction spectra with ALS and SG Filter')
grid on;

save(fullfile(dataProcessed, "ALS_corrected.mat"),"D","x","t")