function cleanNVM(nvmFileName)
fclose all;
nvmFileName = 'F:\Enliang\matlab\GMST_subprob\gmst\realData\halfcircle_jared\image\halfcircle_jared.nvm';

% [camera, points3D] = readNVM(nvmFileName);
[path, name, ext] = fileparts(nvmFileName);

bkupPath = [path, 'bk'];
if(~exist(bkupPath, 'dir'))
    copyfile( path, bkupPath);
end

nvmFileName_bk = fullfile(bkupPath, [name,ext]);
if(exist(path, 'dir'))
    rmdir(path,'s');
end
mkdir(path);

fid_src = fopen(nvmFileName_bk);
fid_dest = fopen(nvmFileName,'w');


assert(fid_src > 0); assert(fid_dest > 0);
% ------------------------------------------------------------------
str = fgets(fid_src); fprintf(fid_dest, str);
assert(all(strtrim(str) == 'NVM_V3'));

str = fgets(fid_src); fprintf(fid_dest, str);
str = fgets(fid_src); fprintf(fid_dest, str);

numOfImages = str2num(str);

for i = 1:numOfImages
    str = fgets(fid_src); fprintf(fid_dest, str);
%     copy the data based on fileName
    [imgFileName, ~ ] = textscan(str, '%s', 1);
    [~, nameOfImg, ~] = fileparts( imgFileName{1}{1} );
    
    copyfile( fullfile( bkupPath, [nameOfImg, '*'] ), path );
    
end

str = fgets(fid_src); fprintf(fid_dest, str);
str = fgets(fid_src); fprintf(fid_dest, str);

numOfPoints = str2num(str);
for i = 1:numOfPoints
    str = fgets(fid_src); fprintf(fid_dest, str); 
end

str = fgets(fid_src); fprintf(fid_dest, str);
fclose(fid_src); fclose(fid_dest);



