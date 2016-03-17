%% Found max score in LDSA results

%File that contains the scores for each class in each image
data=load('/media/HDD_2TB/mcarne/keyframe-extractor/precomputed/Estefania1/LSDA/LSDAfeatures_n.mat');

%Found de max score value
%We consider between the second and the last column because the first
%column correspond to the name of the image that is a number also.
max_value=max(max(data.features(:,2:end)));

[row column]=find(data.features==max_value);

disp(['Max value: ' num2str(max_value) '; row index= ' num2str(row) '; column index= ' num2str(column)]);

image_name=data.features(row,1); %Name (number) of the image

disp(['Image with the higher score (one class only): ' num2str(image_name) '.jpg']);

%Show the image
figure;

cd('/media/HDD_2TB/mcarne/keyframe-extractor/db/Estefania1');

if image_name<100000
    img_score=imread(['0' num2str(image_name) '.jpg']);
else
    img_score=imread([num2str(image_name) '.jpg']);
end

text = fileread('/media/HDD_2TB/mcarne/keyframe-extractor/precomputed/Estefania1/LSDA/objectsLSDA.txt');

lines = regexp(text, '\n', 'split');

disp(lines{row});

imshow(img_score),title('Image with the higher score in one class');