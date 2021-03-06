function writeConfigFile_PatchMatch(workingPath, taskName, executable, numOfImagesUsed,...
    halfWindowSize, numOfSamples, SPMAlpha, numOfIterations)
%  you need to put images, nvm file and pcdb file in the folder

% workingPath = 'C:\Enliang\data\randObject_less';
% taskName = 'randObject_less';
% executable = 'C:\Enliang\data\executable\patchMatch.exe';
% numOfImagesUsed = [];
% halfWindowSize = 8;
% numOfSamples = 15;
% SPMAlpha = 0.6;
% numOfIterations = 3;

% ------------------------------------------------------------------
middleburyFullFileName = fullfile(workingPath, [taskName, '.txt']);
nvmFullFileName = fullfile(workingPath, [taskName, '.nvm']);
if(~exist(fullfile(workingPath, [taskName, '_allImgs.txt']), 'file'))
    camera = convertNVM2Middleburry(nvmFullFileName, [taskName, '_allImgs.txt']);
    
    middleBurryFilePath = fullfile( workingPath, 'middleBurry');
    if(~exist(middleBurryFilePath, 'dir'))
        mkdir(middleBurryFilePath);
    end
    
    for i = 1:numel(camera)
        startId = (i-9);
        if(startId <= 0)
            startId = 1;
        end
        endId = startId + 18;
        if(endId > numel(camera))
            endId = numel(camera);
            startId = endId - 18;
        end
        idx = [i, startId:(i-1), (i+1):endId];        
        outputFileName = fullfile( middleBurryFilePath, [ taskName, sprintf('_%.4d', i-1), '.txt']);        
        writeMiddleburry(camera(idx), outputFileName);
    end
end
numOfImagesUsed = extractPartsOfImgs(middleburyFullFileName, fullfile(workingPath, [taskName, '_allImgs.txt']), numOfImagesUsed);


depthRangeMatFullFileName = fullfile(workingPath, [taskName, '_Range.mat']);
if(~exist(depthRangeMatFullFileName, 'file'))
    computeDepthRangeGiveNVM( taskName, workingPath, fullfile(workingPath, [taskName, '_allImgs.txt']));
end
load(depthRangeMatFullFileName);
    
configFullFileFolder = fullfile(workingPath, 'config');
if(~exist(configFullFileFolder, 'dir'))
    mkdir(configFullFileFolder);
end


%  [camera, points3D] = readNVM(nvmFullFileName);
% numOfImages = numel(camera);
% assert(numOfImagesUsed <= numOfImages)
if(~exist(fullfile(workingPath, 'results'),'dir'))
    mkdir(fullfile(workingPath, 'results'));
end
% copy and rename image files
if(~exist(fullfile(workingPath, 'imageResults'), 'dir'))
   mkdir(fullfile(workingPath, 'imageResults')) 
end

load(fullfile(workingPath, [taskName, '.mat']), 'camera');
for i = 1:numOfImagesUsed
   originalFileName = camera(i).name;
   [~,~,ext] = fileparts(originalFileName);
   destFileName = fullfile(workingPath, 'imageResults', ['depthMap', sprintf('_%.4d', i-1),'_img',ext]);
    copyfile(originalFileName, destFileName);
end


for i = 1:numOfImagesUsed
    fileName = fullfile(configFullFileFolder, [taskName, sprintf('_%.4d', i-1) ,'.ini']);
    fid = fopen(fileName, 'w');
    fprintf(fid,'[params]\n');
    
    middleburySubFileName = fullfile(   workingPath, 'middleBurry', [ taskName, sprintf('_%.4d', i-1), '.txt']);      
    fprintf(fid,'imageInfoFileName = %s\n', middleburySubFileName);  
    
%   compute the required near and far depth
    depth_near_original = near_depth(i);
    depth_far_original = far_depth(i);
    [depth_near, depth_far] = rescaleDepth(depth_near_original, depth_far_original);
    
    fprintf(fid, 'depthRangeNear = %f\n', depth_near);
    fprintf(fid, 'depthRangeFar = %f\n', depth_far);
    fprintf(fid, 'refImageId = %d\n', 0);
    fprintf(fid, 'halfWindowSize = %d\n', halfWindowSize);
    fprintf(fid, 'numOfSamples = %d\n', numOfSamples);
    fprintf(fid, 'SPMAlpha = %f\n', SPMAlpha);
    fprintf(fid, 'gaussianSigma = 0\n');
    fprintf(fid, 'outputFileName = %s\n', fullfile(workingPath, 'results', ['depthMap', sprintf('_%.4d', i - 1), '.txt']));
    fprintf(fid, 'numOfIterations = %d\n', numOfIterations);    
    
    fclose(fid);
end

fid_bat = fopen(fullfile(workingPath, ['batchprocess', num2str(numOfImagesUsed),'.bat']), 'w');
for i = 1 : numOfImagesUsed
    fprintf(fid_bat, '%s %s\n', executable, fullfile(configFullFileFolder, [taskName, sprintf('_%.4d', i-1), '.ini'])  );      
end
fclose(fid_bat);

end

function [depth_near, depth_far] = rescaleDepth(depth_near_original, depth_far_original)
    scaleOffsetFar = 2.5;
    depth_far = depth_far_original + (depth_far_original - depth_near_original) * scaleOffsetFar;
    scaleOffset = 2.0;
    depth_near = depth_near_original - (depth_far_original - depth_near_original) * scaleOffset;
    
    while(depth_near <= 0)
       scaleOffset = scaleOffset / 1.1; 
        depth_near = depth_near_original - (depth_far_original - depth_near_original) * scaleOffset;
    end
end

function numOfImagesUsed = extractPartsOfImgs(dest, orig, numOfImagesUsed)
    fid_orig = fopen(orig, 'r');
    numOfImgs = fgets(fid_orig);
    numOfImgs = str2double(numOfImgs);
    if(isempty(numOfImagesUsed))
        numOfImagesUsed = numOfImgs;
    end
    assert(numOfImagesUsed <= numOfImgs)
    fid_dest = fopen(dest, 'w');
    fprintf(fid_dest, '%d\n', numOfImagesUsed);
    for i = 1:numOfImagesUsed
        line = fgets(fid_orig);
        fprintf(fid_dest, '%s', line);        
    end
    fclose(fid_dest);
    fclose(fid_orig);
end


