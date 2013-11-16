function generatePlyFromDepthmap(K, depthmap, img, outputFileName, sample)

% depthFileName = 'F:\Enliang\data\fountain\results\depthMap005.txt';
% outputFileName = 'xxx.ply';
% depthFileName = 'F:\Enliang\material\Enrique\0005.png.flt';
% img = imread('F:\Enliang\data\fountain\image\0005.png');
% depthmap = loadFLTFile(depthFileName); 

if(nargin == 4)
    sample = 1;
end

% sample = 2; 

% K = [2759.480000 0.000000 1520.690000 0.000000 2764.160000 1006.810000 0.000000 0.000000 1.000000];
% K = reshape(K,3,3); K = K';
% R = [0.890856000000 -0.454283000000 -0.001584340000;
%     -0.021163800000 -0.044985700000 0.998763000000;
%     -0.453793000000 -0.889721000000 -0.049690100000];
% T = [9.318103765596 -0.544475235672 -9.015994315384]';
% img = im2double(img);

% find the median

filteredDepth = medfilt2(depthmap, [5 5]);
depthmap( abs(depthmap - filteredDepth) > 5 ) = 0;


[height, width] = size(depthmap);

x = [round(0.15*width) : sample : round( 0.85* width)];
y = [round(0.15*height) : sample : round( 0.85* height)];
[X, Y] = meshgrid(x, y);
X = X(:)';
Y = Y(:)';
ind = sub2ind([height, width], Y, X);
depthValue = depthmap(ind);


RR = img(:,:,1); GG = img(:,:,2); BB = img(:,:,3);
colorR = RR(ind); colorG = GG(ind); colorB = BB(ind);
CC = [colorR', colorG', colorB'];

points2D = K\([X; Y; ones(size(X))] .* repmat(depthValue, 3, 1)); 
% points3D = [R', -R'*T] * [points2D; ones(1, size(points2D, 2)) ];
points3D = [points2D; ones(1, size(points2D, 2)) ];
for i = 1:numel(X)      % testing (for debug purpose)
   assert(depthValue(i) == depthmap(Y(i), X(i)) );
end

writePlyFile(outputFileName, points3D, CC);

% figure(); 
% scatter3(points3D(1,:), points3D(2,:), points3D(3,:), 3, CC);
% xlabel('x'); ylabel('y'); zlabel('z'); axis equal

end

function writePlyFile(outputFileName, data, color)
% [height, width, ~] = size(depth);
    ptsnum = size(data,2);
    fid = fopen(outputFileName, 'w');
    fprintf(fid, 'ply\n');
    fprintf(fid, 'format ascii 1.0\n');
    fprintf(fid, 'element vertex %d\n', ptsnum);
    fprintf(fid, 'property float x\n');
    fprintf(fid, 'property float y\n');
    fprintf(fid, 'property float z\n');
    fprintf(fid, 'property uchar red\n');
    fprintf(fid, 'property uchar green\n');
    fprintf(fid, 'property uchar blue\n');
    fprintf(fid, 'end_header\n');    
    for i = 1 : size(data,2)
%         disp(row/height);
%         for col = 1 : width
            fprintf(fid, '%f %f %f %u %u %u\n', data(1,i), data(2,i), data(3,i), color(i,1),color(i,2),color(i,3) );
%         end
    end
    fclose(fid);
    
end


