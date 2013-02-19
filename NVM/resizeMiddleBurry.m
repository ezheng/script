function resizeMiddleBurry()

outputPath = 'C:\Enliang\data\fountain_quartresolution\';
outputFileName = 'fountain_quadresolution.txt';
fileName = 'C:\Enliang\data\fountain_halfresolution\fountain_halfresolution.txt';
scale = 0.5;


% ----------------------------------------------------
if(~exist(outputPath, 'dir'))
    mkdir(outputPath);
end

images = read_middleBurry(fileName);
fid = fopen(fullfile(outputPath, outputFileName), 'w');
assert(fid ~= -1)
fprintf(fid, '%i\n', numel(images));
for i = 1:numel(images)
    
%  write images    
    images(i).imageData = imread(images(i).imageName);
    newImg = imresize(images(i).imageData, scale);    
    [~, name, ext] = fileparts(images(i).imageName);    
    outputFullName = fullfile(outputPath, [name, ext]);
    imwrite(newImg, outputFullName);
    
%  
    fprintf(fid, '%s ', outputFullName);
    images(i).K(1) = images(i).K(1)/2;
    images(i).K(5) = images(i).K(5)/2;
    images(i).K(7) = images(i).K(7)/2;
    images(i).K(8) = images(i).K(8)/2;
    K = images(i).K';
    for j = 1:9
        fprintf(fid, '%.6f ', K(j));
    end
    R = images(i).R';
    for j = 1:9
        fprintf(fid, '%.12f ', R(j));
    end
    for j = 1:3
        fprintf(fid, '%.12f ', images(i).T(j));
    end
    fprintf(fid, '\n');
end

fclose(fid);


