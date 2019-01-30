function filterCell = filterCrop(cropCell)
%%filterCrop Filters the images within cropCell cell array by only keeping
%%images with a Gaussian-like GFP signal, with a right-skewed signal
%%intensity distribution, that is located between the two SPB foci.
%
%   input : 
%       cropCell : A cell array containing the cropped rfp and gfp images,
%       the adjusted coordinates of the centroids of the SPB foci in
%       the cropped rfp image, and the SPB indices from pairMat matrix.
%       Columns are rfp, gfp, 1st spb coordinate (X, Y, Z), 2nd spb
%       coordinate (X, Y, Z), and the SPB indices.
%
%   output :
%       filterCell : A filtered version of cropCell cell array only
%       containing images that all meet the criteria.

%% Instantiate cnt index
cnt = 1;
%% Rotate the cropCell array
rotCell = cropCellRotate(cropCell);
%% Use a tight crop on max projection of the rotated image
for n = 1:size(rotCell,1)
    passFail = gaussPosFilter(...
        rotCell{n,2}, rotCell{n,3}, rotCell{n,4}, 0.8, (1/3));
    if passFail
        skewPassFail = skewFilter(cropCell{n,2}, 1);
        if skewPassFail
            posPassFail = positionFilter(max(cropCell{n,2}, [], 3), cropCell{n,3}, cropCell{n,4});
            if posPassFail
                filterCell(cnt,:) = cropCell(n,:);
                cnt = cnt + 1;
            end
        end
    end
end