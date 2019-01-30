function passFail = positionFilter(maxIntProj, XY1, XY2)
%%positionFilter Determines signal location using advPointSourceDetection
%%function and filters out images without detectable signals, and signals
%%outside of a region defined by the X and Y coordinates of the spindle
%%pole body foci.
%
%   inputs :
%       maxIntProj : A 2D matrix containing a maximum intensity projection
%       of an image stack.
%
%       XY1 : A vector containing the X and Y coordinates for a
%       point of interest. Usually the brightest pixel of a spindle pole
%       body foci.
%
%       XY2: A vector containing the X and Y coordinates for a
%       point of interest. Usually the brightest pixel of a spindle pole
%       body foci.
%
%   output :
%       passFail = A logical value of 1 if image matrix contains a
%       a signal that is within the region defined min/max X and Y
%       coordinates of the two centroids.
%
%   Written by Josh Lawrimore, 1/29/2019
pntIm = advPointSourceDetection(maxIntProj,2,0);
numPnts = sum(pntIm(:));
if numPnts == 0
    passFail = false;
else
    %% Test position of each detected point
    pntIdx = find(pntIm);
    [row, col] = ind2sub(size(maxIntProj), pntIdx);
    posTest = zeros([numel(row), 1]);
    for m = 1:numel(row)
        minX = min([XY1(1),XY2(1)]);
        minY = min([XY1(2),XY2(2)]);
        maxX = max(XY1(1),XY2(1));
        maxY = max(XY1(2),XY2(2));
        posTest(m) = row(m) >= minY & row(m) <= maxY |...
            col(m) >= minX & col(m) <= maxX;
    end
    if sum(posTest) ~= numel(posTest)
        passFail = false;
    else
        slength2D = sqrt(sum((XY1(1:2) - XY2(1:2)).^2));
        slength2Dnm = slength2D * 64.5;
        if slength2Dnm > 2500
            cenMat = [XY1(2), XY1(1);...
                XY2(2), XY2(1)];
            maxDistnm = zeros([size(numPnts), 1]);
            for i = 1:numPnts
                maxDistnm(i) = max(sqrt(sum((cenMat - [row(i), col(i)]).^2, 2)))*64.5;
            end
            totalMaxDistnm = max(maxDistnm);
            maxDistRatio = totalMaxDistnm/slength2D;
            if maxDistRatio < 0.8
                passFail = true;
            else
                passFail = false;
            end
        else
            passFail = true;
        end
    end
end