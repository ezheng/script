function writeConfigFile_PatchMatch()
%  you need to put images, nvm file and pcdb file in the folder

workingPath = 'F:\Enliang\data\germany2';
taskName = 'germany2';
executable = 'F:\Enliang\cpp\patchMatch_CUDA\build_64_VS2013\Release\patchMatch.exe';
numOfImagesUsed = [];
halfWindowSize = 3;
numOfSamples = 20;
SPMAlpha = 0.5;
numOfIterations = 3;
isGenerateDepthMapInitFile = true;
% ------------------------------------------------------------------
middleburyFullFileName = fullfile(workingPath, [taskName, '.txt']);
nvmFullFileName = fullfile(workingPath, [taskName, '.nvm']);
% if(~exist(fullfile(workingPath, [taskName, '_allImgs.txt']), 'file'))
[camera, points3D] = convertNVM2Middleburry(nvmFullFileName, [taskName, '_allImgs.txt']);
% end
numOfImagesUsed = extractPartsOfImgs(middleburyFullFileName, fullfile(workingPath, [taskName, '_allImgs.txt']), numOfImagesUsed);

depthRangeMatFullFileName = fullfile(workingPath, [taskName, '_Range.mat']);
if(~exist(depthRangeMatFullFileName, 'file'))
    computeDepthRangeGiveNVM( taskName, workingPath, fullfile(workingPath, [taskName, '_allImgs.txt']));
end
load(depthRangeMatFullFileName);


if( isGenerateDepthMapInitFile )
%     && ~exist(fullfile(workingPath, 'depthMapInit'), 'dir')
    writeDepthFile(camera, points3D, fullfile(workingPath, 'depthMapInit'), near_depth, far_depth);
end
    
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
   destFileName = fullfile(workingPath, 'imageResults', ['depthMap', sprintf('%.3d', i-1),'_img',ext]);
    copyfile(originalFileName, destFileName);
end


for i = 1:numOfImagesUsed
    fileName = fullfile(configFullFileFolder, [taskName, sprintf('%.3d', i-1) ,'.ini']);
    fid = fopen(fileName, 'w');
    fprintf(fid,'[params]\n');
    fprintf(fid,'imageInfoFileName = %s\n', middleburyFullFileName);  
%   compute the required near and far depth
    depth_near_original = near_depth(i);
    depth_far_original = far_depth(i);
    [depth_near, depth_far] = rescaleDepth(depth_near_original, depth_far_original);
    
    fprintf(fid, 'depthRangeNear = %f\n', depth_near);
    fprintf(fid, 'depthRangeFar = %f\n', depth_far);
    fprintf(fid, 'refImageId = %d\n', i-1);
    fprintf(fid, 'halfWindowSize = %d\n', halfWindowSize);
    fprintf(fid, 'numOfSamples = %d\n', numOfSamples);
    fprintf(fid, 'SPMAlpha = %f\n', SPMAlpha);
    fprintf(fid, 'gaussianSigma = 0\n');
    fprintf(fid, 'outputFileName = %s\n', fullfile(workingPath, 'results', ['depthMap', sprintf('%.3d', i - 1), '.txt']));
    fprintf(fid, 'numOfIterations = %d\n', numOfIterations);    
    if(isGenerateDepthMapInitFile)
        path = fullfile(workingPath, 'depthMapInit', 'depthMapInit');
        fprintf(fid, 'depthMapInitFileName = %s_%04d.txt\n', path, i-1);
    end
    fclose(fid);
end

fid_bat = fopen(fullfile(workingPath, ['batchprocess', num2str(numOfImagesUsed),'.bat']), 'w');
for i = 1 : numOfImagesUsed
    fprintf(fid_bat, '%s %s\n', executable, fullfile(configFullFileFolder, [taskName, sprintf('%.3d', i-1), '.ini'])  );      
end
fclose(fid_bat);

end

function [depth_near, depth_far] = rescaleDepth(depth_near_original, depth_far_original)
    scaleOffsetFar = 0.8;
    depth_far = depth_far_original + (depth_far_original - depth_near_original) * scaleOffsetFar;
    scaleOffset = 1.5;
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

function writeDepthFile(camera, points3D, filePath, near_depth, far_depth )
    if(~exist(filePath, 'dir'))
       mkdir( filePath); 
    end
    for i = 1:numel(camera)
        if(near_depth(i) < 0) 
            near_depth(i) = 0.01;
        end
%         depthMap = (far_depth(i) - near_depth(i)) .* rand( camera(i).height, camera(i).width) + near_depth(i) ;    
        depthMap = zeros(camera(i).height, camera(i).width);
        R = quaternion2matrix( camera(i).quarternion ); R = R(1:3,1:3);
        T = -R * camera(i).pos';
        K = [camera(i).focalLength, 0, camera(i).width/2; ...
            0, camera(i).focalLength, camera(i).height/2; ...
            0, 0, 1];
        for j = 1:numel(points3D)
%             j
            measure = points3D(j).measure;
            idx = find( measure(:,1) == (i -1));
            if( ~isempty(idx))
%              get the projection 
                localCoord = [R, T] * [points3D(j).pos,1]';
                depth = localCoord(3);
                pos2D = K * localCoord; pos2D = floor( pos2D/pos2D(3) );
%                 points3D(j).measure(idx,3:4)+[camera(i).width/2, camera(i).height/2] - (pos2D(1:2)')
                window = 4;
                [X, Y] = meshgrid( [ pos2D(1) - window : pos2D(1) + window ], [pos2D(2)- window : pos2D(2) + window] );
                X(X>=camera(i).width) = camera(i).width - 1;
                Y(Y>=camera(i).height) = camera(i).height - 1;
                X(X<=0) = 1; Y(Y<=0) = 1;
                p = [Y(:), X(:)];   
                idx2 = sub2ind([camera(i).height, camera(i).width], Y(:), X(:) );
                idx3 =  find(depthMap(idx2) > depth | depthMap(idx2)== 0);
                idx2 = idx2(idx3);
                depthMap(idx2 ) = depth;
%                 depthMap( idx2 ) = depth;
            end
        end
        map = (far_depth(i) - near_depth(i)) .* rand( camera(i).height, camera(i).width) + near_depth(i);
        depthMap(depthMap == 0) = map(depthMap == 0);
        
        outputFileName = fullfile( filePath,  sprintf('depthMapInit_%04d.txt', i-1));
%         write flt file
        writeFLTFile(outputFileName, depthMap);
    end
end
