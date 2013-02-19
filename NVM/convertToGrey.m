function convertToGrey()

workingPath = 'C:\Enliang\data\Reichstag_outside\image';

allFiles = dir(fullfile(workingPath, '*.jpg'));
numOfImgs = numel(allFiles);

for i = 1:numOfImgs
    imageName = fullfile( workingPath, allFiles(i).name);
    img = imread( imageName);
    
    img = rgb2gray(img);
    img = repmat( img, [1,1,3]);
    
    imwrite(img, imageName);


end