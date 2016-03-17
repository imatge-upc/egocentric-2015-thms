% %% Segment comparation
% 
main_path=pwd;
fullFolder = '/media/My_Book/Datos_Lifelogging/Narrative/Nick_Florida/Full_folders/52_full';
% 
%% Read Florida segmentation
inputFlorida = '/media/My_Book/Datos_Lifelogging/Narrative/Nick_Florida/52';
floridaSegmentation = dir(inputFlorida); 
floridaSegmentation = floridaSegmentation(arrayfun(@(x) x.name(1) ~= '.' && isdir([inputFlorida '/' x.name]), floridaSegmentation));
%Delete META folder
floridaSegmentation = floridaSegmentation(1:(length(floridaSegmentation)-1));

for ii=1:length(floridaSegmentation)
   subfolderFlorida = [inputFlorida '/' floridaSegmentation(ii).name];
   names = dir(subfolderFlorida); 
   names = names(arrayfun(@(x) x.name(1)~='.', names));
   for ff=1:length(names)
        Florida{ii, ff} =  names(ff).name; %Initial image of a segment.
        if(ff==1)
            Fsegmentation{ii}=names(ff).name;
        end
   end
end

Fsegmentation=sort(Fsegmentation);

%Empty position if short segment


%% Read UB segmentation
file = '/media/HDD_2TB/mcarne/SR-Clustering/Demo/Results/result_52_full_Crop.csv';

text = fileread(file);
text = regexp(text, '\n', 'split');
text = {text{1:end-1}}; %Delete empty cell
segm = {};

for jj=1:length(text)
    segm{jj}=regexp(text{jj}, ',', 'split');
    segm{jj}={segm{jj}{2:end}};%Cal posar les claus!!!
    UBsegmentation{jj}=segm{jj}{1}; %Only the first position
end


%% Charge images in a vector
imagesFiles = dir(fullFolder);
imagesFiles = imagesFiles(arrayfun(@(x) x.name(1) ~= '.' && x.name(1) ~= 'm' , imagesFiles));

cd(fullFolder); 

%imagesFiles(:).name contains the name of the images.

matriz=ones(110,50,3)*255; %Default white, para cada imagen por separado
%Florida segmentation from row 1:30
%image from 31:80
%Ub segmentation from 81:110

%Support images
imgR=zeros(30,50,3);
imgR(:,:,1)=255;
imgR(21:30,:,:)=255;

imgB=zeros(30,50,3);
imgB(:,:,3)=255;
imgB(21:30,:,:)=255;

imgMG=ones(30,50,3)*255;
imgMG(:,:,2)=0;
imgMG(1:10,:,:)=255;

imgG=zeros(30,50,3);
imgG(:,:,2)=255;
imgG(1:10,:,:)=255;

mini_white=ones(20,50,3)*255;

iUB=1;
iF=1;

suportUB=imgR;
suportF=imgMG;

count=1;

numCols=20;
    
for ii=1:length(imagesFiles)
    img = imread(imagesFiles(ii).name);
    img = imresize(img, [50, 50]);
    matriz(31:80,:,:) = img;
    
    if imagesFiles(ii).name==Fsegmentation{iF}
        if iF~=length(Fsegmentation)
            iF=iF+1;
        end
        if suportF==imgMG
            suportF=imgG;
        else
            suportF=imgMG;
        end   
        matriz(1:30,:,:) = suportF; 
    else
        matriz(1:30,:,:) = suportF;
    end
    
    if imagesFiles(ii).name==UBsegmentation{iUB}
        if iUB~=length(UBsegmentation)
            iUB=iUB+1;
        end
        
        if suportUB==imgR
            suportUB=imgB;
        else
            suportUB=imgR;
        end
        matriz(81:110,:,:) = suportUB;
    else
        matriz(81:110,:,:) = suportUB;
    end

    list{count}=matriz;
    count=count+1;        
end

cd(main_path);%Contains the function to concatenate
disp('Generating final plotting...');
    
outImg=concatImages2Dhor('inImgCell',list, 'subVcols', numCols);
imshow(outImg/255);






