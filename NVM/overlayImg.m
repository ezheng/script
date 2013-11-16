function overlayImg

workingPath = 'C:\Enliang\data\greatBuddha\';
referenceImgName = 'depthMap024_img.jpg';
addpath 'C:\Enliang\library_64\export_fig' 
% ========================================================
SPMapPath = fullfile(workingPath, 'SPM');
imageFileName = fullfile(workingPath, 'imageResults', referenceImgName);
imageOrig = imread(imageFileName);

allSPMapFiles = dir( fullfile(SPMapPath, '*.txt'));
SPMap = zeros(size(imageOrig,1), size(imageOrig, 2), numel(allSPMapFiles));

for i = 0 : numel(allSPMapFiles)-1
    fprintf(1,'reading... %%%02i is finished\n', round(i/numel(allSPMapFiles)*100));
    selectionFileName = fullfile(SPMapPath,  sprintf('_SPMap%04d.txt', i));    
    SPMap(:,:,i+1 ) = loadFLTFile(selectionFileName);    
end

allSum = sum(SPMap, 3);
for overLayImageId = 0: numel(allSPMapFiles)-1
    image = imageOrig;
    SPMap1 = SPMap(:,:,overLayImageId+1)./allSum ;    
    % image = image + SPMap;
    threshold = 1/(numel(allSPMapFiles))/10;
    for i = 1:3
        x = image(:,:,i);
        if(i~= 3)
            x(SPMap1 < threshold) = 0 ;
        else
            x(SPMap1 < threshold) = 255 ;
        end
        %     x = uint8(floor(SPMap1 * 255));
        image(:,:,i) = x;
    end    
    h = figure(1); imagesc(image); axis equal;
    [~,name,~] = fileparts(allSPMapFiles(overLayImageId+1).name);
    outputFileName = fullfile(SPMapPath, [name, '.pdf']);
%     saveas(h,['overlay_', num2str(overLayImageId), '.bmp']);    
    export_fig( outputFileName);
%     close h;
end