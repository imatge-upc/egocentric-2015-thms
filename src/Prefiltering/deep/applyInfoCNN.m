function features = applyInfoCNN( img_list, NetCNN_params )

    %% Load data mean
    if(~isnan(NetCNN_params.image_mean))
        load(NetCNN_params.image_mean); % image_mean
        nan_mean = false;
    else
        nan_mean = true;
    end

    %% Initialize caffe
    addpath(NetCNN_params.caffe_path);
    caffe('reset');
    matcaffe_init(NetCNN_params.use_gpu, NetCNN_params.model_def_file, NetCNN_params.trained_net_file);
    
    %% Prepare black margins
    if(NetCNN_params.make_black_margins)
        CNN_input_margin = NetCNN_params.patch_props - NetCNN_params.patch_crops;
        CNN_input_inner = NetCNN_params.patch_props - CNN_input_margin *2;
        background = uint8(zeros(InfoCNN_params.patch_props, InfoCNN_params.patch_props, 3));
        loaded = true;
    else
        loaded = false;
    end
    
    %% Test on images
    nBatch = 0;
    nImages = length(img_list);
    
    % Prepare output
    if(length(NetCNN_params.Noutput) == 1)
        output = zeros(nImages, NetCNN_params.Noutput);
    elseif(length(NetCNN_params.Noutput) == 3)
        output = zeros(NetCNN_params.Noutput(1), NetCNN_params.Noutput(2), NetCNN_params.Noutput(3), nImages);
    end
    
    count_images = 1;
    batch_images = cell(1,NetCNN_params.batch_size);
    [batch_images{:}] = deal(0);
    prev_img = 0;
    for im_i = 1:nImages
        %% Prepare all the images in the current batch
        nBatch = nBatch+1;
        if(NetCNN_params.make_black_margins)
            this_img_mat = imread(img_list{im_i});
            % Set black background to image
            img_with_background = background;
            crop_image = imresize(this_img_mat, [CNN_input_inner CNN_input_inner]);
            img_with_background(CNN_input_margin+1:end-CNN_input_margin, CNN_input_margin+1:end-CNN_input_margin, :) = crop_image;
            batch_images{nBatch} = img_with_background;
        else
            batch_images{nBatch} = img_list{im_i};
        end
        
        if(nBatch == NetCNN_params.batch_size || count_images+nBatch-1 == nImages)
            %% Apply classifier
            disp(['    Evaluating ' num2str(count_images+nBatch-1) '/' num2str(nImages)]);
            if(~nan_mean)
                images = {prepare_batch2(batch_images, loaded, NetCNN_params.parallel, image_mean, NetCNN_params.batch_size, NetCNN_params.patch_props)};
            else
                images = {prepare_batch2(batch_images, loaded, NetCNN_params.parallel)};
            end
            scores = caffe('forward', images);
            scores = squeeze(scores{1});
            
            % For feature extraction of classification
            if(length(size(scores)) == 2)
                scores = scores(:,1:nBatch)';
                output(count_images:count_images+nBatch-1,:) = scores;
            % For image activation extraction
            elseif(length(size(scores)) == 4)
                scores = scores(:,:,:,1:nBatch);
                output(:,:,:,count_images:count_images+nBatch-1) = scores;
            end
            
            count_images = count_images+nBatch;
            
            nBatch = 0;
            batch_images = cell(1,NetCNN_params.batch_size);
            [batch_images{:}] = deal(0);
        end
    end
    
    features=zeros(size(output,1),size(output,2)+1);
    features(:,2:end)=output;
%     features(:,1)= names;

    %Close the network
    caffe('reset');
    
end

