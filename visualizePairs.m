function visualizePairs(imagePlane, centroidArray, pairMat)
%%visualizePairs Plots the paired centroids over a fluorescent image
%
%   Inputs :
%       
figure;
imshow(imagePlane, []);
title('Cick within Image to Continue');
hold on;
for m = 1:size(centroidArray,1)
    idx = find(pairMat(:,1) == m);
    if ~isempty(idx)
        caIdx = [pairMat(idx,2); m]; %all indices for centroidArray
        scatter(centroidArray(caIdx,1),centroidArray(caIdx,2));
        pause(0.1);
    end
    
end
hold off;