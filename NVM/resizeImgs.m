function resizeImgs(workingDir, maxDim)

if(nargin == 1)   
    maxDim = 2048;
end

% workingDir = 'C:\Enliang\data\coliseum2';
origDir = fullfile(workingDir, 'OrignalImage');
outputDir = fullfile(workingDir, 'image');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

allFiles = dir( fullfile(origDir, '*.jpg'));
numOfFiles = numel(allFiles);
for i = 1:numOfFiles
    fprintf(1,'processing image %d\n',i);
    name = fullfile(origDir, allFiles(i).name);
    img = imread(name);
    
    resultedImg = resizeImg (img, maxDim);
    
    outputName = fullfile(outputDir, allFiles(i).name);
    imwrite(resultedImg, outputName);
    
end

end


function resultedImg = resizeImg(img, maxDim)
    height = size(img,1);
    width = size(img,2);
    dim = max(height,width);
    sz = 1;
    while(dim > maxDim)
        sz = sz/2;
        dim = dim/2;        
    end
    resultedImg = imresize(img, sz);
end
