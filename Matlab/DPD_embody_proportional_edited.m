% emBODY proportional: visualization for small sample sizes

% Original code by: Enrico Glerean and Lauri Nummenmaa
% Revision by: Seok (Justin) Hong and Matthew Snodgress

% The following revision of the original emBODY program converts the smoothed data array from emBODY_stats
% into three matrices of proportions. Specifically, the number of positive, negative, or zero values were counted
% for a given pixel and emotion condition, across all subjects, and this value was divided by the number of 
% subjects, producing a matrix with the proportion of negative values (50364 by 14 matrix), one with the proportion
% of positive values, and one with the proportion of zero values. The three matrices were then combined by the following
% equation: ((P^2) - (N^2)) = F ...where P represents the matrix of the proportion of positive values at a given
% pixel and emotion condition, and N is the same for negative values. This equation accounts for the difference between
% the proportion of positive to negative values, while also scaling that difference by the proportion of non-zero values as
% the equation can be rewritten: (P - N) * (P + N) = F. F consisted of values between -1 and 1. To produce the color bar range,
% the absolute values of the maximum and minimum values of F were compared, and the greater one of the two became the range
% from -M to M, for the greater M of the two.

% NOTE:
% The following program simply requires the raw data to be in the subjects folder. It takes care of the rest itself.


% let's begin
close all
clear all

system('rm -rf preprocessed/*');

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
        over2=over(10:531,33:203,:)-over(10:531,696:866,:);
        resmat(:,:,n)=over2;
    end
    %% store result (commented)
    save(['preprocessed/' subjects(s).name '_preprocessed.mat'],'resmat')
end



%% this is just a quick demo of how to efficiently run a one sample ttest
% for a set of preprocessed subjects

%% mask (we consider only pixels inside the mask for multiple comparisons)
mask=imread('mask.png');
in_mask=find(mask>128); % list of pixels inside the mask


%% load all subjects
basepath=['./preprocessed/']
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody.m
NS=length(files);
NC=17; % number of conditions
data=zeros(length(in_mask),NS,NC);

for s=1:NS
    load([basepath files(s).name]); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp=reshape(resmat,[],NC);
    data(:,s,:)=temp(in_mask,:);
end
    
NP=50364;
NC=17;

M_neut=zeros(NP,NC);
M_pos=zeros(NP,NC);
M_neg=zeros(NP,NC); 


for condit=1:NC
   for numpix=1:NP
        neut = length(data(data(numpix,:,condit)==0)');
            M_neut(numpix,condit)=neut;
        pos = length(data(data(numpix,:,condit)>0)');
            M_pos(numpix,condit)=pos;
        neg = length(data(data(numpix,:,condit)<0)');
            M_neg(numpix,condit)=neg;    
   end
end

M_neut_new=M_neut/NS;
M_pos_new=M_pos/NS;
M_neg_new=M_neg/NS;

TotMat=(M_neut_new + M_pos_new + M_neg_new); % should be a matrix of all 1s
F=(((M_pos_new).^2)-(((M_neg_new).^2)));



%% plot tmaps

MAX = max(max(F)); % max range for colorbar
MIN = min(min(F)); % min range for colorbar

if abs(MAX) > abs(MIN)
    M = MAX
else
    M = MIN
end

M = .5

NumCol=64;

hotmap=hot(NumCol);
coldmap=flipud([hotmap(:,3) hotmap(:,2) hotmap(:,1) ]);
hotcoldmap=[
    coldmap
    zeros(2,3);
    hotmap
    ];

% reshaping the tvalues into images
tvals_for_plot=zeros(size(mask,1),size(mask,2),NC);
for condit=1:NC
    temp=zeros(size(mask));
    temp(in_mask)=F(:,condit);
    temp(find(~isfinite(temp)))=0; % we set nans and infs to 0 for display
    max(temp(:))
    tvals_for_plot(:,:,condit)=temp;
end

% plotting
plotcols = 8; %set as desired
plotrows = ceil((NC+1)/plotcols); % number of rows is equal to number of conditions+1 (for the colorbar)
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
for n=1:NC
    figure(100)
    subplot(plotrows,plotcols,n)
    imagesc(base2);
    axis('off');
    set(gcf,'Color',[1 1 1]);
    hold on;
    over2=tvals_for_plot(:,:,n);
    fh=imagesc(over2,[-M,M]);
    axis('off');
    axis equal
    colormap(hotcoldmap);
    set(fh,'AlphaData',mask)
    title(labels(n),'FontSize',10)
    if(n==NC)
        subplot(plotrows,plotcols,n+1)
        fh=imagesc(ones(size(base2)),[-M,M]);
        axis('off');
        colorbar;
    end
end


