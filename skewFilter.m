function passFail = skewFilter(imMat, skewThresh)
%%skewFilter Determines if the intensities of the largest signal in a 3D
%%image stack is skewed compared to a given threhold value.
%
%   input :
%       imMat : A 3D matrix containing the image planes for a single
%       timepoint. Dimesions are Y,X,Z.
%
%       skewThresh : A double value specifying the skewness value the
%       intensity distribution must meet to pass. Typically set at 1.
%
%   output :
%       passFail : A logical value of 1 indicates the distribution is
%       skewed beyond the skewThresh value.
%
%   Written by Josh Lawrimore, 1/25/2019

%% Threshold image to generate binary image
binary = imMat > multithresh(imMat);
%% Use regionprop3 to determine largest binary object
propTable = regionprops3(binary, 'ConvexVolume', 'VoxelIdxList');
[~, idx] = max(propTable.ConvexVolume);
voxIdx = propTable.VoxelIdxList{idx};
%% Parse imMat with voxIdx and normalize intensity values
roiNorm = (imMat(voxIdx) - min(imMat(voxIdx)))./...
    (max(imMat(voxIdx)) - min(imMat(voxIdx)));
%% Measure skewness of roiNorm and compare to skewThresh
passFail = skewness(roiNorm) > skewThresh;