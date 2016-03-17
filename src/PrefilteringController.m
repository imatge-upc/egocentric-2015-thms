classdef PrefilteringController < matlab.System
    
    properties
    end
    
    properties(Access=public)
        deepthresh;
        deepFeats;
        method;
        InfoCNN_params;
        deepPath;
        deepFile;
        namesImages;
    end
    
    methods
        function obj = PrefilteringController(params)
            addpath('Prefiltering/deep');
            obj.method =  params.method; 
            obj.InfoCNN_params = params.InfoCNN_params;
            obj.deepthresh = params.deepthresh;
            obj.deepPath = params.deepPath;
            obj.deepFile = params.deepFile;
            
        end
        
        function compute(self,event)
            if strcmp(self.method, 'deep')
                if (~exist([self.deepPath '/' self.deepFile], 'file'))
                    addpath('Prefiltering/deep')
                    mkdir(self.deepPath);
                    
                    %caffe('reset');
%                     features = applyInfoCNN({event.imagePath}, [event.index] , self.InfoCNN_params);
                    features = applyInfoCNN({event.imagePath} , self.InfoCNN_params);
                    names = {event.index};
                    T.features = features;
                    T.names = names;
                    save([self.deepPath '/' self.deepFile], 'T');
                    self.deepFeats = features;
                    self.namesImages = names;
                else
                    load([self.deepPath '/' self.deepFile]); % loads T
                    self.deepFeats = T.features;
                    self.namesImages = T.names;
                end
                
            end
            
        end
        
        function [skipEvents, selectedEvents] = filter(self,event)
           if strcmp(self.method, 'deep')
                skip = zeros(numel(event),1);
                for i = 1 : numel(event)
%                     ife = self.deepFeats(:,1) == event(i).index;
                    ife = ismember(self.namesImages, event(i).index);
                    ni =  self.deepFeats(ife,2); 
                    if(ni > self.deepthresh)
                        %disp([num2str(i+1) ' > ' num2str(event(i).index) '  informative:' num2str(1-ni) ]);
                        skip(i) = 1;
                        event(i).setSkip;
                    end
                end
                
                skipEvents = self.put(event, skip);
                selectedEvents = self.put(event, ~skip);
 
            else
                skipEvents = [];
                selectedEvents = event;
            end
        end
        
        function out = put(~, in , index)
            
            if sum(index)>0
                out = in(logical(index));
            else
                out = [];
            end
        end
        
    end
end
