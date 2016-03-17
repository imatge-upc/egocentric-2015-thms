figure;

cd('/media/HDD_2TB/mcarne/keyframe-extractor/db/Estefania1');

d=1;
for i=1:7:25*7
    if noinfo_sort(i,1)>100000
        img=imread([num2str(noinfo_sort(i,1)) '.jpg']);
        subplot(5,5,d),imshow(img);
    else
        img=imread(['0' num2str(noinfo_sort(i,1)) '.jpg']);
        subplot(5,5,d),imshow(img);
    end
    
    d=d+1;
end

    