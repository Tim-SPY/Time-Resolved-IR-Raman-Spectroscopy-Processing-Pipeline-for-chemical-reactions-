function [corrected_y, linear_baseline] = linear_baseline_correction(x, y, knot1_x, knot2_x)
% LINEAR_BASELINE_CORRECTION Applies a simple linear baseline correction to a spectrum.
%
% Inputs:
%   x       - Vector of x-axis values (e.g., wavenumbers or wavelengths)
%   y       - Vector of y-axis values (e.g., intensities)
%   knot1_x - X-coordinate for the first baseline anchor point
%   knot2_x - X-coordinate for the second baseline anchor point
%
% Outputs:
%   corrected_y     - The baseline-corrected spectrum
%   linear_baseline - The calculated linear baseline that was subtracted

    % 1. Find the closest actual indices in your data for the specified knots
    [~, idx1] = min(abs(x - knot1_x));
    [~, idx2] = min(abs(x - knot2_x));

    % Get the corresponding y-values
    knot1_y = y(idx1);
    knot2_y = y(idx2);

    % 2. Calculate the linear baseline (y = mx + c)
    slope = (knot2_y - knot1_y) / (x(idx2) - x(idx1));
    intercept = knot1_y - slope * x(idx1);
    
    % Generate the baseline across the entire x range
    linear_baseline = slope * x + intercept;

    % 3. Subtract the baseline from the original spectrum
    corrected_y = y - linear_baseline;
end