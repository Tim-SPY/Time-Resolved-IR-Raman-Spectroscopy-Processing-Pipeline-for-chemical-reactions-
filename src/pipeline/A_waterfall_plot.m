
%what to change 
%Line 14: add the file name and the folder name (dataRaw/dataProcessed)

clc
clear all 
close all 

% --- Resolve project data folders (works regardless of current folder) ---
scriptDir = fileparts(mfilename("fullpath"));
dataRaw = fullfile(scriptDir, "..", "..", "data", "raw");
dataProcessed = fullfile(scriptDir, "..", "..", "data", "processed");

load(fullfile(dataRaw, 'raw_imported_spectra.mat'))

% Get the actual number of rows and columns from D_background
[n, m] = size(D);

% Preallocate matrices for speed and correct dimensions
X = zeros(m, n);
Y = zeros(m, n);
Z = zeros(m, n);

for i = 1:n
    X(:, i) = x';          % Transpose x if needed to match column vector size
    Y(:, i) = i * ones(m, 1); % Sample no column vector
    Z(:, i) = D(i, :)'; % Intensity row transposed to column vector
end

figure;
surf(X, Y, Z, 'EdgeColor', 'none')   
colorbar
xlabel("Wavenumber [cm^{-1}]")
%xlim([1700 2200])
ylabel("Sample no")
zlabel("intensity")
title('3D Spectra For Background')
view(30, 45);
