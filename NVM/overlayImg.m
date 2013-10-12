function overlayImg

workingPath = 'F:\Enliang\data\fountain';
depthFileName = fullfile(workingPath, 'image', '0005.png');

% overLayImageId = 4;

imageOrig = imread(depthFileName);
SPMap = zeros(size(imageOrig,1), size(imageOrig, 2), 10);

for i = 0 : 9
    selectionFileName = fullfile( '..',  ['_SPMap', num2str(i),'.txt']);
    SPMap(:,:,i+1 ) = loadFLTFile(selectionFileName, false);    
end

for overLayImageId = 0:9
    image = imageOrig;
    SPMap1 = SPMap(:,:,overLayImageId+1)./ sum(SPMap, 3);
    
    % image = image + SPMap;
    for i = 1:3
        x = image(:,:,i);
        if(i~= 3)
            x(SPMap1 < 0.01) = 0 ;
        else
            x(SPMap1 < 0.01) = 255 ;
        end
        %     x = uint8(floor(SPMap1 * 255));
        image(:,:,i) = x;
    end
    
    h = figure(1);
    imagesc(image);
    axis equal;
    saveas(h,['overlay_', num2str(overLayImageId), '.bmp']);
    close(h);
end