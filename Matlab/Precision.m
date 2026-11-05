%% Embodiment Diffusion Script (aka, average distance script)
%
% Original Code by Enrico Glerean and Lauri Nummenmaa
% Modifications by Benjamin Perlin and Matthew Snodgress
%
% Overview: this script calculates the average distance among all selected
% pixels for each region of interest, for each condition, per subject.
% The resulting output is a data matrix consisting of distance statistics
% and indicator variables for ROI, Emotion, and Subject. 
% This data can easily be subjected to a mixed-design ANOVA 
% (ROI and Emotion as within-subject factors, and Group
% as between-subject, once a second group is added). Otherwise, linear
% mixed-effects models work just as well (if not better) for analysis
% purposes. The raw distance metrics for ROI x Emotion x Subject are
% contained in the output file called 'data_raw.csv'. Zero values in this
% file represent that a subject failed to report any embodiment for that
% ROI and that emotion.
% 
% Directions: add a single group's embodiment data to the 'subjects'
% folder like with the usual 'embody.m' script. Make sure the 'preprocessed' 
% folder is empty. Ensure that the matrix_precision.m file is configured 
% correctly, given your operating system. 
% Then, run this script. The final result is a data matrix
% called 'ddata.csv' with one dependent variable and three grouping variables 
% (ROI, emotion, and subject), which can be used for linear modeling. The
% output data matrix is written to the current working directory.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% let's begin
close all
clear all

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
'Surprise'
'Anxiety'
'Love'
'Depression'
'Contempt'
'Pride'
'Shame'
'Jealousy'
};
mask=imread('mask.png');

% for each subject, load data
for s=1:length(subjects)
    % skip dot and dotdot folders
    if(strcmp(subjects(s).name(1),'.')) continue; end 

    %% Data loading
    % let's load the subject's answers into a variable a
    data=load_subj([basepath '/' subjects(s).name],2);
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
        over2=over(10:531,33:203,:) - over(10:531,696:866,:);
        resmat(:,:,n)=over2;
    end
    %% store result (commented)
    save(['preprocessed/' subjects(s).name '_preprocessed.mat'],'resmat')
end


%% mask (we consider only pixels inside the mask for multiple comparisons)
mask=imread('mask.png');
in_mask=find(mask>128); % list of pixels inside the mask


%% load all subjects
basepath=['./preprocessed/'];
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody_demo.m
NS=length(files);
NC=14; % number of conditions
datanew=zeros(522,171,NC, NS);

for s=1:NS
    clear('resmat');
    load([basepath files(s).name]); % now we have variable resmat
    if exist('resmat','var')== 1
    temp = resmat;
    else temp = Z;
    end
    datanew(:,:,:,s)=temp;
end

% Need to replace the sum function below with Ben's function somehow
% Also note: the numbers below are hard-coded and should not be changed
% unless you know what you're doing. 
store=zeros(5, 14, NS);
for b=1:NS
    for c=1:NC
        head=datanew(1:74,58:118, c, b);
        leftarm=datanew(91:303, 1:35,c,b);
        rightarm=datanew(96:303,143:171,c, b);
        leftleg=datanew(312:522,38:89, c, b);
        rightleg=datanew(312:522,89:134,c,b);
        abs=datanew(206:312,38:143,c,b);
        chest=datanew(74:206,38:143,c,b);
        h=matrix_precision(head);
        la=matrix_precision(leftarm);
        ra=matrix_precision(rightarm);
        ll=matrix_precision(leftleg);
        rl=matrix_precision(rightleg);
        ab=matrix_precision(abs);
        ch=matrix_precision(chest);
        arm = (la+ra)/2;
        leg = (ll+rl)/2;
        m = [h, arm, leg, ab, ch];
        store(:,c,b)=m;
        store(isnan(store))=0;
    end
end

rowNames = {'head','arm', 'leg', 'ab', 'chest'};
%Ba = reshape(store,[(5*NS),14]);
%sTable = array2table(Ba,'VariableNames',labels);
v = [1:5];
v = v(ones(1,NS*14),:);
v = v';
r_ind = reshape(v, [5*14*NS, 1]);
w = repelem(1:14, 5);
w1 = repmat(w, NS);
w2 = w1(1,:);
e_ind = reshape(w2', [5*14*NS, 1]);
z_ind = repelem(1:NS, 14*5)';
s = reshape(store, [NS*5*14,1]);
DA = [s r_ind e_ind z_ind];
labels2 = {'values','roi','emotion','subject'};
gTable = array2table(DA,'VariableNames',labels2);

writetable(gTable, 'ddata.csv');

%% Reshaping matrix in R

% Import ddata in R and run the forllowing lines to get a score per person, per emotion

% d= aggregate(data$values,by=list(subject=data$subject,emotion=data$emotion),data=data,FUN=mean)
% write.csv(d, 'perSubj_perEm.csv')


% OR the following lines to get a score per person

% p= aggregate(data$values,by=list(subject=data$subject),data=data,FUN=mean)
% write.csv(p, 'perSubj.csv')

