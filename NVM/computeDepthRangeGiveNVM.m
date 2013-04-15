function computeDepthRangeGiveNVM(targetName, workingPath, middleburryFile)

% targetName = 'soda_chocolate_data';
% workingPath = 'F:\Enliang\data\jared\soda_chocolate_data';
nvmFileName = fullfile( workingPath,  [targetName, '.nvm']);
% middleburryFile = fullfile( workingPath, [targetName, '.txt']);

% ---------------------------------------------------------------
[~, points3D] = readNVM(nvmFileName);
camera = read_middleBurry(middleburryFile);

numOfCams = numel(camera);
far_depth = ones(numOfCams, 1) ;
near_depth = ones(numOfCams, 1) ;

for i = 1:numOfCams
   depth{i} =  [];
end
for i = 1: numel(points3D)    
    pt3d =  points3D(i).pos;
    
    numOfMeasures = size( points3D(i).measure, 1);
    
    for j = 1:numOfMeasures
        cameraID = points3D(i).measure(j, 1);
        cameraID = cameraID + 1;
        
        depth{cameraID} = [depth{cameraID}, calculateDepth(cameraID, camera, pt3d)];
        
%         if(~isempty(depth))
%             if(depth > far_depth(cameraID))
%                 far_depth(cameraID) = depth;
%             end
%             if(depth < near_depth(cameraID))
%                 near_depth(cameraID) = depth;
%             end
%         end
    end    
end

for i = 1:numOfCams
    oneCamDepth = sort(depth{i});
    numOfPts = numel(oneCamDepth);
    near_depth(i) = oneCamDepth(round(numOfPts*0.05));
    far_depth(i) = oneCamDepth(round(numOfPts * 0.95));
end

save(fullfile(workingPath, [targetName, '_Range.mat']), 'near_depth', 'far_depth')

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





