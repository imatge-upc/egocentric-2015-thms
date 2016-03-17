function [featuresWithName]=extractNF(datapath,features)
% old=cd(path);
files=dir([datapath '/*.jpg']);
featuresWithName=zeros(size(features,1),size(features,2)+1);
featuresWithName(:,2:end)=features;
for k=1:length(files)
    
    filenumber=strread(files(k).name,'%s','delimiter','.');
    featuresWithName(k,1)=str2num(filenumber{1});  
    
end

end