%% Get pixel count for activation and deactivation
%
% Code from embybo.m by Enrico Glerean and Lauri Nummenmaa
% Pixel count by L?nie Torregrossa

% let's begin
close all
clear all

system('rm -rf preprocessed/*');
system('rm -rf preprocessed2/*');

%Create Matrices for hot and cold total values
NC = 17;

C = [];  % Start with empty arrays
H = [];
subjectIDs = {}; % Store Subject IDs

% get a list of subjects
basepath='subjects'; % folder where subjects are
subjects=dir([basepath '/*']);

% the base image used for painting
base=uint8(imread('base.png'));
base2=base(10:531,33:203,:);
labels={'Neutral'
'Fear'
'Anger'
'Disgust'
'Sadness'
'Happiness'
'Lonely'
'Anxiety'
'Love'
'Depression'
'Pride'
'Shame'
'Jealousy'
'Stress'
'Migraine' 
'Nausea'
'Sense of Self'
};
mask=imread('mask.png');

% Counter for actual subjects processed
subj_count = 0;

% for each subject, load data
for s=1:length(subjects)
    % skip dot and dotdot folders
    if(strcmp(subjects(s).name(1),'.')) 
        continue; 
    end 

    % Increment counter
    subj_count = subj_count + 1;
    
    % Extract and store Subject ID
    subjectID = subjects(s).name;
    subjectIDs{subj_count, 1} = subjectID;

    %% Data loading
    data=load_subject([basepath '/' subjects(s).name],2);
    NC=length(data); % number of conditions
    
    %% Painting reconstruction
    for n=1:NC
        num_paint=length(data(n).paint(:,2)); % Changed from T to num_paint
        over=zeros(size(base,1),size(base,2));
        for t=1:num_paint % Changed from T to num_paint
            y=ceil(data(n).paint(t,3)+1);
            x=ceil(data(n).paint(t,2)+1);
            if(x<=0) x=1; end
            if(y<=0) y=1; end
            if(x>=900) x=900; end
            if(y>=600) y=600; end
            over(y,x)=over(y,x)+1;
        end
        % Simulate brush size with a gaussian disk
        h=fspecial('gaussian',[15 15],5);
        over=imfilter(over,h);
        
        % Hot and Cold totals
        H(subj_count,n)=sum(sum(over(10:531,33:203,:)));
        C(subj_count,n)=sum(sum(over(10:531,696:866,:)));
     
        over2=over(10:531,33:203,:)-over(10:531,696:866,:);
        resmat(:,:,n)=over2;
    end  % END for n loop
end  % END for s loop

fprintf('Processed %d subjects\n', subj_count);

%% saving H, C and T results in ONE .csv file with Subject IDs

% Calculate Total (now T won't conflict)
Total = H + C;

% Debug sizes
fprintf('Size of subjectIDs: %d x %d\n', size(subjectIDs, 1), size(subjectIDs, 2));
fprintf('Size of H: %d x %d\n', size(H, 1), size(H, 2));
fprintf('Size of C: %d x %d\n', size(C, 1), size(C, 2));
fprintf('Size of Total: %d x %d\n', size(Total, 1), size(Total, 2));

% Create column names
actual_NC = size(H, 2);
hot_cols = cell(1, actual_NC);
cold_cols = cell(1, actual_NC);
total_cols = cell(1, actual_NC);

for i = 1:actual_NC
    hot_cols{i} = ['hotpixelcount_' labels{i}];
    cold_cols{i} = ['coldpixelcount_' labels{i}];
    total_cols{i} = ['totalpixelcount_' labels{i}];
end

% Combine all data
all_data = [subjectIDs, num2cell(H), num2cell(C), num2cell(Total)];

fprintf('Size of all_data: %d x %d\n', size(all_data, 1), size(all_data, 2));

% Create header row
header = [{'SubjectID'}, hot_cols, cold_cols, total_cols];
fprintf('Number of headers: %d\n', length(header));

% Create table
varNames = matlab.lang.makeValidName(header);
dataTable = cell2table(all_data, 'VariableNames', varNames);

% Save to CSV
writetable(dataTable, 'DPD_pixels_all.csv');

disp('All pixel counts saved in one CSV with Subject IDs!');