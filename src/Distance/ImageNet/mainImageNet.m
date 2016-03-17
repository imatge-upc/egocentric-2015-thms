% better launch in gpu:
% srun-matlab --gres=gpu:1 -J deepmemory -l ~/logs/cnn.mlog mainImageNet > ~/logs/cnn.log 2>&1 &
gpu = 1; % In case that there is not GPU, change the 1 to 0.

folder='137_full_Crop';

data_path = ['../../../db/' folder];
outpath = ['../../../precomputed/' folder '/ImageNet'];
mkdir(outpath);
extractCNNFeatures(data_path,outpath, gpu); 
load([outpath '/ImageNetfeatures.mat']);
[features]=extractNF(data_path,features);
save([outpath '/ImageNetfeatures_n.mat'], 'features');
fprintf('done!');
