%MAinPrefiltering2
clear variables;
addpath('Test_Informative_Detector');

%%

folder='Estefania1';

data_path = ['../../../db/' folder '/'];
outpath = ['../../../precomputed/' folder '/Prefiltering/'];
mkdir(outpath);
loadParameters;
files = dir([data_path '*.jpg']);

%Mcarne added code
s=size(files);
nImages=s(1);
for i=1:nImages
     names{i}=[data_path files(i).name];
end

%D'aquesta manera no tenim el path sencer
%names = {files(:).name};


%images = prepare_batch2([files.name]); %Codi aniol
%Això no s'hauria de fer, es fa dins del applyinfoCNN!
%images = prepare_batch2(names, data_path); %Codi mcarne, s'ha afegit
%data_path
%output = applyInfoCNN(images, InfoCNN_params);
output = applyInfoCNN(names, InfoCNN_params);
[features]=extractNF(data_path,output);
save([outpath '/prefiltering_n.mat'], 'features');
fprintf('done!');
