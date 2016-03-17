
function features=extractCNNFeatures(path,outpath,gpu, caffemodel, prototxt)
%This function uses the ConvolutionalNN provided by Caffe to extract features for the given set of images.
%Input:
%   path: string containing the path of the images set to analize.
%Output:
%   features: matrix containing the features vectors of the images of the
%   specific path.
path = [pwd '/' path];
size_features = 2;
%size_features=1000;

%% Go through each folder

images = dir(strcat(path,'/*.jpg'));
features = zeros(length(images), size_features);
%% For each image in this folder
count_im = 1;

names = {images(:).name};

nImages = length(images);

% for i = 0:batch_size:nImages
%         this_batch = i+1:min(i+batch_size,  nImages);
%         im_list = cell(1,batch_size);
%         [im_list{:}] = deal(0);
%         count = 1;
%         for j = this_batch
%             im_list{count} = [folder '/' names{j}];
%             count = count+1;
%         end
%         images = {prepare_batch2(im_list, false, CNN_params.parallel, CNN_params.mean_file)};
%         scores = caffe('forward', images);
%         scores = squeeze(scores{1});
%         features(this_batch, :) = scores(:,1:length(this_batch))';
% end
    
for k = 1:nImages
    im = names{k};
    im = imread(strcat(path,'/',im));
    %[scores, ~] = matcaffe_demo(im, gpu, caffemodel, prototxt);
    
    %Prepare image
    input_data=prepare_image(im);
    %Path to caffe
    caffe_path = '/usr/local/caffe-master2/matlab/caffe';
    %wd = pwd;
    cd (caffe_path);
  
    matcaffe_init(gpu,prototxt,caffemodel);
    %scores = caffe('forward', images);
    scores=caffe('forward', input_data(:,:,:,1));
    
    features(k, :) = scores;
    % Count progress
    if(mod(count_im, 50) == 0 || count_im == nImages)
        disp(['Processed ' num2str(count_im) '/' num2str(nImages) ' images.']);
    end
    count_im = count_im +1;
end


end
