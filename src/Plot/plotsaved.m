function plotsaved(filepath,name)
% C:\Users\Aniol\Copy\MCV\PFM\results\PETIA1\14052015\resDiv_fusion.mat

load(filepath)
nbins = size(div,1);


if nargin<2
    [~, name, ~] = fileparts( filepath);
    name = name(8:end);
end
AUC = trapz(div)/nbins;
divstr = sprintf('%s > Mean Diversity (AUC=%g)', name, AUC);
fprintf([divstr '\n']);
plot((1:nbins)/nbins, div, 'DisplayName', sprintf('%s (AUC=%g)', name, AUC));
hold on;
axis ([0 1 0 1])
% title(divstr);
title('All > Mean Diversity');

xlabel('Bins (%k)');
ylabel('Error');

% legend(gca,'show')