%% FULL DISPLAYED DAY

clear all;
clc;

main_path=pwd;

source_keyframe = '/media/HDD_2TB/mcarne/keyframe-extractor/Florida/52_th03';
%source_image = '/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente1/Life-logging/Segmentation/21_Crop2';
source_image = '/media/My_Book/Datos_Lifelogging/Narrative/Nick_Florida/Full_folders/52_full_Crop';
num_segments = 16;
columns_mosaic = 10;

red_image = zeros(1000,1000,3);
red_image(:,:,:)=255;

red_image_half=zeros(100,1000,3);
red_image_half=255;


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

        %Know rest frames for center
        center=mod(nLines, columns_mosaic);
        
        if center<columns_mosaic && nLines<columns_mosaic
            blank_squares=floor((columns_mosaic-nLines)/2);
            
            for jj=1:blank_squares
                list{count} = red_image;
                count=count+1;
            end
            
            for l = 1:nLines
                elements = regexp(lines{l}, ': ', 'split');

                name = elements{2};
                for j=1:(length(name)-1)
                    file_name(j)= name(j);
                end

        
                if str2num(file_name) < 100000
                    file_name=['0' file_name];
                end

                path_image = [file_name '.jpg'];

                image = imread(path_image);
                image = imresize(image, [1000 1000]);
                list{count} =  image;
                count=count+1;
                
                file_name='';
            end
            
            more_squares=length(list);
            rest=mod(more_squares, columns_mosaic);
            for nn=1:(columns_mosaic-rest+columns_mosaic)
                list{count} = red_image;
                count=count+1;
            end 

            file_name='';
        else
            %Each line is an image
            for l = 1:(nLines-center)
                elements = regexp(lines{l}, ': ', 'split');

                name = elements{2};
                for j=1:(length(name)-1)
                    file_name(j)= name(j);
                end


                if str2num(file_name) < 100000
                    file_name=['0' file_name];
                end

                path_image = [file_name '.jpg'];

                image = imread(path_image);
                image = imresize(image, [1000 1000]);
                list{count} =  image;
                count=count+1;
                
                file_name='';
            end

            blank_squares=floor((columns_mosaic-center)/2);

            for jj=1:blank_squares
                list{count} = red_image;
                count=count+1;
            end

            for mm=(nLines-center+1):nLines
                elements = regexp(lines{l}, ': ', 'split');

                name = elements{2};
                for j=1:(length(name)-1)
                    file_name(j)= name(j);
                end


                if str2num(file_name) < 100000
                    file_name=['0' file_name];
                end

                path_image = [file_name '.jpg'];

                image = imread(path_image);
                image = imresize(image, [1000 1000]);
                list{count} =  image;
                count=count+1;
                
                file_name='';
            end

            more_squares=length(list);
            rest=mod(more_squares, columns_mosaic);
            for nn=1:(columns_mosaic-rest+columns_mosaic)
                        list{count} = red_image;
                        count=count+1;
            end 

                %file_name='';
            %list{count} = red_image;
            %count=count+1;
        end
    end
end

cd(main_path);

disp('Generating final plotting...');
    
outImg=concatImages2Dhor('inImgCell',list, 'subVcols', columns_mosaic);
imshow(outImg);
%imwrite( outImg, [self.resultsFolder '/' fname]);
