%change the plot data as per your preference 
clc
clear 
close all 

% --- Resolve project data folders (works regardless of current folder) ---
scriptDir = fileparts(mfilename("fullpath"));
dataRaw = fullfile(scriptDir, "..", "..", "data", "raw");
dataProcessed = fullfile(scriptDir, "..", "..", "data", "processed");

load(fullfile(dataProcessed, 'background_data.mat'))

average_background = mean(D);
D=average_background;
plot(x,average_background)
save(fullfile(dataProcessed, 'Background__avg.mat'),"D","t","x")

xlabel("Wavenumber [cm^{-1}]")
ylabel("IR absorption intensity")
xlim([1900 2150])
title('2D Background Spectrum Data Plot Averaged')
grid on;

