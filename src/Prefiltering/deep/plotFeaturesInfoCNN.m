
path_results_file = {'infoCNN_outputClasses_Estefania1.mat', 'infoCNN_outputClasses_Estefania2.mat', ...
    'infoCNN_outputClasses_MAngeles1.mat', 'infoCNN_outputClasses_MAngeles2.mat', ...
    'infoCNN_outputClasses_MAngeles3.mat', 'infoCNN_outputClasses_Mariella.mat', ...
    'infoCNN_outputClasses_Maya1.mat', 'infoCNN_outputClasses_Marc1.mat', ...
    'infoCNN_outputClasses_Petia1.mat', 'infoCNN_outputClasses_Petia2.mat'};

this_path = pwd;
cd ..
loadParameters;

addpath('Evaluation');


%% Read Features
nResultsFiles = length(path_results_file);
res_labels = [];
prob_info = [];
for i = 1:nResultsFiles
    load(path_results_file{i}); % output
    this_res_labels = output;
    this_prob_info = this_res_labels(:,2);
    [~, this_res_labels] = max(this_res_labels, [], 2);
    this_res_labels = this_res_labels-1;
    res_labels = [res_labels; this_res_labels];
    prob_info = [prob_info; this_prob_info];
end

%% Prepare GT
nImages = size(res_labels,1);
labels = zeros(nImages,1);
list_imgs_paths = cell(nImages,1);
offset = 0;
for f = 1:nResultsFiles
%     list_imgs = fileread([pwd '/tmp_labels/' InfoCNN_params.list_folders{f} '/labels.txt']);
    list_imgs = fileread([InfoCNN_params.path_labels '/' InfoCNN_params.list_folders{f} '/labels.txt']);
    list_imgs = regexp(list_imgs, '\n', 'split');
    for i = 1:length(list_imgs)-1
        line = regexp(list_imgs{i}, ' ', 'split');
        labels(i+offset) = str2num(line{2});
        list_imgs_paths{i+offset} = line{1};
    end
    offset = offset+length(list_imgs)-1;
end

classes = unique(labels);
nClasses = length(classes);


%% Evaluate result
[ M_accuracies, M_precisions, M_recalls, accuracy, precision, recall, fmeasure ] = evalSegmentation(labels+1, res_labels+1, classes+1);
Results.Accuracy = accuracy;
Results.Precision = precision;
Results.Recall = recall;
Results.FMeasure = fmeasure;
Results.M_accuracies = M_accuracies';
Results.M_precisions = M_precisions';
Results.M_recalls = M_recalls';

disp('Average measures:');
disp(['Accuracy: ' num2str(Results.Accuracy)]);
disp(['Precision: ' num2str(Results.Precision)]);
disp(['Recall: ' num2str(Results.Recall)]);
disp(['F-Measure: ' num2str(Results.FMeasure)]);

disp(' ');

M_accuracies = [Results.M_accuracies]';
M_precisions = [Results.M_precisions]';
M_recalls = [Results.M_recalls]';

disp('Average measures per class:');
disp('accuracies');
disp(M_accuracies);
disp('precisions');
disp(M_precisions);
disp('recalls');
disp(M_recalls);
disp('classes: ');
disp(classes');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluate result for different thresholds
range = 0:0.01:1;
lenRange = length(range);
precisions = zeros(1, lenRange);
recalls = zeros(1, lenRange);
accuracies = zeros(1, lenRange);
count = 1;
for th = range
    
    prob_info_th = prob_info;
    prob_info_th(prob_info_th < th) = 0;
    prob_info_th(prob_info_th > 0) = 1;
    
    % Evaluate with this threshold
    [ ~, M_precisions, M_recalls, accuracy, ~, ~, ~ ] = evalSegmentation(labels+1, prob_info_th+1, [0 1]+1);
    precisions(count) = M_precisions(2);
    recalls(count) = M_recalls(2);
    accuracies(count) = accuracy;
    
    count = count+1;
end
precisions = [0 precisions 1];
recalls = [1 recalls 0];

% Calculate FMeasure
fmeasures = 2*precisions.*recalls./(precisions+recalls);
fmeasures(isnan(fmeasures)) = 0;

disp('Thresholds:');
disp(range);
disp('Accuracies:');
disp(accuracies);
disp('Recalls:');
disp(recalls);
disp('Precisions:');
disp(precisions);
disp('FMeasures:');
disp(fmeasures);

% Plot precision-recall curve
font_size = 20;
font_size_thres = 15;
f = figure;
plot(recalls, precisions, 'LineWidth', 2); hold on;
plot(recalls, fmeasures, 'LineWidth', 2, 'Color', 'red');
xlabel('Recall', 'FontSize', font_size);
ylabel('Precision', 'FontSize', font_size);

% step = 10;
% text_range = range(1:step:end);
% text_range = text_range(2:end-1);
text_range = [0.05 0.1 0.2 0.4 0.7 0.9];
for t = text_range
    pos = find(range == t);
    text(recalls(pos)-0.05, precisions(pos)-0.03, num2str(t), 'FontSize', font_size_thres);
    scatter(recalls(pos), precisions(pos), 'k', 'fill');
end
legend({'Precision-Recall', 'FMeasure'}, 'FontSize', font_size, 3);

% Are Under Curve (AUC)
AUC = VOCap(recalls(end-1:-1:2)', precisions(end-1:-1:2)');
ti = ['Precision - Recall curve, AUC=' num2str(AUC)];
title(ti, 'FontSize', font_size);
grid on;
disp(['AUC ' num2str(AUC)]);
saveas(f, [ti '.fig']);
saveas(f, [ti '.png']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Display proportion of Relevant/irrelevant images
disp(['# images: ' num2str(length(labels))]);
nRelevant = sum(labels);
disp(['% of relevant images: ' num2str(nRelevant/length(labels)*100)]);
disp(['% of irrelevant images: ' num2str((length(labels)-nRelevant)/length(labels)*100)]);


%%% Best Threshold = 0.05! FMeasure = 0.88

cd(this_path);
disp('Done');
% exit;