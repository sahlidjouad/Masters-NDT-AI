close all; clc; i=0; 
for f=0:1 % f = 0, 1 
    for k=89:90 % k = 1, 2 
        ima= sprintf('%d_image_%d.jpg',f,k); %d prend la valeur de f et k 
        im=imread(ima); % importe l'image
        im=im2double(im); % transforme en format Double ex = 3.14 
        imagesc(im); % visualise l'image figure; % permet de garder l'image %
        i=i+1; %
        features_HOG_TESTING(i,:) = extractHOGFeatures(im);
        
        
       %save('features'); 
    end
end
features_HOG_TESTING= double(features_HOG_TESTING);