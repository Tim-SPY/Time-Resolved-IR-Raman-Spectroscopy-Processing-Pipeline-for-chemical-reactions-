%this file is use to isolate background data 
%what to change 
%Line 21: add the file name and the folder name (dataRaw/dataProcessed)
%line 27 ; select specific wavelength 
%line 33 ; select time scale corrosponding to your raw data
%change the plot data
clc
clear all 
close all 

% --- Resolve project data folders (works regardless of current folder) ---
scriptDir = fileparts(mfilename("fullpath"));
dataRaw = fullfile(scriptDir, "..", "..", "data", "raw");
dataProcessed = fullfile(scriptDir, "..", "..", "data", "processed");
%change 
%trim by spectra
%trim by time frame to use this file
%plot title

%load the untrimmed file
load(fullfile(dataRaw, 'raw_imported_spectra.mat'))


% Trim by spectra.

valid_columns = (x >= 1750) & (x <= 2200);
size(valid_columns)
D_trimmed = D(:, valid_columns); % 
x_trimmed = x(valid_columns); 

%Trim by time frame

valid_rows = 84:164;
D_trimmed = D_trimmed(valid_rows,:);
t = t(valid_rows,:);

D = D_trimmed;
x = x_trimmed;

save(fullfile(dataProcessed, 'background_data.mat'),"D","x","t")

plot(x,D)

xlabel("Wavenumber [cm^{-1}]")
ylabel("IR absorption intensity")
xlim([1900 2150])
title('Background spectra')
grid on;

