%% F_C_Baseline_Linear.m
% -------------------------------------------------------------------------
% GUIDE
% -------------------------------------------------------------------------
% WHAT THIS DOES
%   Removes a simple straight-line baseline from each spectrum, anchored at
%   two chosen wavenumbers (assumed to be baseline/non-absorbing regions),
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
%   - Signal Processing Toolbox (sgolayfilt)
%
% HOW TO RUN
%   Open MATLAB with the repo root as the current folder, then run this
%   script directly. Check the second figure ("Selected Baseline Points")
%   to confirm start_x/end_x actually sit on flat, non-absorbing parts of
%   your spectrum — if they land on a peak, the baseline will be wrong.
%
% KEY PARAMETERS (edit to match your spectra)
%   start_x, end_x - wavenumbers used as the two baseline anchor points
%   sg_frame       - Savitzky-Golay window length (must be odd)
%   sg_poly        - Savitzky-Golay polynomial order (must be < sg_frame)
%
% OUTPUT
%   data/processed/TwoPoint_corrected.mat  (variables: D, x, t)
%   Two figures: all corrected spectra overlaid, and a check plot showing
%   where the two baseline anchor points fall on the last raw spectrum.
% -------------------------------------------------------------------------

clc
clear
close all;

% --- Resolve project data folders (works regardless of current folder) ---
scriptDir = fileparts(mfilename("fullpath"));
dataRaw = fullfile(scriptDir, "..", "..", "data", "raw");
dataProcessed = fullfile(scriptDir, "..", "..", "data", "processed");

load(fullfile(dataProcessed, "reaction_zone_without_background.mat"));

raw_spectra = D;

% --- TWO-POINT BASELINE SETTINGS ---
start_x = 1900;
end_x   = 2125;

% Savitzky-Golay filter parameters
sg_frame = 15;
sg_poly  = 6;

[m, n] = size(raw_spectra);
clean_spectra = zeros(m, n);

% Find indices closest to the selected wavenumbers
[~, start_idx] = min(abs(x - start_x));
[~, end_idx]   = min(abs(x - end_x));

% Actual wavenumber positions
baseline_x = x([start_idx, end_idx]);

for i = 1:m

    % Extract one spectrum
    y_raw = raw_spectra(i, :);

    % 1. Calculate straight-line baseline using two points
    baseline_y = y_raw([start_idx, end_idx]);

    baseline = interp1( ...
        baseline_x, baseline_y, x, 'linear', 'extrap');

    % 2. Subtract baseline
    baseline_correct = y_raw - baseline;

    % 3. Apply Savitzky-Golay filter
    y_clean = sgolayfilt( ...
        baseline_correct, sg_poly, sg_frame);

    % 4. Store corrected spectrum as one row
    clean_spectra(i, :) = y_clean;

    if mod(i, 50) == 0
        fprintf("File Processed %d / %d\n", i, m);
    end
end

% Store corrected spectra
D = clean_spectra;

% --- PLOT ALL CORRECTED SPECTRA ---
figure;
plot(x, D, 'LineWidth', 0.5);
xlabel("Wavenumber [cm^{-1}]");
% xlim([1900 2150]);
ylabel("IR absorption intensity");
title("Reaction Spectra with Two-Point Baseline Correction and SG Filter");
grid on;

% --- VERIFY BASELINE POINTS ---
figure;
plot(x, raw_spectra(end, :), 'b');
hold on;
plot(x([start_idx, end_idx]), ...
     raw_spectra(end, [start_idx, end_idx]), ...
     'rv', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

% xlim([1900 2150]);
xlabel("Wavenumber [cm^{-1}]");
ylabel("IR absorption intensity");
title("Selected Baseline Points");
legend("Raw Spectrum", "Baseline Points");
grid on;

% Save corrected data
save(fullfile(dataProcessed, "TwoPoint_corrected.mat"), "D", "x", "t");