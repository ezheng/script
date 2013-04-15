function data1 = loadFLTFile( fileName )

% fileName = 'fountain0004_DepthMap.flt';
% fileName = 'depthMap110.txt';
fid = fopen(fileName);

line = fscanf(fid, '%d&%d&%d&',[1,3]);
width=line(1);
height=line(2);
channels=line(3); 
num=width*height*channels;
D = fread(fid,num,'float');
fclose(fid);


data1=reshape(D,[width,height]);
data1 = data1';
%  figure(); imagesc(data1);
%  axis equal;
