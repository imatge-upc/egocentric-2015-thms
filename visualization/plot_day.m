%% FULL DISPLAYED DAY

clear all;
clc;

main_path=pwd;

%source_image = '/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente1/Life-logging/2015/10/22_Crop2';
%source_keyframe = '/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente1/Life-logging/result_keyframe/22_Crop2';
%num_segments = 25;

source_image = '/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente1/Life-logging/2015/10/31_Crop2';
source_keyframe = '/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente1/Life-logging/result_keyframe/31_Crop2';
num_segments = 12;

%source_image = '/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente2/11/26_Crop';
%source_keyframe = '/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente2/result_keyframe/26_Crop';
%num_segments = 27;

output = source_keyframe;

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
            
            if (l == nLines && str2num(file_name) >= 120000) && saltm==0
                len=length(list);
                rest=mod(len, columns_mosaic);
                if(rest > 0)
                    blank_spaces = columns_mosaic-rest+columns_mosaic;
                else
                    blank_spaces = columns_mosaic;
                end
                for jj=1:(blank_spaces)
                    list{count} = red_image;
                    count=count+1;
                end 
                saltm=1;
            end
            
            if (l == nLines && str2num(file_name) >= 160000) && saltt==0
                len=length(list);
                rest=mod(len, columns_mosaic);
                if(rest > 0)
                    blank_spaces = columns_mosaic-rest+columns_mosaic;
                else
                    blank_spaces = columns_mosaic;
                end
                for jj=1:(blank_spaces)
                    list{count} = red_image;
                    count=count+1;
                end 
                saltt=1;
            end
            
            if (l == nLines && str2num(file_name) >= 200000) && saltn==0
                len=length(list);
                rest=mod(len, columns_mosaic);
                if(rest > 0)
                    blank_spaces = columns_mosaic-rest+columns_mosaic;
                else
                    blank_spaces = columns_mosaic;
                end
                for jj=1:(blank_spaces)
                    list{count} = red_image;
                    count=count+1;
                end 
                saltn=1;
            end

            file_name='';
        end
        %list{count} = red_image;
        %count=count+1;

	% Fill space to the right for having a row per segment
	len=length(list);
        rest=mod(len, columns_mosaic);
	if(rest > 0)
            for jj=1:(columns_mosaic-rest)
                list{count} = red_image;
                count=count+1;
            end
	end
    end
end

cd(main_path);

disp('Generating final plot...');
    
outImg=concatImages2Dhor('inImgCell',list, 'subVcols', columns_mosaic);
%imshow(outImg);
imwrite( outImg, [output '/mosaic.jpg']);

disp('Done');
