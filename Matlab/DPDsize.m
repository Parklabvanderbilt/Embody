
% Code adjusted from embody.m by Enrico Glerean and Lauri Nummenmaa
% This method was used by Lloyd et al., 2021; Galvez-Pol et al., 2021

%% This script creates a N x NC matrix of proportion of body colored (for each participant and emotion, how much of the body was colored). 

%% Initialize
% Load mask and find relevant pixels
mask = imread('mask.png');
in_mask = find(mask > 128); % Pixels within the mask

% Load subject files
basepath = './preprocessed/'; % Folder containing subject files
files = dir([basepath '/*.mat']); % List of preprocessed .mat files
NS = length(files);
NC = 17; % Number of conditions
NP = 50364; % Total number of pixels
pix = zeros(length(in_mask), NS, NC); % Preallocate pixel data
subjectIDs = {}; % Store Subject IDs

% Emotion labels
labels = {'Neutral', 'Fear', 'Anger', 'Disgust', 'Sadness', 'Happiness', ...
          'Lonely', 'Anxiety', 'Love', 'Depression', 'Pride', 'Shame', ...
          'Jealousy', 'Stress', 'Migraine', 'Nausea', 'Sense of Self'};

%% Process each subject file
for s = 1:NS
    clear('resmat');
    load(fullfile(basepath, files(s).name)); % Load subject data
    
    % Extract and store Subject ID
    subjectID = strrep(files(s).name, '_preprocessed.mat', '');
    subjectIDs = [subjectIDs; subjectID];
    
    % Check if resmat or Z exists and reshape data
    if exist('resmat', 'var') == 1
        temp = reshape(resmat, [], NC);
    elseif exist('Z', 'var') == 1
        temp = reshape(Z, [], NC);
    else
        warning(['No resmat or Z found in ' files(s).name ', skipping.']);
        continue;
    end
    
    % Store pixel data
    pix(:, s, :) = temp(in_mask, :);
end

%% Count nonzero pixels for each subject and condition
new_mat = zeros(NS, NC);
for i = 1:NS
    for j = 1:NC
        new_mat(i, j) = sum(pix(:, i, j) > 0);
    end
end

% Normalize by total pixel count
new_mat = new_mat ./ NP;

%% Prepare Data for CSV
% Combine Subject IDs with data
final_mat = [subjectIDs, num2cell(new_mat)];

% Convert to table with appropriate column names
final_table = cell2table(final_mat, 'VariableNames', ['SubjectID', labels]);

% Write table to CSV
writetable(final_table, 'size_with_subjectIDs.csv');

