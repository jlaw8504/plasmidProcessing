%% Instantiate cnt index
cnt = 1;
%% Rotate the cropCell array
rotCell = cropCellRotate(cropCell);
%% Use a tight crop on max projection of the rotated image
for n = 1:size(rotCell,1)
    rfpMip = max(rotCell{n,1}, [], 3);
    gfpMip = max(rotCell{n,2}, [], 3);
    rows = floor(rotCell{n,3}(1))-2:ceil(rotCell{n,4}(1))+3;
    if isempty(rows)
        rows = floor(rotCell{n,4}(1))-2:ceil(rotCell{n,3}(1))+3;
    end
    cols = floor(rotCell{n,3}(2)):ceil(rotCell{n,4}(2));
    if isempty(cols)
        cols = floor(rotCell{n,4}(2)):ceil(rotCell{n,3}(2));
    end
    gfpMipTight = gfpMip(rows, cols);
    %% Determine if plasmid signal is within tight crop region
    gfpArray = sum(gfpMipTight);
    [mu, rsquare] = noisedGaussFit(gfpArray);
    positionTest = mu > 0.33*length(gfpArray) | mu < 0.66*length(gfpArray);
    if positionTest && rsquare > 0.8
        %gfpCropMip = max(cropCell{n,2}, [], 3);
        gfpCrop = cropCell{n,2};
        gfpBin = gfpCrop > multithresh(gfpCrop);
        propTable = regionprops3(gfpBin, 'ConvexVolume', 'VoxelIdxList');
        [maxVol, idx] = max(propTable.ConvexVolume);
        voxIdx = propTable.VoxelIdxList{idx};
        roiNorm = (gfpCrop(voxIdx) - min(gfpCrop(voxIdx)))./...
            (max(gfpCrop(voxIdx)) - min(gfpCrop(voxIdx)));
        if skewness(roiNorm) > 1
            pntIm = advPointSourceDetection(max(cropCell{n,2}, [], 3),2,0);
            numPnts = sum(pntIm(:));
            if numPnts > 0
                %% Test position of each detected point
                pntIdx = find(pntIm);
                [row, col] = ind2sub(size(max(cropCell{n,2}, [], 3)), pntIdx);
                for m = 1:numel(row)
                    minX = min([cropCell{n,3}(1),cropCell{n,4}(1)]);
                    minY = min([cropCell{n,3}(2),cropCell{n,4}(2)]);
                    maxX = max(cropCell{n,3}(1),cropCell{n,4}(1));
                    maxY = max(cropCell{n,3}(2),cropCell{n,4}(2));
                    posTest(m) = row(m) >= minY & row(m) <= maxY |...
                        col(m) >= minX & col(m) <= maxX;
                end
                if sum(posTest) == numel(posTest)
                    slength2D = sqrt(sum((cropCell{n,3}(1:2) - cropCell{n,4}(1:2)).^2));
                    slength2Dnm = slength2D * 64.5;
                    if slength2Dnm > 2500
                        cenMat = [cropCell{n,3}(2), cropCell{n,3}(1);...
                            cropCell{n,4}(2), cropCell{n,4}(1)];
                        
                        for i = 1:numPnts
                            maxDistnm(i) = max(sqrt(sum((cenMat - [row(i), col(i)]).^2, 2)))*64.5;
                        end
                        totalMaxDistnm = max(maxDistnm);
                        maxDistRatio = totalMaxDistnm/slength2D;
                        if maxDistRatio < 0.8
                            filterCell(cnt,:) = cropCell(n,:);
                            cnt = cnt + 1;
                        end
                    else
                        filterCell(cnt,:) = cropCell(n,:);
                        cnt = cnt + 1;
                    end
                end
            end
        end
    end
end