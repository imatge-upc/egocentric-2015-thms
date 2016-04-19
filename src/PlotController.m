classdef PlotController < matlab.System
    
    properties(Access=private)
        dsname;
        dsetResultsFolder;
        mets;
    end
    properties(Access=public)
        skipPlot = false;
        mosaic;
        resultsFolder;
        hasDiary=false;
    end
    
    methods
        function obj = PlotController(pltp, mets)
            addpath('Plot');
            obj.mosaic = pltp.mosaic;
            if ~isfield(pltp, 'expName') || strcmp(pltp.expName,'')
                c = clock;
                pltp.expName = sprintf('%d%.2d%0d_%.2d%.2d',c(1:3),c(4:5));
            end
            obj.resultsFolder = [pltp.resultsFolder '/' pltp.expName];
            mkdir(obj.resultsFolder);
            
            if isfield(pltp, 'skipPlot')
                obj.skipPlot = pltp.skipPlot;
            end
            if isfield(pltp, 'logfile')
                logfile = [obj.resultsFolder '/' pltp.logfile];
                diary(logfile);
                obj.hasDiary = true;
            end
            
            obj.mets = mets;
            obj.emptyFile([obj.resultsFolder '/results.txt']);
        end
        
        function updateDataSet(self, dsname)
            self.dsname = dsname;
            self.dsetResultsFolder = [self.resultsFolder '/' dsname];
            
            mkdir([self.dsetResultsFolder '/fusion/']);
            mkdir([self.dsetResultsFolder '/event/']);
            
            for m = 1 : numel(self.mets)
                mkdir([self.dsetResultsFolder '/' self.mets{m} '/a']);
                if ~hascv
                    mkdir ([self.dsetResultsFolder '/' self.mets{m} '/a/afiles']);
                end
            end
            
        end
        %plt.write(fullSortedList, 0, 'fusion', Nimages, 'retail');

        function write(self, sortedList, index, method, Nimages)
            if ~self.skipPlot
                
                self.eventWritter(sortedList, sprintf('%02g_%s.jpg', index, method), Nimages);
                
            end
        end
        
        function saveParameters(self, dbp,pltp,evp,pfp,dsp,dvp,mthdp, methods, distances )
            A = evalc('methods');
            A = [A evalc('distances')];
            A = [A evalc('fn_structdisp(dbp)')];
            A = [A evalc('fn_structdisp(pltp)')];
            A = [A evalc('fn_structdisp(evp)')];
            A = [A evalc('fn_structdisp(pfp)')];
            A = [A evalc('fn_structdisp(dsp)')];
            A = [A evalc('fn_structdisp(dvp)')];
            A = [A evalc('fn_structdisp(mthdp)')];
            
            fid = fopen([self.resultsFolder '/parameters.txt'] ,'w');
            fprintf(fid,'%s',A);
            fclose(fid);
            
        end
        
        function writeResults(self, text, div, method)
            fid = fopen([self.resultsFolder '/results.txt'],'a');
            fprintf(fid,'%s',text);
            if nargin>2
                save(sprintf('%s/reNSMS_%s.mat',self.resultsFolder,method),'div');
            end
            fclose(fid);
        end
        
        function show(self,event)
            fid = fopen([self.resultsFolder '/results.txt'],'w');
            %fprintf(fid, 'image %d: %d \n', [1:numel(event); [event.index]]);
            names = {event.index};
            for ii=1:numel(event)
                fprintf(fid, 'image %d: %s \n', ii, names{ii});
                disp(['Image ' num2str(ii) ': ' num2str(event(ii).index)]);
            end
            fclose(fid);
        end
        
             
        function show_full(self,event)
            fid = fopen([self.resultsFolder '/results_merge.txt'],'w');
            %fprintf(fid, 'image %d: %d \n', [1:numel(event); [event.index]]);
            names = {event.index};
            for ii=1:numel(event)
                fprintf(fid, 'image %d: %s \n', ii, names{ii});
                disp(['Image ' num2str(ii) ': ' num2str(event(ii).index)]);
            end
            fclose(fid);
        end
        
        function close(self)
            legend(gca,'show', 'Location','southeast')
            if self.hasDiary
                diary off;
            end
        end
    end
    
    methods (Access=private)
        function bool = find(~, elem , list)
            for i = 1: numel(list)
                if (elem==list(i))
                    bool = true;
                    return;
                end
            end
            bool= false;
        end
        
        function emptyFile(~,file)
            fclose(fopen(file,'w'));
        end
        
        function eventWritter(self, event, fname, max)
       
                event = event(1:max);
                %Si això no ho faig ho ordena per rellevancies
               
	        % only suitable for Narrative pictures
		if(~isempty(strfind(event(1).index, '_')))
		    version = 2;
		else
		    version = 1;
		end
 
		if(version == 2)
                    for k=1:size(event,2)
                   	vecstr = strsplit(event(k).index,'_');
                   	time(k) = str2double(vecstr(2));
                    end
		else
		    for k=1:size(event,2)
                        time(k) = str2double(event(k).index);
                    end
		end
                [~, ind]=sort(time);
		event = event(ind);
            
                fid = fopen([self.resultsFolder '/results_selected.txt'],'w');
                for k=1:size(event,2)
                    fprintf(fid, 'image %d: %s \n', k, event(k).index);
                end
                fclose(fid);
                
                for i = 1 : max
                    image = event(i).getImage();
                    list{i} =  image;
                end
                
                outImg=concatImages2Dhor('inImgCell',list, 'subVcols', self.mosaic.cols);
                %imshow(outImg);
                imwrite( outImg, [self.resultsFolder '/' fname]);
                
         
        end
    end
end
