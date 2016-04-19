%% FULL DISPLAYED DAY

clear all;
clc;

main_path=pwd;

source_image =                  '/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente1/Life-logging/2015/10/31_Crop2';
source_keyframe =                 '/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente1/Life-logging/result_keyframe/31_Crop2';


output = source_keyframe;

num_segments = 12;
columns_mosaic = 10;

saltm=0;
saltt=0;
saltn=0;

red_image = zeros(1000,1000,3);
red_image(:,:,:)=255;

cd(source_image);

count=1;

disp('Plotting...');

for ii=1:num_segments
    disp(['Segment: ' num2str(ii)]);
    
    file_keyframe = [source_keyframe '/Segment_' num2str(ii) '/results/ImageNetNoDvAverage/results_selected.txt'];
    if exist(file_keyframe)
        text = fileread(file_keyframe);
        lines = regexp(text, '\n', 'split');

        if(isempty(lines{end}))
            lines = {lines{1:end-1}};
        end

        nLines = length(lines);

        for l = 1:nLines
            elements = regexp(lines{l}, ': ', 'split');

            name = elements{2};
            for j=1:(length(name)-1)
                file_name(j)= name(j);
            end

            if str2num(file_name) < 100000
                %file_name=['0' file_name];
		file_name = file_name;
            end

            path_image = [file_name '.jpg'];

            image = imread(path_image);
            image = imresize(image, [1000 1000]);
            list{count} =  image;
            count=count+1;
            
            if (str2num(file_name) >= 120000) && saltm==0
                len=length(list);
                rest=mod(len, columns_mosaic);
                for jj=1:(columns_mosaic-rest+columns_mosaic)
                    list{count} = red_image;
                    count=count+1;
                end 
                saltm=1;
            end
            
            if (str2num(file_name) >= 160000) && saltt==0
                len=length(list);
                rest=mod(len, columns_mosaic);
                for jj=1:(columns_mosaic-rest+columns_mosaic)
                    list{count} = red_image;
                    count=count+1;
                end 
                saltt=1;
            end
            
            if (str2num(file_name) >= 200000) && saltn==0
                len=length(list);
                rest=mod(len, columns_mosaic);
                for jj=1:(columns_mosaic-rest+columns_mosaic)
                    list{count} = red_image;
                    count=count+1;
                end 
                saltn=1;
            end

            file_name='';
        end
        %list{count} = red_image;
        %count=count+1;
    end
end

cd(main_path);

disp('Generating final plot...');
    
outImg=concatImages2Dhor('inImgCell',list, 'subVcols', columns_mosaic);
%imshow(outImg);
imwrite( outImg, [output '/mosaic.jpg']);

disp('Done');
