function out_name = genVideoAndImages_fun(source_image, source_keyframe, output_folder, day_name)

    to_remove = [];
    im_props = [700 580];

    day=day_name;

    output = output_folder;
    output_images = [output '/Day_' day '_images']; 

    %num_segments = 36;

    dir_list = dir(source_keyframe);
    dir_list = dir_list(arrayfun(@(x) x.name(1) ~= '.' && isdir([source_keyframe '/' x.name]), dir_list));
    num_segments = length(dir_list);

    mkdir(output_images);

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

                img = imread ([source_image '/' image_name]);
                
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

    out_name = ['Day_' day '.avi'];

disp(['Generating final VIDEO DAY ' day '...']);

end    
