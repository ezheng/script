function readDepthData()
workingPath = 'C:\Enliang\data\brandenbur_larger';

addpath('C:\Enliang\library_64\export_fig\');
inputFileRoot = fullfile(workingPath, 'results');
outputFileRoot = fullfile(workingPath, 'imageResults\');
% ===========================================================
allImgsTxtFile = dir(fullfile(inputFileRoot, '*.txt'));
numOfImages = numel(allImgsTxtFile);

for i = 1:numOfImages
% for i = 112
%     fileName = [inputFileRoot, ['depthMap',sprintf('%.3d', i-1) ,'.txt']];
    fileName = fullfile(inputFileRoot, allImgsTxtFile(i).name);

    % --------------------------------------------------
%     data = dlmread(fileName);
%     depth = numel(data)/width/height;
%     data = reshape( data, width, height, depth);
%     data = data';
    data = loadFLTFile(fileName);
    % -------------------------
    figure(1); imagesc(data); axis equal;colorbar;
    zoom(2);
    zoom(0.5);
    outputFileName = fullfile(outputFileRoot, ['depthMap', sprintf('%.3d',i-1),'.pdf']);
    export_fig(outputFileName);
    close 1;
end

