function computeDepthRangeGiveNVM(nvmFileName, middleburryFile)

% nvmFileName = 'C:\Enliang\data\brandenburg\brandenburg_day_50.nvm';
% middleburryFile = 'C:\Enliang\data\brandenburg\brandenburg_day_50.txt';
% nvmFileName = 'C:\Enliang\data\san_marco_tower\san_marco_tower.nvm';
% middleburryFile = 'C:\Enliang\data\san_marco_tower\san_marco_tower.txt';
targetName = 'soda_chocolate_data';
workingPath = 'F:\Enliang\data\jared\';
% nvmFileName = 'C:\Enliang\data\saint_peter\saint_peter.nvm';
% middleburryFile = 'C:\Enliang\data\saint_peter\saint_peter.txt';
nvmFileName = fullfile( workingPath, targetName, [targetName, '.nvm']);
middleburryFile = fullfile( workingPath, targetName, [targetName, '.txt']);

% ---------------------------------------------------------------
[~, points3D] = readNVM(nvmFileName);
camera = read_middleBurry(middleburryFile);

numOfCams = numel(camera);
far_depth = -ones(numOfCams, 1) * realmax('double');
near_depth = ones(numOfCams, 1) * realmax('double');


for i = 1: numel(points3D)    
    pt3d =  points3D(i).pos;
    
    numOfMeasures = size( points3D(i).measure, 1);
    
    for j = 1:numOfMeasures
        cameraID = points3D(i).measure(j, 1);
        cameraID = cameraID + 1;
        
        depth = calculateDepth(cameraID, camera, pt3d);
        
        if(~isempty(depth))
            if(depth > far_depth(cameraID))
                far_depth(cameraID) = depth;
            end
            if(depth < near_depth(cameraID))
                near_depth(cameraID) = depth;
            end
        end
    end    
end
save([targetName, '_Range.mat'], 'near_depth', 'far_depth')

end


function  depth = calculateDepth(cameraID, camera, pt3d)
    R = camera(cameraID  ).R;
    T = camera(cameraID  ).T;
    
    projectedPt = [R,T] * [pt3d,1]';
    depth = projectedPt(3);
    if(depth <= 0)
       fprintf(1, 'warning! depth is no bigger than 0. Camera id: %d\n',   cameraID);
       depth = [];
    end
%     assert(depth>0);
end





