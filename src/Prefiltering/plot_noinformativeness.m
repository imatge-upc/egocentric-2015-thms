figure;

cd('/media/HDD_2TB/mcarne/keyframe-extractor/db/Estefania1');

for i=1:49
    img=imread([num2str(noinfo_sort(i,1)) '.jpg']);
    subplot(7,7,i),imshow(img);
end

    