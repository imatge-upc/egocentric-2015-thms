global CAFFE_PATH;
global CAFFE_PATH_OLD;
global USE_GPU;
CAFFE_PATH_OLD =                '/usr/local/caffe-dev/matlab/caffe';
CAFFE_PATH =                    '/usr/local/caffe-master2/matlab/caffe';
USE_GPU =                       1;

%input_folder =                  '/media/HDD_2TB/mcarne/keyframe-extractor/db/prova';
input_folder =                  '/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente1/Life-logging/Segmentation/22_Crop2';
output_folder =                 '/media/HDD_2TB/mcarne/keyframe-extractor/paciente/22_perform_03';
number_segments =               25;

dbp.imgFolder =                 input_folder;
dbp.imgFormat =                 'jpg';                                     % Extention of images. jpg | png
dbp.resize =                    [490 472];

pltp.PercentageImagesShown =    10;                                        %Percentatge de fotos ordenades per temps a mostrar.
pltp.skipPlot =                 false;                                     % Skip writting results
pltp.resultsFolder =            [output_folder '/results/'];                 % Results folder
pltp.expName =                  'ImageNetNoDvAverage';                     % Experiment name, empty for date
pltp.mosaic.cols =              3;


pfp.method =                    'deep';                                    % Prefiltering Method [deep | skip];
%pfp.deepthresh = 				0.999			   % Deep. Threshold for informativeness
%pfp.deepthresh = 				0.3;
pfp.deepthresh =				0.95;  % better threshold w.r.t. Precision-Recall curve
pfp.deepPath = 					[output_folder '/computed/informative'];    % Deep. Path for informativeness features
pfp.deepFile = 					'prefiltering_n.mat';				       % Deep. File for informativeness features
pfp.InfoCNN_params.caffe_path =     CAFFE_PATH;
pfp.InfoCNN_params.use_gpu =        USE_GPU;
pfp.InfoCNN_params.model_def_file = '/media/HDD_2TB/mcarne/keyframe-extractor/src/Prefiltering/deep/train_val_finetunning_test2.prototxt';
pfp.InfoCNN_params.trained_net_file = '/media/HDD_2TB/CNN_MODELS/InformativeCNN/informativeDetectCNN_finetunning_Petia2_iter_18000.caffemodel';
pfp.InfoCNN_params.image_mean = NaN;
pfp.InfoCNN_params.batch_size = 50;
pfp.InfoCNN_params.parallel = false; % use parallel computation or not
pfp.InfoCNN_params.patch_props = 256;
pfp.InfoCNN_params.patch_crops = 227;
pfp.InfoCNN_params.make_black_margins = false;
pfp.InfoCNN_params.Noutput = 2;
pfp.InfoCNN_params.outputfilename = 'infoCNN_outputClasses.mat';


dsp.loadSaveCompute =           2;                                         % Precompute distance matrices, [ 1 | 2 | 3 ] Load, Save, Compute
dsp.FeatsPath =                 [output_folder '/computed/similarity'];    % Path of features {except Feature = pixel} << Allows $DSETNAME >>
dsp.FeatsFile =                 '%sfeatures_n.mat';                        % Filename of features {except Feature = pixel}
dsp.preComputePath =            '';                                        % Path to load/save Distances Matrix. Commented or empty will use FeatsPath. << Allows $DSETNAME >>
dsp.caffe_path =                CAFFE_PATH;
dsp.use_gpu =                   USE_GPU;
dsp.model_def_file =            '/media/HDD_2TB/mcarne/keyframe-extractor/src/Distance/ImageNet/deploy_features.prototxt';
dsp.model_file =                '/media/HDD_2TB/mcarne/keyframe-extractor/src/Distance/ImageNet/caffe_reference_imagenet_model';

%methods =                       {'saliency', 'objectsLSDA','faces'};                   % Cell of methods {'method1','method2',...}
methods =                       {'objectsLSDA','faces'};                                                                           % random | saliency | faces | objects | affective


fsp.method =                    'pondsum index';                           % Method used in fusion [ random | first | sum | pondsum  {score | rank}]
%fsp.pondArray =                 [0.33333,0.33333, 0.33334];                                 % Ponderation for each method {method = pondsum [..]}
fsp.pondArray =                 [0.5, 0.5];

distances =                     {'ImageNet'};                              % Cell of distances {'distance1', 'distance2', ...}
                                                                           % pixel, ImageNet, LSDA, Places

dvp.method =                    'skip';                                     % Method used when applying diversity [RSD | RSDF | skip]
dvp.pondArray =                 [1];                                       % Ponderation for each distance {method = RSDF}
dvp.maxSelected =               false;                                     % Perform max on already selected (true).

mthdp.random.parameter =        '';                                        % Not used

mthdp.saliency.method = 		'deep';									   % [deep , basic]
mthdp.saliency.deepPath = 		[output_folder '/computed/saliency'];
mthdp.saliency.deepModel =      '/media/HDD_2TB/mcarne/keyframe-extractor/src/Saliency/deep';
mthdp.saliency.caffe_path =     CAFFE_PATH_OLD;
%mthdp.saliency.use_gpu =        USE_GPU;
mthdp.saliency.use_gpu =        0;
mthdp.saliency.gauss =          false;

mthdp.faces.plt.debug =         true;                                      % Display faces steps
mthdp.faces.plt.textPos =       [10,10];                                   % Place to display text in auxiliar mosaic
mthdp.faces.plt.imres =         1/2;                                       % Image resize factor in auxiliar mosaicS
mthdp.faces.plt.auxLog =        'faces_%s_auxiliar.log';                   % Auxiliar faces log
mthdp.faces.model =             'model1';                                  % Pre-trained faces model [model1 | model2 | model3]
mthdp.faces.thresh =            -1;                                        % Threshold SVM
mthdp.faces.loadSaveCompute =   2;
mthdp.faces.loadSavePath =      [output_folder '/computed/faces'];


mthdp.objects.method =          'fast';                                    % Object Candidates method [fast | accurate] (UCM, MCG respectivelly)
mthdp.objects.plt.auxLog =      'objects_%s_auxiliar.log';                 % Auxiliar objects log
mthdp.objects.plt.debug =        true;                                     % Display Objects steps
mthdp.objects.plt.textPos =      [10,10];                                  % Place to display text in auxiliar mosaic
mthdp.objects.plt.imres =        1/2;                                      % Image resize factor in auxiliar mosaic
mthdp.objects.numObj =           5;                                        % Number of objecs taken. 0 will take all objects

mthdp.objectsLSDA.numObj =       0;                                        % Number of objecs taken. 0 will take all objects
mthdp.objectsLSDA.deepPath =     [output_folder '/computed/LDSA'];      % Path of features {except Feature = pixel} << Allows $DSETNAME >>
mthdp.objectsLSDA.deepFile =     'LSDAfeatures_n.mat';                   % Filename of features {except Feature = pixel}
mthdp.objectsLSDA.lsda_path =    '/media/HDD_2TB/marc/LSDA/jhoffman-lsda-b54cafd';
mthdp.objectsLSDA.caffe_path = CAFFE_PATH;
mthdp.affective.FeatsPath =    '../precomputed/$DSETNAME/Affective/';      % Path of features {except Feature = pixel} << Allows $DSETNAME >>
mthdp.affective.FeatsFile =    'Affectivefeatures_n.mat';                  % Filename of features {except Feature = pixel}
