function centroidArray = spbID(rfpStack)
%%spbID Identify spindle pole body foci based on binary object convex area
%%after Otsu thresholding.

%   Input :
%       rfpStack : 3D matrix containing image planes
%
%   Output :
%       centroidArray : A 2D matrix containing the X, Y, and Z posiitons in
%       voxels of each proported spindle pole body foci.
%
% Written by Josh Lawrimore, 1/16/2019
%% Otsu Threshold To Generate Binary Image Stack
rfpBinary = rfpStack > multithresh(rfpStack);
%% Calculate Binary Objects' Properties
rfpTbl = regionprops3(rfpBinary, 'Centroid', 'ConvexVolume');
%% Filter the Table by Volume
%Assuming SPBs are 100x100x100 nm structures and that we are using ~500nm
%emission light, the voxel number with a pixel size 64.5 and z-step of
%300nm is around 150-200 voxels. Since thresholding picks up a lot of
%single pixel values and light can spread more than we initially predict we
%set the voxel volume range from 25 to 500. This range appeared to work
%well in test stack by visual inspection.
rfpTbl25to500 = rfpTbl(rfpTbl.ConvexVolume > 25 &...
    rfpTbl.ConvexVolume < 500, :);
centroidArray = rfpTbl25to500.Centroid;

