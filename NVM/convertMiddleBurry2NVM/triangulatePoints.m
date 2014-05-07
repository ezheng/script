function triangulatedPoints = triangulatePoints(camera, feature)


numOfCameras = numel(camera);

A = zeros( 2 * numOfCameras, 4);

for i = 1:numOfCameras
   A(i*2 - 1,:) = feature(1,i) * camera(i).P(3,:) - camera(i).P(1,:);
   A(i*2,:) =     feature(2, i) * camera(i).P(3,:) - camera(i).P(2,:);
        
%    normalization? 
    A(i*2 - 1,:) = A(i*2-1,:) / norm(A(i*2 - 1,:));
    A(i*2,:) = A(i*2,:) / norm(A(i*2,:));
    
end

[~, ~, V] = svd(A);
triangulatedPoints = V(:, end);

for i = 1:4
triangulatedPoints(i, :) = triangulatedPoints(i, :) ./ triangulatedPoints(4, :);
end

triangulatedPoints = triangulatedPoints(1:3,:);





















