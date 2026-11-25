%use this file to remove background noise/spectra from reaction timeline

clc 
clear
close all 

% --- Resolve project data folders (works regardless of current folder) ---
scriptDir = fileparts(mfilename("fullpath"));
dataRaw = fullfile(scriptDir, "..", "..", "data", "raw");
dataProcessed = fullfile(scriptDir, "..", "..", "data", "processed");

load(fullfile(dataProcessed, 'Background__avg.mat'))
average_background = D;

load(fullfile(dataProcessed, 'reaction_zone_with_background.mat'))

D = D - average_background;


plot(x,D)
xlabel("Wavenumber [cm^{-1}]")
% xlim([1900 2150])
ylabel("IR absorption intensity")
title('2D Reaction zone background Subtracted Data Plot')
grid on;

save(fullfile(dataProcessed, 'reaction_zone_without_background.mat'),"D","t","x")

