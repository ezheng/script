function checkBestKCost

folder = 'F:\Enliang\data\germany2\results';

numOfTargetImages = 432;
% --------------------------------------------------

for i = 1:numOfTargetImages
    fullfileName = fullfile(folder, sprintf( 'depthMap000.txt_matchCost%d.txt',i-1));
    if(i == 1);
         a = loadFLTFile(fullfileName);
        allCost = zeros(size(a,1),size(a,2), numOfTargetImages);
        allCost(:,:,1) = a;
    else
        allCost(:,:,i) = loadFLTFile(fullfileName);
    end
end

allCost = sort(allCost, 3);
a = mean( allCost(:,:,1:4), 3);
% a(a>0.1) = -10;
% satisfied = allCost;
% satisfied( allCost > 0.4) = 0;
% satisfied( allCost <= 0.4) = 1;
% a = sum(satisfied,3);
%  a = sum( allCost( allCost < 0.6),3 );

% satisfied = mean(satisfied,3);
% satisfied(satisfied < 0.3) = -100;
% figure(); imagesc(satisfied); axis equal;
% 
% d = allCost(70,251,:); d= d(:)';
% figure(); plot(d);


for i = 1:4
    b = loadFLTFile(  fullfile(folder, ['depthMap000.txt_BestMatchCost',num2str(i-1),'.txt']) );
    a = allCost(:,:,i);
    figure(i); imagesc(b-a); axis equal;
end


