data=load('/media/HDD_2TB/mcarne/keyframe-extractor/precomputed/Estefania1/Prefiltering/prefiltering_n.mat');

j=1; %New vector index
k=1;

for i=1:length(data.features)
    if data.features(i,3) > 0.7
        info(j,:)=data.features(i,:);
        j=j+1;
    elseif data.features(i,3) < 0.3
        noinfo(k,:)=data.features(i,:);
        k=k+1;
    end
end

info_sort=sort(info,'descend');
noinfo_sort=sort(noinfo,'ascend');