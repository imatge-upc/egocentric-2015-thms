
function [top_boxes, cats_ids, top_scores] = prune_boxes(boxes, scores)
max_numcat = 100;
th = tic;
fprintf('Prune boxes...');

% find scores > 0
[ind_c, c] = find(scores > 0);
nz_classes = unique(c);
if length(nz_classes) > max_numcat
    % subsample classes with top max_numcat scores
    t = max(scores(:, nz_classes));
    [~, ord] = sort(t, 'descend');
    nz_classes = nz_classes(ord(1:max_numcat));
end

top_boxes = zeros(50,5); % preallocate some space
cats_ids = zeros(50,1);
top_scores = zeros(50, size(scores,2));
index = 1;
thresh = 0.1; % percat threshold for nms
for i = 1:length(nz_classes)
    ind = c==nz_classes(i);
    sc = scores(ind_c(ind), nz_classes(i));
    scored_boxes = cat(2, boxes(ind_c(ind),:), sc);
    keep = nms(scored_boxes, thresh);
    indices = index:index+length(keep)-1;
    top_boxes(indices,:) = scored_boxes(keep,:);
    cats_ids(indices) = nz_classes(i)*ones(length(keep),1);
    
    index = index + length(keep);
    
    top_scores(indices,nz_classes(i)) = sc(keep);
end
top_boxes = top_boxes(1:index-1,:);
cats_ids = cats_ids(1:index-1);
top_scores = top_scores(1:index-1,:);

%keep = nms(top_boxes,0.4);
%cats_ids = cats_ids(keep);
%top_boxes = top_boxes(keep,:);
%top_scores = top_scores(keep,:);
%ind = find(top_boxes(:,5) >= 1.0);
%
%if length(ind) >= 2
%    top_boxes = top_boxes(ind,:);
%    cats_ids = cats_ids(ind);
%    top_scores = top_scores(ind,:);
%end
%}
fprintf(' done (ind %.3fs)\n', toc(th));
end

function boxes = extract_boxes(im, numbox)
th = tic;
fprintf('Extract boxes...');
fast_mode = true;
im_width = 500;
boxes = selective_search_boxes(im, fast_mode, im_width);
boxes = boxes(:, [2 1 4 3]); %[y1 x1 y2 x2] to [x1 y1 x2 y2]

numbox = min(numbox, size(boxes,1));
boxes = single(boxes(1:numbox,:));
fprintf(' found %d boxes: done (in %.3fs)\n', size(boxes, 1), toc(th));
end
