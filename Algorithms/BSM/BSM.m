function [ imgL_d,imgR_d ] = BSM( imgL,imgR,DisparityRange)
fileLocation=mfilename('fullpath');
a=strfind(fileLocation,'\');
fileLocation=fileLocation(1:a(end)-1);


%% make temp files
%make name of files
namePerfix=num2str( ceil(rand()*1000000000));

lImg = [tempdir namePerfix  'tempL.png' ];
rImg = [tempdir namePerfix  'tempR.png' ];
lDis = [ namePerfix 'dispL.png' ];
rDis = [ namePerfix  'dsipR.png' ];

maxDis = DisparityRange(2);
disScale  = 1;
newMethod = 0;
%make random name of file

imwrite(imgL,lImg);
imwrite(imgR,rImg);


%% exec command
command = ['!"' fileLocation '/BinaryStereoMatching.exe" "' lImg '" "' rImg '" "' lDis '" "' rDis  '" ' num2str( maxDis ) ' ' num2str( disScale ) ' ' num2str( newMethod  ) ''];
eval(command);

imgL_d=double(imread(lDis));
imgR_d=double(imread(rDis));

%% remove temp files
delete( lImg)
delete (rImg)
delete (lDis)
delete( rDis)

%% show result
display(['finish' namePerfix] )
end
