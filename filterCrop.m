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
    if positionTest && rsquare > 0.95
        filterCell(cnt,:) = cropCell(n,:);
        cnt = cnt + 1;
    end
        
end