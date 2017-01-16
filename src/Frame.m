classdef Frame < handle
 
    properties(Access=private)
        
        aux;
    end
    properties(Access=public)
        index;
        indexInEvent;
        weight = -1;
        info;
        auxinfo;
        eventid;
        skiped;
        resize;
        imagePath;
        faces_bboxes;
        faces_poses;
    end
    
    methods
        function obj = Frame(path, file, ext, eventid, indexInEvent, resize)
            if nargin<4 
                eventid = -1;
                indexInEvent = -1;
            end
            obj.index = file;
            obj.indexInEvent = indexInEvent;
%             obj.imagePath= [path '/' sprintf('%06g', file) '.' ext];
            obj.imagePath= [path '/' file '.' ext];
            obj.info = imfinfo(obj.imagePath);
            obj.auxinfo.Height = 0;
            obj.auxinfo.Width =0 ;
            obj.eventid = eventid;
            obj.resize=resize;
            obj.faces_bboxes = [];
            obj.faces_poses = [];
        end
        function image = getImage(self)
            %NEW
            image = imresize(imread(self.imagePath), [self.resize]);
        end
        
        
        function image = getDoubleImage(self)
            %NEW
            image = imresize(double(imread(self.imagePath))/255, [self.resize]);
        end
        
        function image = getAux(self)
            if isa(self.aux, 'writeOnImageHandler') && hascv
                image = self.aux.compute();
            else
                image = self.aux;
            end
        end
        
        function setAux(self, image)
            self.aux = image;
            if ~isa(image, 'writeOnImageHandler')
                self.auxinfo.Width = size(image,2);
                self.auxinfo.Height = size(image,1);
            else
                 self.auxinfo.Width = self.info.Width*image.props.scaleRes;
                 self.auxinfo.Height = self.info.Height*image.props.scaleRes;
            end
        end
        function setAuxGT(self)
           self.aux.setGT(); 
        end;
        
        function setSkip(self)
           self.skiped = true; 
        end;
        
        
    end
end