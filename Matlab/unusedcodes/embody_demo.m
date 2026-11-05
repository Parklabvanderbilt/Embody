%% Short matlab demo to load and visualize emBODY data
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
% Code by Enrico Glerean and Lauri Nummenmaa
%
% Thanks to Laura Harrison @ caltech for useful feedback

% let's begin
close all
clear all

%Create Matrices for hot and cold total values, where number of row = N
C=zeros(9,14);
H=zeros(9,14);

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
        
        % Creation of hot and cold totals for each emotion
        %Hot
        H(s,n)=sum(sum(over(10:531,33:203,:)));
        %Cold
        C(s,n)=sum(sum(over(10:531,696:866,:)));
        
            Cold_Arms(s,n)=sum(sum(over(10:531,696:735,:)))+sum(sum(over(10:531,825:866,:)))
            Cold_Abs(s,n)=sum(sum(over(205:305,736:825,:)))
            Cold_Chest(s,n)=sum(sum(over(10:280,736:825,:)))
            Cold_Legs(s,n)=sum(sum(over(305:531,736:825,:)))
            Hot_Head(s,n)=sum(sum(over(10:85,135:205,:)))
            Hot_Legs(s,n)=sum(sum(over(305:531,71:214,:)))
            Hot_Abs(s,n)=sum(sum(over(205:305,71:214,:)))
            Hot_Chest(s,n)=sum(sum(over(10:205,71:214,:)))
            Hot_Arms(s,n)=sum(sum(over(10:531,33:71,:)))+sum(sum(over(10:531,214:400,:)))
            Cold_Head(s,n)=sum(sum(over(10:85, 735:805,:)))
     
        % we subtract left part minus right part of painted area
        over2=over(10:531,33:203,:)-over(10:531,696:866,:);
        resmat(:,:,n)=over2;
    end
end

cold_regionz = [Cold_Head, Cold_Chest, Cold_Abs, Cold_Arms, Cold_Legs]
hot_regionz = [Hot_Head, Hot_Chest, Hot_Abs, Hot_Arms, Hot_Legs]

regionz = [hot_regionz, cold_regionz]

csvwrite('region_wise_activation.csv',regionz)    
