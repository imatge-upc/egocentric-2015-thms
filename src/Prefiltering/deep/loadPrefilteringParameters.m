
%% Parameters
InfoCNN_params.caffe_path = CAFFE_PATH;
InfoCNN_params.use_gpu = USE_GPU;
InfoCNN_params.model_def_file = '/media/HDD_2TB/mcarne/keyframe-extractor/src/Prefiltering/deep/train_val_finetunning_test2.prototxt';

InfoCNN_params.trained_net_file = '/media/HDD_2TB/mcarne/keyframe-extractor/src/Prefiltering/deep/informativeDetectCNN_finetunning_Petia2_iter_2800.caffemodel';
InfoCNN_params.image_mean = NaN;

% Path to train/val/test files
InfoCNN_params.path_images = data_path;
InfoCNN_params.batch_size = 50;
InfoCNN_params.parallel = true; % use parallel computation or not

InfoCNN_params.patch_props = 256;
InfoCNN_params.patch_crops = 227;
InfoCNN_params.make_black_margins = false;


%% CNN output
InfoCNN_params.Noutput = 2; % 5 for classes and 500 for features. Hi havia 2
%He vist que scores era de 10x1000;
InfoCNN_params.outputfilename = 'infoCNN_outputClasses.mat';


