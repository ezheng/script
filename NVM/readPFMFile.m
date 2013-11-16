function image = readPFMFile(fileName, isShow)

if(nargin == 1)
    isShow = true;
end
% fileName = 'F:\Enliang\virtualMachine\shareFolder\brandenburg2\images\depth-L0_0000.pfm';

fid = fopen(fileName, 'r');

line = fgetl(fid);
line = fgetl(fid);
data = textscan(line, '%f %f %f');
width = data{1};
height = data{2};

image = fread( fid, width * height, 'float32' );
image = reshape(image, width, height);
image = image';
image = flipud(image);

if(isShow)
    figure(2);
    imagesc(image); axis equal;
end

fclose(fid);

