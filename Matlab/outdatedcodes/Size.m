
% Code adjusted from embody.m by Enrico Glerean and Lauri Nummenmaa
% This method was used by Lloyd et al., 2021; Galvez-Pol et al., 2021

%% This script creates a N x NC matrix of proportion of body colored (for each participant and emotion, how much of the body was colored). 

% Start with the preprocessed files 

% Load mask and find relevant pixels
mask = imread('mask.png');
in_mask = find(mask > 128); % Pixels within the mask

% Load subject files
basepath='./preprocessed/'; % Folder containing subject files
files = dir([basepath '/*.mat']); % List of preprocessed .mat files
NS = length(files);
NC = 17; % Number of conditions
NP = 50364; % Total number of pixels
pix = zeros(length(in_mask), NS, NC); % Preallocate pixel data

% Process each subject file
for s = 1:NS
    clear('resmat');
    load(fullfile(basepath, files(s).name)); % Load subject data
    if exist('resmat', 'var') == 1
        temp = reshape(resmat, [], NC);
    elseif exist('Z', 'var') == 1
        temp = reshape(Z, [], NC);
    else
        warning(['No resmat or Z found in ' files(s).name ', skipping.']);
        continue;
    end
    pix(:, s, :) = temp(in_mask, :);
end

% Preallocate new_mat for better performance
new_mat = zeros(NS, NC);

% Count nonzero pixels for each subject and condition
for i = 1:NS
    for j = 1:NC
        new_mat(i, j) = sum(pix(:, i, j) > 0);
    end
end

% Normalize by total pixel count
new_mat = new_mat ./ NP;

% Save results as CSV
writematrix(new_mat, 'size.csv');
