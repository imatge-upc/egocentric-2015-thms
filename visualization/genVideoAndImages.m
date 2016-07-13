clear all;
clc;

%percentage_size = 0.5; % 0.25

main_path=pwd;


%to_remove = [1 4 7 8 11 12 17 23 24 25 27 36 38 39 44 45 46 51 54 58 61 64 69 70 71 77 82 84];
to_remove = [];
%im_props = [320 580];
im_props = [700 580];

for dd=[25]
    day=num2str(dd);

    source_image = ['/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente2/11/' day '_Crop'];
    source_keyframe = ['/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente2/result_keyframe/' day '_Crop_hort']
    
    output = [source_keyframe];
    output_images = [output '/Day_' day '_images']; 

    %num_segments = 36;

    dir_list = dir(source_keyframe);
    dir_list = dir_list(arrayfun(@(x) x.name(1) ~= '.' && isdir([source_keyframe '/' x.name]), dir_list));
    num_segments = length(dir_list);

    mkdir(output_images);

    cd(source_image);

    count=1;

    outputVideo = VideoWriter(fullfile(output,['Day_' day '.avi']));
    outputVideo.FrameRate = 0.4; %frame per second (0.75 first idea) (0.4 = 2.5s per image second idea)
    open(outputVideo)

    disp(['Writting... DAY: ' day]);

    %fileID = fopen([source_keyframe '/keyframes.txt'],'w');

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

                name=regexp(lines{l},': ','split');
                name_= name{2}(1:(end-1));
                
                if str2num(name_)<100000
                    %name_=['0' name_];
		    name_ = name_;
                end
                
                image_name = [name_ '.jpg'];%Name of the image to add to the video
                %fprintf(fileID,image_name);

                img = imread (image_name);
                
                % Prepare image for video
                 if count==1
%                    imSize=size(img);
%                    imSize=imSize * percentage_size;
		     imSize = im_props;
                 end
                 
                 if(sum(count == to_remove))
                    count = count+1;
                    continue
                end

		% Write image to images folder
		imwrite(img, sprintf([output_images '/%0.5d.jpg'], count));
		count = count+1;

                imgAux = imresize(img,[imSize(1),imSize(2)]); %all the images will be resized to the first image size
                writeVideo(outputVideo,imgAux)
            end

        end

    end

    close(outputVideo)
end

% fclose(fileID);

cd(main_path);

disp(['Generating final VIDEO DAY ' day '...']);
    
