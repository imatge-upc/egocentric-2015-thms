classdef DataSetController < matlab.System
    
    properties (Access=private)
        cellEvents;
        listGTEvents;
        autoEventindex;
    end
    properties
        path
        gtPath
        name
        gtSegFile
        gtRelFile
        imgFormat
        getGTimages
        dispEvent;
        numEvents;
        resize
    end
    
    methods
        function obj = DataSetController(parameters)
            obj.path =        parameters.path;
            obj.gtPath =      parameters.gtPath;
            obj.name =        parameters.name;
            obj.gtSegFile =   parameters.gtSegFile;
            obj.gtRelFile =   parameters.gtRelFile;
            obj.imgFormat =   parameters.imgFormat;
            obj.getGTimages = parameters.getGTimages;
            obj.resize=       parameters.resize; %NEW
            
            if isfield(parameters, 'startEvent')
                obj.autoEventindex = parameters.startEvent;
            else
                obj.autoEventindex = 1;
            end
            obj.dispEvent = parameters.dispEvent;
            
            obj.openGTFiles();
            obj.numEvents = numel(obj.cellEvents);
            
            if isfield(parameters, 'endEvent') && parameters.endEvent ~= 0
                obj.numEvents = parameters.endEvent;
            end
            
        end
        
        function [eventFrames, gtEventList] = event(self,eventIndex)
            if nargin<2
                eventIndex = self.autoEventindex;
                self.autoEventindex = self.autoEventindex +1;
            end
            if self.dispEvent
                fprintf('%s >> EVENT: %g \n', self.name, eventIndex);
            end
            %Event Frames
            eventList = self.cellEvents{eventIndex};
            
            for i  = 1 : numel(eventList)
                eventFrames(i) = Frame(self.path, eventList(i), self.imgFormat,eventIndex,i,self.resize);
            end
            
            %GT Event Frames
            %Search relevants in envent
            
%             k = 1;
%             for i = 1: numel(eventList)
%                 for j = 1: numel(self.listGTEvents)
%                     
%                     if (eventList(i) == self.listGTEvents(j))
%                         gtEventList(k) = eventList(i);
%                         %                         gtEventIndex(k) = i;
%                         k = k +1;
%                     end
%                 end
%             end
%             
%             if ~exist('gtEventList')
%                 fprintf('eventList');
%                 eventList'
%                 fprintf('listGTEvents');
%                 self.listGTEvents'
%                 
%                 error('isempty(gtEventList)');
%             end
        end
        
        function eventIndex = eventIndex(self)
            eventIndex = self.autoEventindex -1;
        end
        function bool = eventsEnd(self)
            bool = self.autoEventindex > self.numEvents;
        end
        
    end
    
    methods (Access=private)
        function openGTFiles(self)
            % EXCEL (SEGMENTATION)
            files = dir([self.path '/*.' self.imgFormat]);
            %[self.cellEvents,~,~,~]=analizarExcel_Narrative([self.gtPath '/' self.gtSegFile], files);
            self.cellEvents = analizarCSV_narrative([self.gtPath '/' self.gtSegFile]); 
            % TXT (RELLEVANT)
            if ~strcmp(self.gtRelFile,'');
                fid = fopen([self.gtPath '/' self.gtRelFile], 'r');
                A  = textscan(fid, '%s','Delimiter','\n');
                fclose(fid);
                for i = 1: size(A{1})
                    [~,fname,~]=fileparts(A{1}{i});
                    self.listGTEvents(i) = str2num(fname);
                end
            end
            
            
        end
        
        
        
    end
end