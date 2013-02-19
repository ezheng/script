function extractMiddleBurryImageRegions()

% imageROI [top, left, bottom, right]
imageROI = [1200, 300, 1799, 799];
orignalMiddleburryFileName = 'F:\Enliang\data\fountain_yilin\origImage\fountain_original.txt';
outputPath = 'F:\Enliang\data\fountain_subregion';

% ---------------------------------
if(~exist(outputPath, 'dir'))
    mkdir(outputPath);
end

image = read_middleBurry(orignalMiddleburryFileName);
for imageIdx = 1 : numel(image)
    imageData = imread(image(imageIdx).imageName);
    [imgH, imgW, imgD] = size(imageData);
    [~, name, ext] = fileparts(image(imageIdx).imageName);
        
    assert( imageROI(1) > 0 && imageROI(2) > 0 && imageROI(3) <= imgH && imageROI(4) <= imgW);    
    subImage = imageData( imageROI(1):imageROI(3), imageROI(2):imageROI(4), :);
    subImageFileName = fullfile( outputPath, [name, '_sub', ext]);
    imwrite(subImage, subImageFileName);
    
    image(imageIdx).K(1,3) = image(imageIdx).K(1,3) - imageROI(2);
    image(imageIdx).K(2,3) = image(imageIdx).K(2,3) - imageROI(1);
    
    image(imageIdx).imageName = subImageFileName;
    
end

[~, orignalMBNoPath, originalMBExt] = fileparts(orignalMiddleburryFileName);
outputFileName = fullfile(outputPath, [orignalMBNoPath,'_sub', originalMBExt]);
% writeMiddleburry(image, outputFileName);

fid = fopen(outputFileName, 'w');
fprintf(fid, '%i\n', numel(image));
for i = 1:numel(image)
    fprintf(fid, '%s ', image(i).imageName);
%     writing K matrix
%     K = [ cameras(i).focalLength, 0 , cameras(i).width /2 ; 0, cameras(i).focalLength, cameras(i).height/2.0; 0 0 1 ];
    K = image(i).K';
    for j = 1:9
        fprintf(fid, '%.6f ', K(j));
    end        
%     writing R matrix    
    R = image(i).R';
    for j = 1:9
        fprintf(fid, '%.12f ', R(j));
    end    
%   writing T vector       
    fprintf(fid, '%.12f %.12f %.12f\n', image(i).T(1), image(i).T(2), image(i).T(3));    
end




