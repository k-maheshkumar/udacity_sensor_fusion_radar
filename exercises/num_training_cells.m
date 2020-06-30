% Select the number of training cells in both the dimensions.
Tr = 8;  % Training (range dimension)
Td = 4;  % Training cells (doppler dimension)

% Select the number of guard cells in both dimensions around the Cell Under 
% Test (CUT) for accurate estimation.
Gr = 4;  % Guard cells (range dimension)
Gd = 2;  % Guard cells (doppler dimension)

% Offset the threshold by SNR value in dB
offset = 15;

% Calculate the total number of training and guard cells
N_guard = (2 * Gr + 1) * (2 * Gd + 1) - 1;  % Remove CUT
N_training = (2 * Tr + 2 * Gr + 1) * (2 * Td + 2 * Gd + 1) - (N_guard + 1)