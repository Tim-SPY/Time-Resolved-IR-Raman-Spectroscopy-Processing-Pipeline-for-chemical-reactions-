%% G_PCA_Run_Analysis.m
% -------------------------------------------------------------------------
% GUIDE
% -------------------------------------------------------------------------
% WHAT THIS DOES
%   Runs Principal Component Analysis (PCA) on the baseline-corrected
%   reaction spectra to summarize how the spectra change over time: the
%   "loadings" (coeff) are spectral shapes, and the "scores" are how much
%   each loading contributes at each time point (i.e. kinetic profiles).
%
% WHEN TO RUN IT
%   After whichever baseline-correction step you used (F_A, F_B, or F_C).
%   As written, it loads TwoPoint_corrected.mat (the F_C output) — change
%   the filename below if you used airPLS_corrected.mat or
%   ALS_corrected.mat instead.
%
% REQUIRES
%   - data/processed/TwoPoint_corrected.mat (or your chosen baseline
%     output), containing D, x, t
%   - Statistics and Machine Learning Toolbox (pca)
%
% HOW TO RUN
%   Open MATLAB with the repo root as the current folder, then run this
%   script directly.
%
% WHAT TO LOOK AT IN THE OUTPUT
%   - num_components_95: how many PCs are needed to explain 95% of the
%     variance in the data (printed to the command window)
%   - Scree plot (top-left): variance explained per component and
%     cumulative, with a 95% reference line
%   - PC loadings (top-right): the spectral shape of PC1 and PC2 — compare
%     these against known species spectra to interpret them chemically
%   - PC scores (bottom-right): how PC1 and PC2 evolve over time — this is
%     effectively a rough kinetic trace before running full MCR-ALS
%
% NOTE
%   Only PC1/PC2 are plotted by default (PC3/PC4 lines are commented out).
%   Uncomment them in the "Plot 2" and "Plot 4" sections if you want to
%   inspect higher components.
% -------------------------------------------------------------------------

clc
clear all
close all

% --- Resolve project data folders (works regardless of current folder) ---
scriptDir = fileparts(mfilename("fullpath"));
dataRaw = fullfile(scriptDir, "..", "..", "data", "raw");
dataProcessed = fullfile(scriptDir, "..", "..", "data", "processed");

load(fullfile(dataProcessed, 'TwoPoint_corrected.mat'))
% =========================================================================
% PCA ANALYSIS FOR TIME-RESOLVED IR SPECTRA (Customized for D, t, x)
% =========================================================================
% Variable mapping based on your .mat file:
%   D = Data matrix (441 time points x 145 wavenumbers)
%   t = Time vector (441 x 1)
%   x = Wavenumber vector (1 x 145)

% 1. Run PCA
% The pca() function automatically mean-centers the data (subtracts the column mean).
[coeff, score, latent, tsquared, explained] = pca(D);

% Note: 
%   coeff -> Loadings (145 x 145). These are the "Pure Component Spectra".
%   score -> Scores (441 x 145). These are the "Time Profiles".
%   explained -> Percentage of variance explained by each component.

% 2. Determine number of components to keep
% Let's find how many components explain 95% of the variance
num_components_95 = find(cumsum(explained) > 95, 1);
fprintf('Number of components to explain 95%% of variance: %d\n', num_components_95);

% --- Plot 1: Scree Plot (Variance Explained) ---
subplot(2,2,1);

num_PC_plot = 3;  % Change to 10, 20, 30, 50, etc.

bar(1:num_PC_plot, explained(1:num_PC_plot));
hold on;

plot(1:num_PC_plot, cumsum(explained(1:num_PC_plot)), ...
    '-ro', 'LineWidth', 1.5, 'MarkerSize', 4);

yline(95, 'k--', '95% Threshold');

xlabel('Principal Component');
ylabel('Variance Explained (%)');
title('Scree Plot');
legend('Individual Variance', 'Cumulative Variance', ...
    'Location', 'best');

xlim([1 num_PC_plot]);
xticks(1:2:num_PC_plot);
grid on;

% --- Plot 2: PC 1 to PC 4 Loadings on the same graph ---
subplot(2,2,2); % Or change to figure if they want a separate full window
hold on; % Enable multiple plots on same axes
plot(x, coeff(:,1), 'LineWidth', 1.5, 'DisplayName', 'PC 1');
plot(x, coeff(:,2), 'LineWidth', 1.5, 'DisplayName', 'PC 2');
% plot(x, coeff(:,3), 'LineWidth', 1.5, 'DisplayName', 'PC 3');
%plot(x, coeff(:,4), 'LineWidth', 1.5, 'DisplayName', 'PC 4');

hold off;
xlabel('Wavenumber (cm^{-1})');
ylabel('Loading Intensity');
title('PC Loadings');
legend('Location', 'best');
grid on;
% --- Plot 4: PC Scores (Kinetics over time) ---
subplot(2,2,4);
hold on;

% Plot all PC scores
plot(t, score(:,1), 'b', 'LineWidth', 1.5, 'DisplayName', 'PC 1');
plot(t, score(:,2), 'r', 'LineWidth', 1.5, 'DisplayName', 'PC 2');
%plot(t, score(:,3), 'g', 'LineWidth', 1.5, 'DisplayName', 'PC 3');
%plot(t, score(:,4), 'm', 'LineWidth', 1.5, 'DisplayName', 'PC 4');

hold off;
xlabel('Time');
ylabel('Score (Intensity)');
title('Scores');
legend('Location', 'best');
grid on;