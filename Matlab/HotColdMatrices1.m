%% Purpose: Generating NP x N x NC matrices for activation and deactivation
%% Author: L?nie Torregrossa 
%% Date : 10/12018


close all
clear all


% system('rm -rf subjects/*'),

system('rm -rf preprocessed/*');
system('rm -rf preprocessed2/*');

% get a list of subjects
basepath='subjects'; % folder where subjects are
subjects=dir([basepath '/*']);

%% create positive matrix

% the base image used for painting (in our case only one sided since we
% subtract values)
base=uint8(imread('base.png'));
base2=base(10:531,33:203,:); % single image base
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

% for each subject, load data
for s=1:length(subjects)
    % skip dot and dotdot folders
    if(strcmp(subjects(s).name(1),'.')) continue; end 

    %% Data loading
    % let's load the subject's answers into a variable a
    data=load_subject([basepath '/' subjects(s).name],2);
    NC=length(data); % number of conditions
    
    %% Painting reconstruction
    % 'data' now contains all mouse movements. What we need are the mouse
    % locations while the button was pressed (i.e. during painting)
    % Furthermore, the painting tool has a brush size. We recreate that
    % using image filter
    
    for n=1:NC;
        T=length(data(n).paint(:,2)); % number of mouse locations
        over=zeros(size(base,1),size(base,2)); % empty matrix to reconstruct painting
        for t=1:T
            y=ceil(data(n).paint(t,3)+1);
            x=ceil(data(n).paint(t,2)+1);
            if(x<=0) x=1; end
            if(y<=0) y=1; end
            if(x>=900) x=900; end % hardcoded for our experiment, you need to change it if you changed layout
            if(y>=600) y=600; end % hardcoded for our experiment, you need to change it if you changed layout
            over(y,x)=over(y,x)+1;
        end
        % Simulate brush size with a gaussian disk
        h=fspecial('gaussian',[15 15],5);
        over=imfilter(over,h);
        % we subtract left part minus right part of painted area
        % values are hard-coded to our web layout
        over2=over(10:531,33:203,:);
        resmat(:,:,n)=over2;
    end
    % store result 
    save(['preprocessed/' subjects(s).name '_preprocessed.mat'],'resmat')
end



% mask (we consider only pixels inside the mask for multiple comparisons)
mask=imread('mask.png');
in_mask=find(mask>128); % list of pixels inside the mask


% load all subjects
basepath=['./preprocessed/']
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody.m
NS=length(files);
NC=17; % number of conditions
NP=50364;
pos=zeros(length(in_mask),NS,NC);

for s=1:NS
    load([basepath files(s).name]); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp=reshape(resmat,[],NC);
    pos(:,s,:)=temp(in_mask,:);
end
    


%save your matrix of positive pixel values

save  SZ_P.mat pos % change name


%% create negative matrix


% get a list of subjects
basepath='subjects'; % folder where subjects are
subjects=dir([basepath '/*']);

% the base image used for painting (in our case only one sided since we
% subtract values)
base=uint8(imread('base.png'));
base2=base(10:531,33:203,:); % single image base
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

% for each subject, load data
for s=1:length(subjects)
    % skip dot and dotdot folders
    if(strcmp(subjects(s).name(1),'.')) continue; end 

    %% Data loading
    % let's load the subject's answers into a variable a
    data=load_subject([basepath '/' subjects(s).name],2);
    NC=length(data); % number of conditions
    
    %% Painting reconstruction
    % 'data' now contains all mouse movements. What we need are the mouse
    % locations while the button was pressed (i.e. during painting)
    % Furthermore, the painting tool has a brush size. We recreate that
    % using image filter
    
    for n=1:NC;
        T=length(data(n).paint(:,2)); % number of mouse locations
        over=zeros(size(base,1),size(base,2)); % empty matrix to reconstruct painting
        for t=1:T
            y=ceil(data(n).paint(t,3)+1);
            x=ceil(data(n).paint(t,2)+1);
            if(x<=0) x=1; end
            if(y<=0) y=1; end
            if(x>=900) x=900; end % hardcoded for our experiment, you need to change it if you changed layout
            if(y>=600) y=600; end % hardcoded for our experiment, you need to change it if you changed layout
            over(y,x)=over(y,x)+1;
        end
        % Simulate brush size with a gaussian disk
        h=fspecial('gaussian',[15 15],5);
        over=imfilter(over,h);
        % we subtract left part minus right part of painted area
        % values are hard-coded to our web layout
        over2=over(10:531,696:866,:);
        resmat(:,:,n)=over2;
    end
    % store result 
    save(['preprocessed2/' subjects(s).name '_preprocessed2.mat'],'resmat')
end

% mask (we consider only pixels inside the mask for multiple comparisons)
mask=imread('mask.png');
in_mask=find(mask>128); % list of pixels inside the mask


% load all subjects
basepath=['./preprocessed2/']
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody.m
NS=length(files);
NC=17; % number of conditions
NP=50364;
neg=zeros(length(in_mask),NS,NC);

for s=1:NS
    load([basepath files(s).name]); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp=reshape(resmat,[],NC);
    neg(:,s,:)=temp(in_mask,:);
end
    
%save your matrix of negative pixel values

save  SZ_N.mat neg % change name


% then run mix_script2.R






