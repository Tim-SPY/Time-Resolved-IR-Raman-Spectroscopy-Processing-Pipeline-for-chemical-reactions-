%% H_Run_MCR.m
% -------------------------------------------------------------------------
% GUIDE
% -------------------------------------------------------------------------
% WHAT THIS DOES
%   Loads the baseline-corrected spectra and runs MCR-ALS (via the external
%   mcr_toolbox2_updated_070721 toolbox) to resolve pure component spectra
%   and their concentration profiles from the mixed reaction spectra.
%
% WHEN TO RUN IT
%   After whichever baseline-correction step you used (F_A, F_B, or F_C).
%   As written, it loads TwoPoint_corrected.mat — change the filename below
%   if you used airPLS_corrected.mat or ALS_corrected.mat instead.
%
% REQUIRES
%   - data/processed/TwoPoint_corrected.mat (or your chosen baseline
%     output), containing D, x, t
%   - The MCR-ALS toolbox's "ALS routines" folder, placed in the repo at:
%       mcr_toolbox2_updated_070721 (2)/ALS routines/
%     (sitting next to src/, data/, docs/ at the repo root)
%
% HOW TO RUN
%   Open MATLAB with the repo root as the current folder, then run this
%   script directly. The MCR toolbox's own GUI/prompts (from mcr_main)
%   will take over once it launches — follow its on-screen instructions.
%
% PORTABILITY NOTE
%   The toolbox path below is resolved relative to this script's location,
%   so it works regardless of your current MATLAB folder. If you move the
%   toolbox (e.g. into external/, which is gitignored and the usual place
%   for third-party code you don't want tracked in git), update
%   toolboxRelativePath below to match. You can also override it entirely
%   at runtime by setting the environment variable MCR_TOOLBOX_PATH before
%   starting MATLAB.
%
% OUTPUT
%   Leaves copt (concentration profiles) and sopt (pure spectra) in the
%   workspace for I_Save_MCR_ALS.m to save and plot.
% -------------------------------------------------------------------------

clc
clear all
close all

% --- Resolve project data folders (works regardless of current folder) ---
scriptDir = fileparts(mfilename("fullpath"));
dataRaw = fullfile(scriptDir, "..", "..", "data", "raw");
dataProcessed = fullfile(scriptDir, "..", "..", "data", "processed");

originalPath = pwd;

% 1. Load the baseline-corrected spectra
load(fullfile(dataProcessed, "TwoPoint_corrected.mat"));

% 2. Point to your local copy of the MCR-ALS toolbox.
%    Default: repo_root/mcr_toolbox2_updated_070721 (2)/ALS routines
%    Override by setting the MCR_TOOLBOX_PATH environment variable instead.
mcrToolboxPath = getenv('MCR_TOOLBOX_PATH');
if isempty(mcrToolboxPath)
    repoRoot = fullfile(scriptDir, '..', '..');
    toolboxRelativePath = fullfile('mcr_toolbox2_updated_070721 (2)', 'ALS routines');
    mcrToolboxPath = fullfile(repoRoot, toolboxRelativePath);
end

if ~isfolder(mcrToolboxPath)
    error(['MCR-ALS toolbox not found at: %s\n' ...
           'Either place the toolbox there, or set the environment variable ' ...
           'MCR_TOOLBOX_PATH to its correct location before starting MATLAB.'], mcrToolboxPath);
end
addpath(mcrToolboxPath);

% 3. Run the toolbox
run('mcr_main');

% 4. Return to the original path automatically
cd(originalPath);