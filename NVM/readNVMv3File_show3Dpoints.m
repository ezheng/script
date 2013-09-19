function readNVMv3File_show3Dpoints( filename, sampleRate)

% filename = 'model.nvm';
if( nargin < 2)
    sampleRate = 0.01;
end

fid = fopen(filename,'r');

% Read version.
line = nextline(fid);
if ~strcmp(strtrim(line),'NVM_V3')
    error('Not an NVM_V3 file.');
end

% Read cameras.
line = nextline(fid);
numCameras = sscanf(line,'%f',1);
imnames = cell(numCameras,1);

for n=1:numCameras
    if( mod(n,20) == 0)
        fprintf(1, 'reading cameras... %%%2.3f percent is finished\n', n/numCameras*100);
    end
    
    line = nextline(fid);
    savedCams{n} = line;
    
    name = sscanf(line,'%s',1);
    vals = sscanf(line(length(name)+1:end),'%f');
%     f = vals(1);
%     R = quaternionToMatrix(vals(2:5));
%     C = vals(6:8);    
%     [workingPath, filePath, fileName] = getFolderAndCopyFile(name);
%     sourceDir = fullfile(workingPath, filePath, [fileName, '.jpg']);
    sourceDir = [name,'jpg'];
    imnames{n} = sourceDir;
end

% Read 3d points and tracks.
line = nextline(fid);
numPoints = sscanf(line,'%f',1);
points = zeros(numPoints,3);

for n=1:numPoints
    if( mod(n,100) == 0)
        fprintf(1, 'reading points... %%%2.3f percent is finished\n', n/numPoints*100);
    end
    line = nextline(fid);    
    vals = sscanf(line,'%f');
    points(n,:) = vals(1:3);
%     color = vals(4:6);
    numOfCams = vals(7);    
%     pointsInfo = [pointsInfo, vals(1:7)] ;    
    camInfo = vals(8:end);
    assert(numel(camInfo) == numOfCams * 4);
%     allCamInfo = [allCamInfo, reshape(camInfo, 4,[])];
%     the first row is image index
%     the second row is the feature index
end
fclose(fid);

fprintf(1, 'showing the image...\n');

step = floor(size(numPoints * sampleRate));
points = points(1:step:end,:);

figure(1);
% subplot(3,1,1);
plot3(points(:,1), points(:,2), points(:,3), '*');
axis equal;
xlabel('x');
ylabel('y');
zlabel('z');
title('3d points');
view(0,90);

% subplot(3,1,2);
figure(2);
plot3(points(:,1), points(:,2), points(:,3), '*');
axis equal;
xlabel('x');
ylabel('y');
zlabel('z');
title('3d points');
view(90,0);

figure(3)
% subplot(3,1,3);
plot3(points(:,1), points(:,2), points(:,3), '*');
axis equal;
xlabel('x');
ylabel('y');
zlabel('z');
title('3d points');
view(0,0);



% figure(4);
% subplot(3,1,1);
% plot(points(:,1), ones(size(points,1),1), '*');
% title('x axis');
% 
% subplot(3,1,2);
% plot(points(:,2), ones(size(points,1),1), '*');
% title('y axis');
% 
% subplot(3,1,3);
% plot(points(:,2), ones(size(points,1),1), '*');
% title('z axis');

end


function line = nextline( fid )
line = fgetl(fid);
[~,errnum] = ferror(fid);
while(isempty(line) && errnum==0)
    line = fgetl(fid);
    [~,errnum] = ferror(fid);
end
end