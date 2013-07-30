function writePairwiseListNVM()


workingDir = 'F:\Enliang\temp\trajectories\data\jared\MVI_2171';

% -------------------------------------------------------------

allImages = dir(fullfile(workingDir, '*.ppm'));

fileListName = fullfile( workingDir, 'list.txt');
fid = fopen(fileListName, 'w');

for i = 1:numel(allImages)-1
    fileName_1 = fullfile( allImages(i).name);
    fileName_2 = fullfile( allImages(i+1).name);
    fprintf(fid, '%s %s\n', fileName_1, fileName_2);   
    
end

fclose(fid);