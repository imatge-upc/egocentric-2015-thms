function out_name = genVideoAndImages_fun(source_image, source_keyframe, output_folder, day_name, music_path, to_remove)

    seconds_per_image = 2.5; %frame per second (0.75 first idea) (0.4 = 2.5s per image second idea)

    if nargin < 5
        music_path = '';
    end
    if nargin < 6
        to_remove = [];
    end
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

    % Read music file if any
    if ~isempty(music_path)
        [audio_data, sampling_rate] = audioread(music_path);
        outputVideo = vision.VideoFileWriter(fullfile(output,['Day_' day '.avi']), 'AudioInputPort', true);
        % length of the audio to be put per frame
        %val_audio = size(audio_data,1)/nFrames;
    else
        outputVideo = vision.VideoFileWriter(fullfile(output,['Day_' day '.avi']));
    end
    % Applicable for vision.VideoFileWriter (with audio)
    outputVideo.Quality = 10; % 0-100 range
    outputVideo.FrameRate = 2;
    sampling_rate = round(sampling_rate/outputVideo.FrameRate);
    times_repeat_imgs = round(outputVideo.FrameRate*seconds_per_image);

    % Applicable for VideoWriter (without audio only)
    %outputVideo.FrameRate = 1/seconds_per_image;
    %open(outputVideo)


    disp(['Writting... DAY: ' day]);
    count_audio = 1;

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

                imgAux = imresize(img,[imSize(1),imSize(2)]); %all the images will be resized to the first image size
                %writeVideo(outputVideo,imgAux)
                for rep_i = 1:times_repeat_imgs
                    if ~isempty(music_path)
                        step(outputVideo, (imgAux), audio_data(sampling_rate*(count_audio-1)+1:sampling_rate*count_audio,:));
                    else
                        step(outputVideo, (imgAux));
                    end
                count_audio = count_audio+1;
                end

                count = count+1;
            end

        end

    end


    release(outputVideo)
    %close(outputVideo)

    %% Video compression
    disp('---------- Compressing video and converting to .mp4 ------------');
    status = system(['ffmpeg -i ' fullfile(output,['Day_' day '.avi']) ' ' fullfile(output,['Day_' day '.mp4'])]);
    delete(fullfile(output,['Day_' day '.avi']));    

    out_name = ['Day_' day '.mp4'];

disp(['Generating final VIDEO DAY ' day '...']);

end    
