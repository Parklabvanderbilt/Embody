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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create files for group one's hot matrix

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
        over2=over(10:531,33:203,:);
        resmat(:,:,n)=over2;
    end
    %% store result (commented)
    save(['preprocessed/' subjects(s).name '_preprocessed.mat'],'resmat')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create files for group one's cold matrix

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
        over2=over(10:531,696:866,:);
        resmat(:,:,n)=over2;
    end
    %% store result (commented)
    save(['preprocessed2/' subjects(s).name '_preprocessed2.mat'],'resmat')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create files for group two's hot matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% let's begin
close all
clear all

% get a list of subjects
basepath='subjects2'; % folder where subjects are
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
        over2=over(10:531,33:203,:)-over(10:531,696:866,:);
        resmat(:,:,n)=over2;
    end
    %% store result (commented)
    save(['preprocessed3/' subjects(s).name '_preprocessed3.mat'],'resmat')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create files for group two's cold matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% let's begin
close all
clear all

% get a list of subjects
basepath='subjects2'; % folder where subjects are
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
        over2=over(10:531,33:203,:)-over(10:531,696:866,:);
        resmat(:,:,n)=over2;
    end
    %% store result (commented)
    save(['preprocessed4/' subjects(s).name '_preprocessed4.mat'],'resmat')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create group one's hot proportional matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% mask (we consider only pixels inside the mask for multiple comparisons)
mask=imread('mask.png');
in_mask=find(mask>128); % list of pixels inside the mask


%% load all subjects
basepath=['./preprocessed/']
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody.m
NS=length(files);
NC=14; % number of conditions
data=zeros(length(in_mask),NS,NC);

for s=1:NS
    load([basepath files(s).name]); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp=reshape(resmat,[],NC);
    data(:,s,:)=temp(in_mask,:);
end
    
NP=50364;
NC=14;

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

TotMat=(M_neut_new + M_pos_new + M_neg_new); % should be a matrix of all 1s, if not, there's an issue
F_hot_one=(((M_pos_new).^2)-(((M_neg_new).^2)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create group one's cold proportional matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% let's begin
close all
clear all

%% mask (we consider only pixels inside the mask for multiple comparisons)
mask=imread('mask.png');
in_mask=find(mask>128); % list of pixels inside the mask


%% load all subjects
basepath=['./preprocessed2/']
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody.m
NS=length(files);
NC=14; % number of conditions
data=zeros(length(in_mask),NS,NC);

for s=1:NS
    load([basepath files(s).name]); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp=reshape(resmat,[],NC);
    data(:,s,:)=temp(in_mask,:);
end
    
NP=50364;
NC=14;

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

TotMat=(M_neut_new + M_pos_new + M_neg_new); % should be a matrix of all 1s, if not, there's an issue
F_cold_one=(((M_pos_new).^2)-(((M_neg_new).^2)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create group two's hot proportional matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% let's begin
close all
clear all

%% mask (we consider only pixels inside the mask for multiple comparisons)
mask=imread('mask.png');
in_mask=find(mask>128); % list of pixels inside the mask


%% load all subjects
basepath=['./preprocessed3/']
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody.m
NS=length(files);
NC=14; % number of conditions
data=zeros(length(in_mask),NS,NC);

for s=1:NS
    load([basepath files(s).name]); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp=reshape(resmat,[],NC);
    data(:,s,:)=temp(in_mask,:);
end
    
NP=50364;
NC=14;

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

TotMat=(M_neut_new + M_pos_new + M_neg_new); % should be a matrix of all 1s, if not, there's an issue
F_hot_two=(((M_pos_new).^2)-(((M_neg_new).^2)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create group two's cold proportional matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% let's begin
close all
clear all

%% mask (we consider only pixels inside the mask for multiple comparisons)
mask=imread('mask.png');
in_mask=find(mask>128); % list of pixels inside the mask


%% load all subjects
basepath=['./preprocessed4/']
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody.m
NS=length(files);
NC=14; % number of conditions
data=zeros(length(in_mask),NS,NC);

for s=1:NS
    load([basepath files(s).name]); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp=reshape(resmat,[],NC);
    data(:,s,:)=temp(in_mask,:);
end
    
NP=50364;
NC=14;

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

TotMat=(M_neut_new + M_pos_new + M_neg_new); % should be a matrix of all 1s, if not, there's an issue
F_cold_two=(((M_pos_new).^2)-(((M_neg_new).^2)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create proportional two-group difference matrix for hot and for cold

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

F_hot = (F_hot_one) - (F_hot_two)
F_cold = (F_cold_one) - (F_cold_two)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate the proportional hot difference map

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% plot tmaps

MAX = max(max(F_hot)); % max range for colorbar
MIN = min(min(F_hot)); % min range for colorbar

if abs(MAX) > abs(MIN)
    M = MAX
else
    M = MIN
end

NumCol=64;

hotmap=autumn(NumCol);
coldmap=flipud([hotmap(:,3) hotmap(:,2) hotmap(:,1) ]);
hotcoldmap=[
    coldmap
    zeros(2,3);
    hotmap
    ];

% reshaping the F values into images
tvals_for_plot=zeros(size(mask,1),size(mask,2),NC);
for condit=1:NC
    temp=zeros(size(mask));
    temp(in_mask)=F_hot(:,condit);
    temp(find(~isfinite(temp)))=0; % we set nans and infs to 0 for display
    max(temp(:))
    tvals_for_plot(:,:,condit)=temp;
end

% plotting
plotcols = 7; %set as desired
plotrows = ceil((NC+1)/plotcols); % number of rows is equal to number of conditions+1 (for the colorbar)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate the proportional cold difference map

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% plot tmaps

MAX = max(max(F_cold)); % max range for colorbar
MIN = min(min(F_cold)); % min range for colorbar

if abs(MAX) > abs(MIN)
    M = abs(MAX)
else
    M = abs(MIN)
end

NumCol=64;

hotmap=autumn(NumCol);
coldmap=flipud([hotmap(:,3) hotmap(:,2) hotmap(:,1) ]);
hotcoldmap=[
    coldmap
    zeros(2,3);
    hotmap
    ];

% reshaping the F values into images
tvals_for_plot=zeros(size(mask,1),size(mask,2),NC);
for condit=1:NC
    temp=zeros(size(mask));
    temp(in_mask)=F_cold(:,condit);
    temp(find(~isfinite(temp)))=0; % we set nans and infs to 0 for display
    max(temp(:))
    tvals_for_plot(:,:,condit)=temp;
end

% plotting
plotcols = 7; %set as desired
plotrows = ceil((NC+1)/plotcols); % number of rows is equal to number of conditions+1 (for the colorbar)
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



