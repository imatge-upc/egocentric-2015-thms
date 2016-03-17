classdef DiversityController < matlab.System
    
    properties(Access=private)
        dists;
        pondArray;
        maxSelected;
    end
    
    properties(Access=public)
        method;
    end
    
    methods
        function obj= DiversityController(params, dists)
            obj.method = params.method;
            obj.dists = dists;
            obj.pondArray = params.pondArray;
            obj.maxSelected = params.maxSelected;
            if ~isfield(params, 'pondArray')
                obj.pondArray = 1/numel(dists);
            elseif sum(obj.pondArray) ~=1
                error('Ponderation values (pondArray) must sum 1');
            end
            
            if numel(params.pondArray) ~= numel(dists)
                error('There should be as many Ponderation values (pondArray) as distances (dists)');
            end
            
        end
        
        function sortedList = diverse(self,sortedList)
            if strcmp(self.method, 'RSD') || strcmp(self.method, 'RSDF') % RSD or RSDF : Reranking by soft diversity [Fusion]
                sortedList=self.scoreDiverse(sortedList);
            elseif strcmp(self.method, 'skip')
            else
                error('Diversity method incorrect');
            end
        end
    end
    methods (Access=private)
        
        function diverseList = scoreDiverse(self, sortedList)
            nf = numel(sortedList);
            
            nf_tmp = nf;
            
            for k = 1 : nf;
                % Take top element
                diverseList(k) = sortedList(1);
                
                % Reduce list
                sortedList = sortedList(2:end);
                nf_tmp = nf_tmp-1;
                
                % Get sores for relevance (0 best, 1 worse)
                scores = 1-(1: nf_tmp)/(nf_tmp);
                
                % update scores penalizing diversity
                for i = 1: nf_tmp
                    % Max distance of selected
                    if self.maxSelected
                        mx = 0;
                        for s = 1: numel(diverseList)
                            d = self.distance(diverseList(s), sortedList(i));
                            if d>mx
                                mx = d;
                            end
                        end
                        dis = mx;
                    else
                      % Distance at step
                    dis = self.distance(diverseList(k), sortedList(i));
                    end
                    scores(i) = scores(i) - dis;
                end
                
                % Update sortedList;
                [~,ind] = sort(scores,'descend');
                sortedList = sortedList(ind);
            end
            
            
        end
        
        function dist = distance(self, f1, f2)
            if strcmp(self.method, 'RSD') % Reranking by Soft Diversity
                dist = self.dists{1}.distance(f1,f2);
            elseif strcmp(self.method, 'RSDF') % Reranking by Soft Diversity  Fusion
                dist = 0;
                for m = 1 : numel(self.dists)
                    dist = dist +  self.pondArray(m) * self.dists{m}.distance(f1,f2);
                end
            else
                error('Late or Early must be specified in SDR method');
            end
            
        end
    end
end