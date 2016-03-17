classdef ObjectCandidatesSorterLSDA < matlab.System
    
    
    properties (Access = private)
        lsdaFeats;
        numObj;
        deepPath;
        deepFile;
        lsda_path;
        caffe_path;
        namesImages;
    end
    
    
    methods
        function obj = ObjectCandidatesSorterLSDA(params)
            obj.numObj = params.numObj;
            obj.deepPath = params.deepPath;
            obj.deepFile = params.deepFile;
            obj.lsda_path = params.lsda_path;
            obj.caffe_path = params.caffe_path;
        end
        
        function compute(self,event)
            if (~exist([self.deepPath '/' self.deepFile], 'file'))
                
                addpath([pwd '/ObjectCandidates/LSDA']);
                addpath(pwd);
                mkdir(self.deepPath);
                mypath = pwd;
                cd(self.lsda_path);
                startup;
                count_im = 1;
                features = zeros (numel(event),7604+1 );
                names = cell(1,numel(event));
                for k = 1: numel(event)
                    [boxes, scores] = lsda(rcnn_model, rcnn_feat, event(k).getDoubleImage());
                    [~, ~, top_scores] = prune_boxes(boxes, scores);
                    vec = sum(top_scores,1);
                    if size(vec,2) ~= 7604
                        vec = zeros(1,7604);
                    end
                    
%                     features(k, 1) = event(k).index;
                    
                    names{k} = event(k).index;
                    features(k, 2:end) = vec;
                    % Count progress
                    if(mod(count_im, 50) == 0 || count_im == numel(event))
                        disp(['Processed ' num2str(count_im) '/' num2str(numel(event)) ' images.']);
                    end
                    count_im = count_im +1;
                    
                end
                
                T.features = features;
                T.names = names;
                save([self.deepPath '/' self.deepFile], 'T');
                self.lsdaFeats = features;
                self.namesImages = names;
                cd(mypath);
            else
                load([self.deepPath '/' self.deepFile]); % load T
                self.lsdaFeats = T.features;
                self.namesImages = T.names;
            end
            %Close the network
            addpath (self.caffe_path);
            caffe('reset');
            rmpath(self.caffe_path);

        end
        
        
        
        
        function sortedList = sort(self,event)
            for i = 1 : numel(event)
%                 ife = self.lsdaFeats(:,1) == event(i).index;
                ife = ismember(self.namesImages, event(i).index);
                fe =  self.lsdaFeats(ife,2:end);
                if self.numObj ~= 0
                    [sfe,~] = sort(fe, 'descend');
                    event(i).weight = sum(sfe(1:self.numObj));
                else
                    fe = fe(fe>0);
                    event(i).weight = sum(fe);
                end
            end
            
            % Sort images by weight
            [~,indexSortedList]=sort([event.weight], 'descend');
            sortedList = event(indexSortedList);
        end
    end
end