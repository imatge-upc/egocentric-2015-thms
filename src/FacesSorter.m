classdef FacesSorter < matlab.System
    
    % http://www.ics.uci.edu/~xzhu/face/
    % X. Zhu, D. Ramanan. "Face detection, pose estimation and landmark localization in the wild" Computer Vision and Pattern Recognition (CVPR) Providence, Rhode Island, June 2012. 
    
    properties
        model;
        plt;
        posemap;
        params;
        loadSaveCompute;
        loadSavePath;
    end
    
    properties(Access=public)
    end
    
    methods
        function obj = FacesSorter(params, plt)
            obj.plt = params.plt;
            obj.loadSavePath= params.loadSavePath;
            obj.loadSaveCompute = params.loadSaveCompute;
                
            if isfield(obj.plt, 'auxLog')
                obj.plt.auxLog = [plt.resultsFolder '/' sprintf(obj.plt.auxLog, params.model)];
            end
            
            if obj.loadSaveCompute==2
                mkdir(obj.loadSavePath);
            end
            
            addpath('Faces/wild');
            % compile.m should work for Linux and Mac.
            % To Windows users:
            % If you are using a Windows machine, please use the basic convolution (fconv.cc).
            % This can be done by commenting out line 13 and uncommenting line 15 in compile.m
            % compile;
            
            % load model
            % Pre-trained model with 146 parts. Works best for faces larger than 80*80
            if strcmp(params.model,'model1')
                load face_p146_small.mat
            end
            % % Pre-trained model with 99 parts. Works best for faces larger than 150*150
            if strcmp(params.model,'model2')
                load face_p99.mat
            end
            % % Pre-trained model with 1050 parts. Give best performance on localization, but very slow
            if strcmp(params.model,'model3')
            	load multipie_independent.mat
            end
            % Display model
            if isfield(params, 'dispModel') && params.dispModel
                disp('Model visualization');
                visualizemodel(model,1:13);
            end
            
            % 5 levels for each octave
            model.interval = 5;
            % set up the threshold
            model.thresh = min(params.thresh, model.thresh);
            
            % define the mapping from view-specific mixture id to viewpoint
            if length(model.components)==13
                posemap = 90:-15:-90;
            elseif length(model.components)==18
                posemap = [90:-15:15 0 0 0 0 0 0 -15:-15:-90];
            else
                error('Can not recognize this model');
            end

            obj.model = model;
            obj.posemap = posemap;
            
        end
        
        function compute(~,~)
        end
        
        function sortedList = sort(self,event)
            if self.loadSaveCompute~=1
                for i = 1 : numel(event)
                    % Detect faces
                    image= event(i).getImage();
                    bs = detect(image, self.model, self.model.thresh);
                    bs = clipboxes(image, bs);
                    bs = nms_face(bs,0.3);

                     if numel(bs)>0

                        % Compute bounding box and pose && data in arrays
                        bs = repairboxes(bs, self.posemap);
                        boxes = reshape([bs(:).box],[numel(bs),4]); %revisar esta linea. boxes deben ser en formato Xmin,Ymin,Xmax,Ymax
                        pose = [bs.pose];
                        ls = [bs.s];

                        % Weigth
                        event(i).weight = sum(exp([bs.s])); % Sum square confidences

                     else
                        event(i).weight = -inf;
                        boxes = [];
                        pose = -inf;
                        ls = -99;
                     end

    %                 %plot
                    event(i).setAux(writeOnImageHandler(event(i), 'rectangle', boxes, ls,  self.plt.imres, self.plt.textPos, sprintf('%g',  event(i).weight) ));



                    auxInf = [sprintf('ev: %g \t| frame: %g \t|  faces: %g \t| weight: %g \t|  pose: [', event(i).eventid, event(i).index, numel(bs), event(i).weight) sprintf('%g ', pose) sprintf('] \t| conf: [') sprintf('%g ', ls) sprintf('] \n')]; 

                    % Store found bboxes in frame
                    event(i).faces_bboxes = boxes;
                    event(i).faces_poses = pose;

                    if isfield(self.plt, 'debug')&& self.plt.debug
                       fprintf(auxInf);
                    end
                    if isfield(self.plt, 'auxLog')
                        fid = fopen(self.plt.auxLog,'a');
                        fprintf(fid, auxInf);
                        fclose(fid);
                    end
                end
                
                % Sort images by weight
                [~,indexSortedList]=sort([event.weight], 'descend');
            
            
                if self.loadSaveCompute
                    save ([self.loadSavePath num2str(event(1).eventid) '.mat'], 'indexSortedList');
                end
            else
                T = load([self.loadSavePath num2str(event(1).eventid) '.mat']);
                indexSortedList = T.indexSortedList;
            end
            
            sortedList = event(indexSortedList);
        end
    end
end