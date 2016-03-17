function featuresWithName = extractLSDAFeatures(path,outpath, met)
startup;

	
images = dir(strcat(path,'/*.jpg'));
features = zeros(length(images), 7604);

fid = fopen([outpath '/objectsLSDA.txt'], 'w');
%% For each image in this folder
count_im = 1;

names = {images(:).name};

nImages = length(images);
for k = 1:nImages
    im = names{k};
    I = imread(strcat(path,'/',im));
    
    [boxes, scores] = lsda(rcnn_model, rcnn_feat, I);
	switch met
		case 'max'
			vec = max(scores);
			vec(vec<0) = 0;
		case 'mean'
			vec = mean(scores);
		case 'filter'
            [~, ~, top_scores] = prune_boxes(boxes, scores);
            % nms
			vec = sum(top_scores,1);
			if size(vec,2) ~= 7604
				vec = zeros(1,7604);
			end
		otherwise
			error('method incorrect');
		end;
    [~,ind] = sort(vec, 'descend');
    top10 = rcnn_model.classes(ind(1:10));
    features(k, :) = vec;
    
    fprintf(fid, '%s >', im);
    for i = 1:numel(top10), fprintf(fid, '%s\t', top10{i}); end;
    fprintf(fid, '\n');
    

    
    % Count progress
    if(mod(count_im, 50) == 0 || count_im == nImages)
        disp(['Processed ' num2str(count_im) '/' num2str(nImages) ' images.']);
    end
    count_im = count_im +1;
end

fclose(fid);
featuresWithName=zeros(size(features,1),size(features,2)+1);
featuresWithName(:,2:end)=features;
featuresWithName(:,1)= names;


    