%% I_Save_MCR_ALS.m
% -------------------------------------------------------------------------
% GUIDE
% -------------------------------------------------------------------------
% WHAT THIS DOES
%   Saves the MCR-ALS results (resolved concentration profiles and pure
%   spectra) to a .mat file, then plots them: concentration profiles over
%   time, and pure spectra with automatic peak labeling.
%
% WHEN TO RUN IT
%   Immediately after H_Run_MCR.m, in the SAME MATLAB session — this script
%   does not load copt/sopt from a file, it expects them to already be in
%   the workspace from the MCR-ALS toolbox run (mcr_main typically names
%   its outputs copt = concentrations, sopt = spectra).
%
% REQUIRES
%   - Variables copt and sopt in the workspace (from H_Run_MCR.m)
%   - Variables t and x in the workspace (loaded earlier in the pipeline)
%
% HOW TO RUN
%   Run H_Run_MCR.m first, let the toolbox finish and produce copt/sopt,
%   then run this script.
%
% PARAMETERS
%   min_prominence - peak-detection sensitivity for the spectra plot.
%                    Lower = more peaks found; raise this if the plot looks
%                    too cluttered/noisy.
%
% OUTPUT
%   data/processed/MCR_Final_Results.mat  (variables: copt, sopt, t, x)
%   A figure with resolved concentration profiles (top) and resolved pure
%   spectra with labeled peaks (bottom). Handles any number of resolved
%   species, not just 3.
% -------------------------------------------------------------------------

% --- 0. Sanity check: make sure MCR-ALS has actually been run ---
if ~exist('copt', 'var') || ~exist('sopt', 'var')
    error(['copt and/or sopt not found in the workspace. Run H_Run_MCR.m ' ...
           'first and let it finish before running this script.']);
end

% --- 1. Save the results to a .mat file ---
scriptDir = fileparts(mfilename("fullpath"));
dataProcessed = fullfile(scriptDir, "..", "..", "data", "processed");
save(fullfile(dataProcessed, 'MCR_Final_Results.mat'), 'copt', 'sopt', 't', 'x');
disp('Results saved to data/processed/MCR_Final_Results.mat');

% --- 2. Define variables ---
conc = copt;
spectra = sopt;
n_species = size(spectra, 1); %