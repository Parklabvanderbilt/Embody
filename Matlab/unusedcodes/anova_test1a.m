%% data, data2, data3

DATA = horzcat(data, data2, data3)
DaTap = permute(DATA, [2 3 1])
g = vertcat(repmat(0,NS,1), repmat(1,NS2,1), repmat(2,NS3,1))

t2data=zeros(length(in_mask),NC);
for condit=1:NC
    [H,TBL,STATS] = anova1(DaTap(:,:,condit));
    t2data(:)=STATS;
end