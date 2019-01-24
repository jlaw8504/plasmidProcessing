for n = 1:size(filterCell,1)
    slength2D = sqrt(sum((filterCell{n,3}(1:2) - filterCell{n,4}(1:2)).^2));
    slength2Dnm = slength2D * 64.5;
    mip = max(filterCell{n,2}, [], 3);
    pntIm = advPointSourceDetection(mip, 2, 0);
    h = figure('WindowState', 'maximized');
    subplot(1,2,1);
    imshow(mip, []);
    title(num2str(n));
    hold on;
    cenMat = [filterCell{n,3}; filterCell{n,4}];
    scatter(cenMat(:,1), cenMat(:,2), 'ro');
    hold off;
    subplot(1,2,2);
    imshow(pntIm);
    title(num2str(round(slength2Dnm)));
    waitforbuttonpress;
    close(h);
end