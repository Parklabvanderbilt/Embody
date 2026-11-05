%% this is just a quick demo of how to efficiently run a One-way ANOVA
% for a set of preprocessed subjects

clear all
close all


%% mask (we consider only pixels inside the mask for multiple comparisons)
mask=imread('mask.png');
in_mask=find(mask>128); % list of pixels inside the mask


%% load all subjects
basepath=['./preprocessed/']
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody1.m
NS=length(files);
NC=14; % number of conditions
data=zeros(length(in_mask),NS,NC);

for s=1:NS
    load([basepath files(s).name]); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp=reshape(resmat,[],NC);
    data(:,s,:)=temp(in_mask,:);
end

%% load all subjects2
basepath=['./preprocessed2/']
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody2.m
NS2=length(files);
NC2=14; % number of conditions
data2=zeros(length(in_mask),NS2,NC2);

for s=1:NS2
    load([basepath files(s).name]); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp2=reshape(resmat,[],NC2);
    data2(:,s,:)=temp2(in_mask,:);
end

%% load all subjects3
basepath=['./preprocessed3/']
files=dir([basepath '*.mat']); % preprocessed files, obtained by running embody3.m
NS3=length(files);
NC3=14; % number of conditions
data3=zeros(length(in_mask),NS3,NC3);

for s=1:NS3
    load([basepath files(s).name]); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp3=reshape(resmat,[],NC3);
    data3(:,s,:)=temp3(in_mask,:);
end
