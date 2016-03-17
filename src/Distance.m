classdef Distance < matlab.System
    
    properties(Access=public)
        feature;
    end
    properties(Access=private)
        disMat;
        iDisMat;
        loadSaveCompute;
        disParams;
        
    end
    
    methods(Access = public)
        function obj = Distance(feature, params)
            obj.loadSaveCompute = params.loadSaveCompute;
            obj.feature = feature;
            
            
            if ~isfield(params, 'preComputePath') || isempty(params.preComputePath)
                params.preComputePath = params.FeatsPath;
            end
            
            obj.disParams = params;
            
            obj.disParams.FeatsPath = sprintf(obj.disParams.FeatsPath, obj.feature);
            obj.disParams.preComputePath = sprintf(obj.disParams.preComputePath, obj.feature);
            obj.disParams.FeatsFile = sprintf(obj.disParams.FeatsFile, obj.feature);
            
        end
        
        function compute(self,event)
            if (~strcmp(self.feature, 'pixel') && ~exist([self.disParams.FeatsPath '/' self.disParams.FeatsFile], 'file'))
                mkdir(self.disParams.FeatsPath);
                addpath('Distance/ImageNet');
                %                     features = applyInfoCNN({event.imagePath}, [event.index] , self.InfoCNN_params);
                size_features = 4096;
                features = zeros(numel(event), size_features+1);
                names = cell(1, numel(event));
                count_im = 1;
                
                nImages = numel(event);
                for k = 1:nImages
                    %caffe('reset');
                    scores = matcaffe_demo(event(k).getDoubleImage(), self.disParams.use_gpu, self.disParams.caffe_path, self.disParams.model_def_file, self.disParams.model_file, k);
                    names{k} = event(k).index; % afegir nom
                    features(k, 2:end) = scores';
                    % Count progress
                    if(mod(count_im, 50) == 0 || count_im == nImages)
                        disp(['Processed ' num2str(count_im) '/' num2str(nImages) ' images.']);
                    end
                    count_im = count_im +1;
                end
                
                addpath (self.disParams.caffe_path);
                caffe('reset');
                rmpath(self.disParams.caffe_path);
                
                T.features = features;
                T.names = names;
                save([self.disParams.FeatsPath '/' self.disParams.FeatsFile], 'T');
            elseif ~strcmp(self.feature, 'pixel')
                load([self.disParams.FeatsPath '/' self.disParams.FeatsFile]); % load T
                features = T.features;
                names = T.names;
            end
            
            
            
            if  ~strcmp(self.feature, 'pixel')&& self.loadSaveCompute ~=1 % save /compute
                self.ALLDistanceMatContruct(features);
            end
            
            
            if ~strcmp(self.feature, 'pixel') && self.loadSaveCompute == 2 % Save
                mkdir(self.disParams.preComputePath);
                disMat = self.disMat;
                iDisMat = self.iDisMat;
                save([self.disParams.preComputePath '/' self.feature '.mat'],'disMat', 'iDisMat');
            elseif ~strcmp(self.feature, 'pixel') && self.loadSaveCompute == 1 %load
                try
                    load([self.disParams.preComputePath '/' self.feature '.mat']);
                catch
                    error('Unable to read file %s. Make sure that loadSaveCompute=2 if the file is not created yet', [self.disParams.preComputePath '/' self.feature '.mat']);
                end
                self.disMat = disMat;
                self.iDisMat = iDisMat;
            end
            
        end
        
        
        
        function DM = distanceMatrix(self, list, gt)
            % Compute distance matrix list vs gt(indexes) in event
            [~,igt] = intersect([list.index], gt);
            DM = zeros(numel(list), numel(gt));
            for l = 1 : numel(list)
                for g = 1: numel(gt)
                    DM(l,g) = self.distance(list(igt(g)), list(l));
                end
            end
        end
        
        function cost = distance(self, f1, f2)
            if strcmp(self.feature, 'pixel')
                im1= f1.getImage();
                im2= f2.getImage();
                [sr,sc] = size(im1);
                cost = 1 - sum(sum(sum(abs(double(im1-im2)/255)))/(sr*sc))/3;
            else
                if1 = self.iDisMat == f1.index;
                if2 = self.iDisMat == f2.index;
                cost = self.disMat(if1,if2);
            end
            
        end
        
    end
    
    methods(Access = private)
        
        function ALLDistanceMatContruct(self, features)
            % Compute distances between all db images.
            fprintf('%s > Computing big similarity matrix...', self.feature);
            mx = 0;
            sf = size(features,1);
            SM = zeros(sf,sf);
            for i = 1 : sf
                for j = 1 : sf
                    err = norm(features(i,2:end)-features(j,2:end));
                    if err>mx
                        mx =err;
                    end
                    SM(i,j) = err;
                end
            end
            self.disMat = 1- SM / mx;
            self.iDisMat = features(:,1);
        end
    end
end