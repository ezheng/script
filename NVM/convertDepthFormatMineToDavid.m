function convertDepthFormatMineToDavid()

workingDir = 'F:\Enliang_DenseReconstruction\output_dense\greatBuddha\dense';
taskName = 'greatBuddha';
enliangPath = fullfile(workingDir, 'depth-000_enliang');
davidPath = fullfile(workingDir, 'depth-000_david');
outputPath = fullfile(workingDir, 'depth-000');

[camera, points] = readNVM(fullfile(workingDir, 'model.nvm'));

[camera2, points2] = readNVM(fullfile(workingDir, '\..', [taskName, '.nvm']));

% R11 = quaternion2matrix(camera(1).quarternion); R11 = R11(1:3,1:3);
% R21 = quaternion2matrix(camera2(1).quarternion); R21 = R21(1:3,1:3);
% R = R21' * R11
% camera2(1).pos' ./ (R* camera(1).pos')
% 
% R11 = quaternion2matrix(camera(2).quarternion); R11 = R11(1:3,1:3);  % david
% R21 = quaternion2matrix(camera2(2).quarternion); R21 = R21(1:3,1:3);    % my 
% R = R21' * R11
% camera2(2).pos' ./ (R* camera(2).pos')
% 
%  ( points2(1).pos') ./ (R *points(1).pos')


for i = 1:numel(camera)
    [~,name,~] = fileparts( camera(i).name);
    
    depthEnliang = loadFLTFile( fullfile(enliangPath, 'results',sprintf('depthMap%03d.txt',i-1))); 
%      figure(1); imagesc(depthEnliang); axis equal;
    depthDavid = readDavidDepth( fullfile(davidPath, [name, '-best-depth.data']), false);
    
    assert( size(depthEnliang, 1) == size(depthDavid,1) );
    assert( size(depthEnliang, 2) == size(depthDavid,2) );
    
    
    
    depthEnliang = convertDepth(camera(i), camera2(i), depthEnliang);
    
%     x = depthEnliang./depthDavid;
%     figure(3); imagesc(x);
    
%     figure(2); imagesc(depthDavid); axis equal;
    
    outputFileName = fullfile( outputPath, [name, '-best-depth.data']);
    writeDavidDepth( depthEnliang, outputFileName);
    
    
end
end

function depthEnliang = convertDepth(camera_david, camera_enliang, depthEnliang)
    
R = quaternion2matrix( camera_enliang.quarternion); R = R(1:3,1:3);
C = camera_enliang.pos'; T = -R*C; 

[height, width] = size(depthEnliang);
K= [camera_enliang.focalLength, 0, width/2; 0, camera_enliang.focalLength, height/2; 0, 0,1 ];

x = [1 :  width];
y = [1 : height];
[X, Y] = meshgrid(x, y);
X = X(:)';
Y = Y(:)';
ind = sub2ind([height, width], Y, X);
depthValue = depthEnliang(ind);
points2D = K\([X; Y; ones(size(X))] .* repmat(depthValue, 3, 1));
points3D = [R', -R'*T] * [points2D; ones(1, size(points2D, 2))];

% scale:
R2 = quaternion2matrix(camera_david.quarternion); R2 = R2(1:3,1:3);
C2 = camera_david.pos'; T2 = -R2*C2;
% and transform 3d points
R_transform = R' * R2  ;
scale = camera_enliang(1).pos' ./ (R_transform* camera_david(1).pos');

% R_transform' * pointsEnlaing(2).pos' /scale(1)
% pointsDavid(2).pos

points3D = R_transform' * (points3D / scale(1));
% project into dave's camera, and record the depth

depth = [R2, T2] * [points3D; ones(1,size(points3D,2))];
depth = depth(3,:);
% projPoint = K * [R2, T2] * [points3D; ones(1,size(points3D,2))];

% finalProjPoint = projPoint ./ repmat(projPoint(3,:), 3,1);

depthEnliang(ind) = depth;

end


