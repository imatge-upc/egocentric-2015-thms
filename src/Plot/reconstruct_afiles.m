function reconstruct_afiles(dir_afiles, dir_mosaics)

if ~hascv
    error('Computer vision toolbox is needed for computing mosaics. Compute them in a matlab with CV toolbox');
end
afiles = dir([ dir_afiles '/*.mat']);

for i =  1: numel(afiles)
    load([dir_afiles '/' afiles(i).name]);
    image = cell(1, numel(list));
    for j = 1: numel(list)
        image{j} = list{j}.compute();
    end;
     outImg=concatImages2D('inImgCell',image, 'subVcols', 6);
     name = afiles(i).name;
     imwrite( outImg, [dir_mosaics '/' name(1:end-3) 'jpg']);
     clear list;
end