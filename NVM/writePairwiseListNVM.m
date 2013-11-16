function writePairwiseListNVM()


workingDir = 'F:\Enliang\data\church_Spilled_Blood\subsetImages';

% -------------------------------------------------------------

allImages = dir(fullfile(workingDir, '*.jpg'));

id = randperm(numel(allImages));
allImages = allImages(id);

fileListName = fullfile( workingDir, 'list.txt');
fid = fopen(fileListName, 'w');

for i = 1:numel(allImages)-1
    fileName_1 = fullfile( allImages(i).name);
    fileName_2 = fullfile( allImages(i+1).name);
    fprintf(fid, '%s %s\n', fileName_1, fileName_2);   
    
end

fclose(fid);