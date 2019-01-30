function centroidArray = fociId(imStk, roiSize, skewThresh)
%%fociID Finds foci in 3D image stack
%
%   inputs :
%       imStk : A 3D matrix containing image planes.
%
%   outputs :
%       centroidArray : A 2D matrix where each row is a centroid and the
%       columns contain the X, Y, and Z coordinates in voxels.
%
%   Written by Josh Lawrimore, 1/30/2019
cnt = 1;
%% Generate max intensity projection 
imStkMip = max(imStk, [], 3);
PntIm = advPointSourceDetection(imStkMip, 2, 0);
%% convert roiSize to pad
pad = (roiSize - 1)/2;
%% set up new point image
newPntIm = zeros(size(PntIm));
%% Loop over all pnt sources in image
idx = find(PntIm);
%% Draw rects over MIP
for n=1:numel(idx)
    [y,x] = ind2sub(size(PntIm), idx(n));
    %crop out 3D region
    roi = imStk(y-pad:y+pad,x-pad:x+pad,:);
    passFail = skewness(roi(:)) >= skewThresh;
    if passFail
        newPntIm(idx(n)) = 1;
        [~, maxIdx] = max(roi(:));
        [~,~,z] = ind2sub(size(roi), maxIdx);
        centroidArray(cnt,:) = [x, y, z];
        cnt = cnt + 1;
    end
end