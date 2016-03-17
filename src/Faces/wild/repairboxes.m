function [boxes]= repairboxes(boxes, posemap)

for k = 1 : numel(boxes)
    box = [min(boxes(k).xy(:,1)), min(boxes(k).xy(:,2)), max(boxes(k).xy(:,3)), max(boxes(k).xy(:,4))];
    boxes(k).box = box;
    boxes(k).pose = posemap(boxes(k).c);
end