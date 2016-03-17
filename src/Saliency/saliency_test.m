%% Visualize the saliency map

%Name image (without the format)
name_image='090153';
%Load saliency results+

cd('/media/HDD_2TB/mcarne/keyframe-extractor/precomputed/Estefania1/saliency');
data=load(['/media/HDD_2TB/mcarne/keyframe-extractor/precomputed/Estefania1/saliency/' name_image '.mat']);
%It's a 1x1x240x320, we need the 2D image

sal=reshape(data.isal, [240 320]);

%Normalize the saliency map for the visualization
maximum=max(max(sal));
minimum=min(min(sal));

sal_norm=(sal+abs(minimum))/(abs(minimum)+maximum);

%We have to inverse the order of the column, because the image are
%inverted.
sal_norm_inv=zeros(240,320);

for i=1:320
    sal_norm_inv(:,(320-(i-1)))=sal_norm(:,i);
end

cd('/media/HDD_2TB/mcarne/keyframe-extractor/db/Estefania1');

img=imread([name_image '.jpg']);
figure;
subplot(121),imshow(img),title('Image');
subplot(122),imshow(sal_norm_inv),title('Saliency map');
