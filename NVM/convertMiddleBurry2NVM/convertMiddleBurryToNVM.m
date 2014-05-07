function convertMiddleBurryToNVM( middleburryFileName , originalNVMFileName)

% we use the 2d features in the file called 'originalNVMFileName'
% the camera poses are from middleburryFileName, but the focal length
% becomes the average of fx and fy, principal point becomes the center of
% the cameras

middleburryFileName = 'F:\Enliang\matlab\script\NVM\convertMiddleBurry2NVM\fountain.txt';
originalNVMFileName = 'fountain.nvm';
outputNVMFileName = 'fountain_goesele_output.nvm';

addpath '..'

cameraMiddleburry = read_middleBurry( middleburryFileName);
[cameraNVM, points3D] = readNVM(originalNVMFileName);
numOfCams = numel(cameraMiddleburry);

% all the images have the same K and focal length
focalLength = (cameraMiddleburry(1).K(1,1) + cameraMiddleburry(1).K(2,2))/2; 
img = imread( cameraMiddleburry(1).imageName); [height, width, ~] = size(img);
K = [focalLength, 0, width/2; 0, focalLength, height/2; 0,0,1 ];

for i = 1:numOfCams
% camera poses
     newNVMCams(i).focalLength = (cameraMiddleburry(i).K(1,1) + cameraMiddleburry(i).K(2,2))/2;
     newNVMCams(i).quarternion = matrix2quaternion(cameraMiddleburry(i).R);
     newNVMCams(i).pos = -cameraMiddleburry(i).R' * cameraMiddleburry(i).T;
     newNVMCams(i).distortion = [0, 0];
     newNVMCams(i).name = cameraNVM(i).name;        
     
     newNVMCams(i).P = K * [cameraMiddleburry(i).R, cameraMiddleburry(i).T];
     
%      RR = quaternion2matrix(cameraNVM(i).quarternion); RR = RR(1:3,1:3);
%      cameraNVM(i).P = [cameraNVM(i).focalLength, 0, width/2; 0, cameraNVM(i).focalLength, height/2; 0 0 1]* [RR,-RR*cameraNVM(i).pos' ];
end

% write the new NVM file
fid = fopen( outputNVMFileName, 'w');
assert(fid > 0)
fprintf(fid, 'NVM_V3\n\n');
fprintf(fid, '%d\n', numOfCams);

for i = 1:numOfCams
    fprintf(fid, '%s\t %f ', newNVMCams(i).name, newNVMCams(i).focalLength);
    fprintf(fid, '%.12f ' , newNVMCams(i).quarternion);
    fprintf(fid, '%.12f ' , newNVMCams(i).pos);
    fprintf(fid, '%d ' , newNVMCams(i).distortion);     %note it is 0, so use %d, I found goesele's code(makescene) cannot read 0.00000 (strange -_-!)
    fprintf(fid, '\n');
end
fprintf( fid, '\n%d\n', numel(points3D) );

for i = 1:numel(points3D)
    if( mod(i,100) == 0)
        fprintf(1, '%d percent is finished\n', round(i/numel(points3D)*100) );
    end
    
    imageIdx = points3D(i).measure(:,1);
    feature = points3D(i).measure(:,3:4);   % the feature position is 0 based
    feature = feature';   
    feature(1,:) = feature(1,:) + width/2;
    feature(2,:) = feature(2,:) + height/2;
    
     triangulatedPoints = triangulatePoints(newNVMCams(imageIdx+1), feature+1);
%     triangulatedPoints = triangulatePoints(cameraNVM(imageIdx+1), feature+1)
%     points3D(i).pos
    points3D(i).pos = triangulatedPoints;    
%     write down the 3d points onto the file
    fprintf(fid, '%f ', points3D(i).pos);
    fprintf(fid, '%d ', points3D(i).rgb);
    numOfMeasurement = size(points3D(i).measure,1);
    fprintf(fid, '%d ', numOfMeasurement );
    for j = 1:numOfMeasurement
        fprintf(fid, '%d %d %f %f ', points3D(i).measure(j,:));        
    end    
    fprintf(fid, '\n');
end



fclose(fid);











