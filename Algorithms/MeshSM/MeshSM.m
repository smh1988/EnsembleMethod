function [ imgL_d,imgR_d ] = MeshSM( imgL,imgR,DisparityRange)
fileLocation=mfilename('fullpath');
a=strfind(fileLocation,'\');
fileLocation=fileLocation(1:a(end)-1);


%% make temp files
%make the name of files
namePrefix=num2str( ceil(rand()*1000000000));

lImg = [tempdir namePrefix  'tempL.png' ];
rImg = [tempdir namePrefix  'tempR.png' ];
Dis = [ namePrefix 'disp' ];
%rDis = [ namePrefix  'dispR.png' ];

maxDis = DisparityRange(2);

imwrite(imgL,lImg);
imwrite(imgR,rImg);

%FIXME: saving png is not good for disparity ranges more than 256!
%% exec command
command = ['!"' fileLocation '/MeshStereo.exe" "' lImg '" "' rImg '" "' Dis '" ' num2str( maxDis ) ''];
eval(command);

imgL_d=double(imread([Dis, 'L.png']));
imgR_d=double(imread([Dis, 'R.png']));

%% remove temp files
delete( lImg)
delete (rImg)
delete ([Dis, 'L.png'])
delete( [Dis, 'R.png'])

%% show result
display(['finish' namePrefix] )
end