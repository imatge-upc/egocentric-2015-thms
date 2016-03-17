classdef FusionController < matlab.System
    
    properties(Access=public)
        map;
        frameList;
        methodIndex;
        nmethods;
        fusionMet;
        pondArray; 
    end
    
    methods
        function obj= FusionController(params, methods)
            obj.nmethods = numel(methods);
            obj.methodIndex = 1;
            obj.fusionMet = params.method;
            obj.pondArray = params.pondArray'; 
            
            if sum(obj.pondArray) ~=1 
			
                error('Ponderation values (pondArray) must sum 1 (%s)', sum(obj.pondArray));
            end
            
            if numel(params.pondArray) ~= numel(methods)
                error('There should be as many Ponderation values (pondArray) as methods');
            end
            
            if obj.nmethods == 1
                obj.fusionMet = 'first';
            end
            
        end
        
        function add(self, sortedList)
            
            [~,ind] = sort([sortedList.indexInEvent]);
            
            if strfind(self.fusionMet, 'score')
                weightsList = [sortedList.weight];
                % Normalize
                weightsList = weightsList - min(weightsList);
                weightsList = weightsList / max(weightsList);
                score = weightsList(ind);
                
            else
                % rank
                score =1 -(ind-1)/(numel(ind)-1);
            end
            
            if (self.methodIndex == 1)
                self.frameList = sortedList(ind);
                self.map = zeros(self.nmethods, numel(sortedList));
            end
            
            self.map(self.methodIndex,:) = score;
            self.methodIndex = self.methodIndex+1;
        end
        
        function sortedList = fusion(self)
            if strfind(self.fusionMet, 'random')
                ind = round(rand(self.nmethods,1)*self.nmethods+1);
                sortedList = self.frameList(ind);
            elseif strfind(self.fusionMet, 'pondsum')
                pond = repmat(self.pondArray, 1, size(self.map,2));
                [~,ind] = sort(sum(self.map.*pond),'descend');
                sortedList = self.frameList(ind);
            elseif strfind(self.fusionMet, 'sum')
                [~,ind] = sort(sum(self.map),'descend');
                sortedList = self.frameList(ind);
            elseif strfind(self.fusionMet,'first')
                [~,ind] = sort(self.map(1,:),'descend');
                sortedList = self.frameList(ind);
            else
                error('Fusion Method invalid');
            end
            
            
            self.next();
        end
        
        function next(self)
            self.methodIndex = 1;
            self.map= cell(self.nmethods,1);
        end
        
    end
end