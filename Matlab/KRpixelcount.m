%% Get pixel count for activation and deactivation
%
% - Please note that there are hard-coded parameters related to our
% experiment version. If you modify the graphic layout of the web tool you
% will need to change also how matlab preprocesses the data
% - In our experiment we treated the left part of the screen as positive
% values and the right part as negative values, and performed a subtraction
% between the two. You are free to use the whole painting area and you
% don't need to subtract the values if left and right silouhettes have
% different meanings than activation/deactivation.
% - The demo uses the function load_subj, make sure it is in your path
% - It should be easy to rewrite this in python for those without a Matlab
% license.
%
% Code from embybo.m by Enrico Glerean and Lauri Nummenmaa
%
% Pixel count by L?nie Torregrossa

% let's begin
close all
clear all

system('rm -rf preprocessed/*');
system('rm -rf preprocessed2/*');

%Create Matrices for hot and cold total values, where number of row = N,
%number of col = NC 

NC= 22

C=zeros(1,NC); %change depending on your data
H=zeros(1,NC);

% get a list of subjects
basepath='subjects'; % folder where subjects are
subjects=dir([basepath '/*']);

% the base image used for painting (in our case only one sided since we
% subtract values)
base=uint8(imread('base.png'));
base2=base(10:531,33:203,:); % single image base
labels={
'Neutral'
'Fear'
'Anger'
'Disgust'
'Sadness'
'Happiness'
'Anxiety'
'Love'
'Depression'
'Pride'
'Shame'
'Stress'
'Loneliness'
'Rejection'
'Acceptance'
'Motivation'
'Regret'
'Trauma'
'Isolation'
'Disconnection'
'Grief'
'Hope'
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
        
        % Creation of hot and cold totals for each emotion
        %Hot
        H(s,n)=sum(sum(over(10:531,33:203,:)));
        %Cold
        C(s,n)=sum(sum(over(10:531,696:866,:)));
     
        % we subtract left part minus right part of painted area
        over2=over(10:531,33:203,:)-over(10:531,696:866,:);
        resmat(:,:,n)=over2;
    end
end


%% saving H, C and T results in .csv files 

em=labels'

% create cell array for Hot pixel counts with emotion labels 
H=H([3:end],:)%removing the first three blank rows 
Hmat= [em; num2cell(H)]


%save as .csv file
 fid = fopen('ACO_all26_pixel_H.csv', 'w') ; %change name you want your .csv saved under
 fprintf(fid, '%s,', Hmat{1,1:end-1}) ;
 fprintf(fid, '%s\n', Hmat{1,end}) ;
 fclose(fid) ; 
 dlmwrite('ACO_all26_pixel_H.csv', Hmat(2:end,:), '-append') ; %change name you want your .csv saved under

 % Cold pixel counts
C=C([3:end],:) 
Cmat= [em; num2cell(C)]


 fid = fopen('ACO_all26_pixel_C.csv', 'w') ; %change name you want your .csv saved under
 fprintf(fid, '%s,', Cmat{1,1:end-1}) ;
 fprintf(fid, '%s\n', Cmat{1,end}) ;
 fclose(fid) ; 
 dlmwrite('ACO_all26_pixel_C.csv', Cmat(2:end,:), '-append') ; %change name you want your .csv saved under

 % Total pixel counts
 
T= H+C

Tmat= [em;num2cell(T)];

 fid = fopen('ACO_all26_pixel_T.csv', 'w') ; %change name you want your .csv saved under
 fprintf(fid, '%s,', Tmat{1,1:end-1}) ;
 fprintf(fid, '%s\n', Tmat{1,end}) ;
 fclose(fid) ; 
 dlmwrite('ACO_all26_pixel_T.csv', Tmat(2:end,:), '-append') ; %change name you want your .csv saved under

 
 
 

 