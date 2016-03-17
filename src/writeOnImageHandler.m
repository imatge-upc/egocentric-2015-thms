classdef writeOnImageHandler < handle
    
    properties (Access = public)
       frame;
       props;
    end
    
    methods
        function self = writeOnImageHandler(frame, shape, boxes, labels, scaleRes, mainTextPos, mainText)
            self.frame = frame;
            self.props.shape = shape;
            self.props.boxes = boxes;
            self.props.labels = labels;
            self.props.mainTextPos= mainTextPos;
            self.props.mainText = mainText;
            self.props.scaleRes = scaleRes;
            self.props.gt = false;
        end
        
        function image = compute(self)
            if isa(self.frame, 'Frame')
                im = self.frame.getImage();
            else
                im = self.frame;
            end
            
            if self.props.gt
                image = insertText (imresize(insertObjectAnnotation(im, self.props.shape, self.props.boxes, self.props.labels), self.props.scaleRes),  self.props.mainTextPos, self.props.mainText, 'BoxColor', 'green');
            else
               image = insertText (imresize(insertObjectAnnotation(im, self.props.shape, self.props.boxes, self.props.labels), self.props.scaleRes),  self.props.mainTextPos, self.props.mainText); 
            end
        end
        function setGT(self)
            self.props.gt = true;
        end
    end
end
    
    
    
    
    