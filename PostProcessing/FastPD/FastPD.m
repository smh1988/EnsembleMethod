function MRF_labeling = FastPD(CostVolume, numlabels ,dispImg,Cost,imgL3D)
%https://github.com/srdjankrstic/defocus
bias=1;
scale=1000;
lambda=0.25;

input_file = tempname('.');
output_file = tempname('.');

fid = fopen(input_file, 'wb');
if fid == -1
    error(['Cannot open file ' results_fname]);
end

w = size(CostVolume, 1);
h = size(CostVolume, 2);
numpoints = h * w;

numpairs = 2 * h * w - h - w;
maxIters = 100;
type = 'uint32';

fwrite(fid, numpoints, type);
fwrite(fid, numpairs, type);
fwrite(fid, numlabels, type);
fwrite(fid, maxIters, type);

%CostVolume=CostVolume+bias;
% HACK
avg = mean(CostVolume(:));
stdev = std(CostVolume(:));
CostVolume(CostVolume> avg + 2*stdev) = avg + 2 * stdev;
CostVolume = normalize(CostVolume);

fwrite(fid,int32( CostVolume*scale), type);

% pairs (each pixel is neighbor with 4 adjacent)
for i = 1:h
    row = w * (i - 1);
    temp = [row, kron((row + 1):(row + w - 2), [1 1]), w - 1];
    fwrite(fid, temp, type);
end
temp = zeros(1, 2 * w * (h - 1));
temp(1:2:end) = 0 : (w * (h - 1) - 1);
temp(2:2:end) = w : (w * h - 1);


%	fread( _pairs , sizeof(int ), _numpairs*2 , fp );
fwrite(fid, temp, type);


% inter-label costs (0 if same, 1 if adjacent, 2 otherwise)
labelcosts = 2 * ones(numlabels, numlabels) - ...
    2 * eye(numlabels) - ...
    1 * diag(ones(numlabels - 1, 1), 1) - ...
    1 * diag(ones(numlabels - 1, 1), -1);
%labelcosts=ones(numlabels, numlabels)-eye(numlabels);

%	fread( _dist  , sizeof(Real), _numlabels*_numlabels, fp );
fwrite(fid, labelcosts, type);

Esmooth=zeros(w,h);%(9) formola
p=double(imgL3D );
   
for i=2:w-1
	for j=2:h-1
		Esmooth(i,j)= ...
            Wpq(p(i,j,:),p(i-1,j,:),dispImg(i,j),dispImg(i-1,j)) + ...
            Wpq(p(i,j,:),p(i+1,j,:),dispImg(i,j),dispImg(i+1,j)) + ...
            Wpq(p(i,j,:),p(i,j-1,:),dispImg(i,j),dispImg(i,j-1)) + ...
            Wpq(p(i,j,:),p(i,j+1,:),dispImg(i,j),dispImg(i,j+1)) ;
	end
end
Edata=Cost+bias;
Ed=((Edata+Esmooth*lambda))*scale;
fwrite(fid,Ed, type);%wcost
fclose(fid);

% run FastPD
commandStr = ['"'  mfilename('fullpath') '/../FastPD.exe" ' input_file ' ' output_file]
result=system(commandStr);
if(result~=0)
    error(['FastPD.exe return error:' num2str(result)]);
end
MRF_labeling = get_MRF_labeling(output_file);
MRF_labeling = reshape(MRF_labeling, w,h)+1;
%    MRF_labeling = max(max(MRF_labeling)) - MRF_labeling;

% clean up
%if (~DEBUG)
delete(input_file, output_file);
%end

end
