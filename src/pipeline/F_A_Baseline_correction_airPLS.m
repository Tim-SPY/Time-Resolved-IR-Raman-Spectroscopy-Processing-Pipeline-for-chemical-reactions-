%% F_A_Baseline_correction_airPLS.m
% -------------------------------------------------------------------------
% GUIDE
% -------------------------------------------------------------------------
% WHAT THIS DOES
%   Removes any remaining curved/sloped baseline from the background-
%   subtracted reaction-zone spectra using airPLS (adaptive iteratively
%   reweighted penalized least squares), then smooths each spectrum with a
%   Savitzky-Golay filter.
%
% WHEN TO RUN IT
%   After E_Reaction_back_remove.m, as ONE of three alternative baseline
%   methods (F_A / F_B / F_C). Run only one of the three before continuing
%   to G_PCA_Run_Analysis.m — don't run all three in sequence.
%
% REQUIRES
%   - data/processed/reaction_zone_without_background.mat (produced by
%     E_Reaction_back_remove.m), containing D, x, t
%   - airPLS.m on the MATLAB path (src/functions/)
%   - Signal Processing Toolbox (sgolayfilt)
%
% KEY PARAMETERS (edit if your baseline is under/over-corrected)
%   lambda   - airPLS smoothness penalty; larger = stiffer, smoother
%              baseline (less likely to follow real peaks). Try 1e3-1e6.
%   sg_frame - Savitzky-Golay window length (must be odd)
%   sg_poly  - Savitzky-Golay polynomial order (must be < sg_frame)
%
% OUTPUT
%   data/processed/airPLS_corrected.mat  (variables: D, x, t)
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

raw_spectra = D;                        % rows = samples

%define the parameter for SG filter and Lambda for AirPLS
lambda   = 100000;
sg_frame = 11;
sg_poly  = 3;

clean_spectra = zeros(size(raw_spectra));

for i = 1:length(t)
    y_raw = raw_spectra(i, :)';
    y_corr = airPLS(y_raw, lambda);
    y_sm   = sgolayfilt(y_corr, sg_poly, sg_frame);
    clean_spectra(i, :) = y_sm';                  % store as row
    fprintf("Spectrum %d / %d processed\n", i, length(t));
end

D = clean_spectra;

plot(x,D);
xlabel("Wavenumber [cm^{-1}]")
xlim([750 2200])
ylabel("IR absorption intensity")
title('Reaction spectra with airPLS and SG Filter')
grid on;

save(fullfile(dataProcessed, "airPLS_corrected.mat"),"D","x","t")