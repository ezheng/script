function main()

% this script generates the images for each step in the patchMatch sweep
% the input is the *.txt depth files in the folder %workngPath%/rawData/

workingPath = 'C:\Enliang\matlab\script\NVM\createHalfProcessImgs\greatBuddha2\';
% colorRange = [35,48];
% colorRange = [4.790 ,9.6567];
colorRange = [5.5, 7.5];

% ----------------------------------------------------------------
outputPath = fullfile(workingPath, 'output');
if( ~exist(outputPath,'dir'))
    mkdir(outputPath);
end
addpath C:\Enliang\library_64\export_fig
allFiles = dir(fullfile(workingPath, 'rawData', '*.txt'));
numOfIterations = numel(allFiles) - 1;



for i = 1:numOfIterations
    fprintf(1, 'processingIter: %d\n', i);
    outputPath_sub = fullfile(outputPath, sprintf('%03d', i ));
    if( ~exist(outputPath_sub,'dir'))
        mkdir(outputPath_sub);
    end
    
    dataFormer = loadFLTFile( fullfile(workingPath, 'rawData', allFiles(i).name) );
    dataLater = loadFLTFile( fullfile(workingPath, 'rawData', allFiles(i+1).name) );
    
    [height, width] = size(dataFormer);
    
    if( mod(i,4) == 1)
        for j = 1:10: width            
            newImg = [dataLater(:,1:j), dataFormer(:,j+1:end)];
            newImg(:,j) = zeros( size(newImg,1), 1);
           outputFileName = fullfile(outputPath_sub, ['iter', sprintf('%02d',i),'_', sprintf('%04d',j),'.png']);
           plotFullScreen(newImg, outputFileName,colorRange);
        end
    elseif( mod(i,4) == 2)
        for j = 1:10: height            
%             newImg = [dataLater(:,1:j), dataFormer(:,j+1:end)];
            newImg = [dataLater(1:j, :); dataFormer(j+1:end,:)];
            newImg(j,:) = zeros(1, size(newImg, 2));
            outputFileName = fullfile(outputPath_sub, ['iter', sprintf('%02d',i),'_', sprintf('%04d',j),'.png']);      
            plotFullScreen(newImg, outputFileName,colorRange);
        end
    elseif (mod(i,4) == 3)
%         for j = 1:10: width            
         for j = width : -10:1
            newImg = [dataFormer(:,1:j-1), dataLater(:,j:end)];
            newImg(:,j) = zeros( size(newImg,1), 1);
            outputFileName = fullfile(outputPath_sub, ['iter', sprintf('%02d',i),'_', sprintf('%04d',width - j + 1),'.png']);
            plotFullScreen(newImg, outputFileName,colorRange);            
        end
    else    
         for j = height : -10:1           
            newImg = [dataFormer(1:j-1, :); dataLater(j:end,:)];
             newImg(j,:) = zeros(1, size(newImg, 2));
            outputFileName = fullfile(outputPath_sub, ['iter', sprintf('%02d',i),'_', sprintf('%04d',height - j + 1),'.png']);
            plotFullScreen(newImg, outputFileName,colorRange);
        end
    end
end

end

function plotFullScreen(newImg, outputFileName, colorRange)


h =figure(1);
%              set(h,'position', [260, 228, 768,768 ]);
set(h,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
imagesc(newImg, colorRange);
axis equal; colorbar;
zoom(2); zoom(0.5); set(h, 'color', 'w');
export_fig( outputFileName);
end









