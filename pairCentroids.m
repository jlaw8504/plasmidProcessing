function pairMat = pairCentroids(centroidArray, distance, pixelSize, zStep)
%%pairMat Parses a matrix of centroids and returns row index of centroids
%%within a specified distance
%
%   Inputs :
%       centroidArray : A 2D matrix where each row is a centroid and the
%       columns contain the X, Y, and Z coordinates in voxels.
%
%       distance : An integer specifying the distance two centroids must be
%       within to count as a pair.
%
%       pixelSize : An integer specifying the pixel size in nanometers.
%
%       zStep : An integer specifying the z-step size in nanometers.
%
%   Outputs :
%       pairMat : A 2D matrix composed of row indices from the
%       centroidArray variable.
%
%   Written by Josh Lawrimore, 1/16/2019
        
%% Calculate pairwaise distance for each centroid
%pre-allocate matrix
subSq = zeros([size(centroidArray,1),...
               size(centroidArray,2),...
               size(centroidArray,1)]);
dists = zeros([size(centroidArray,1),...
               size(centroidArray,1)]);
for m = 1:size(centroidArray,1)
    for n = 1:3
        if n < 3
            subSq(:,n,m) = (centroidArray(:,n) * pixelSize - ...
                centroidArray(m,n) * pixelSize).^2;
        else
            subSq(:,n,m) = (centroidArray(:,n) * zStep - ...
                centroidArray(m,n) * zStep).^2;
        end
    end
    dists(:,m) = sqrt(sum(subSq(:,:,m),2));
end
%% Parse dists matrix for centroids within 5 microns of each other
%remove upper half of matrix to prevent repeats
halfDists = tril(dists);
halfDists(halfDists == 0) = nan;
distsLT = halfDists <= distance; %nm
[row, col] = find(distsLT);
%in col array indecies are in ascending order, so put them first
pairMat = [col,row];
