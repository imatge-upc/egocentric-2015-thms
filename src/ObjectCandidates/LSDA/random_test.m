%% 10 random images with them 5 objects candidates

%File that contains the scores for each class in each image
data=load('/media/HDD_2TB/mcarne/keyframe-extractor/precomputed/Estefania1/LSDA/LSDAfeatures_n.mat');

random_index=round(rand([1 10])*500);

cd('/media/HDD_2TB/mcarne/keyframe-extractor/db/Estefania1');

%Read txt with the classes
text = fileread('/media/HDD_2TB/mcarne/keyframe-extractor/precomputed/Estefania1/LSDA/objectsLSDA.txt');

lines = regexp(text, '\n', 'split');

%info=regexp(info,' ','split');

for i=1:length(random_index)
    %Leer la imagen
    if data.features(random_index(i),1)<100000
        img=imread(['0' num2str(data.features(random_index(i),1)) '.jpg']);
    else
        img=imread([num2str(data.features(random_index(i),1)) '.jpg']);
    end
    
    info=regexp(lines{random_index(i)},'>','split');
    
    figure(i)
    %imshow(img), title([info{1} info{2}]);
    imshow(img), title(info{2});
end
        