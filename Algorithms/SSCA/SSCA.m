function [ imgL_d ] = SSCA( imgL,imgR,DisparityRange)

%% make temp files
%make name of files
a = mfilename;
p = mfilename('fullpath');
p = p(1:end-length(a));
backFolder=cd(p);

namePerfix=num2str( ceil(rand()*1000000000));

lImg = [tempdir namePerfix ,'tempL.png' ];
rImg = [tempdir namePerfix ,'tempR.png' ];
lDis = [tempdir namePerfix ,'dispL.png' ];
%rDis = strcat(namePerfix ,'dsipR.png' );

maxDis = DisparityRange(2);
disScale  =1;

%Cost Computation METHOD : GRD CEN BSM CG
ccName='CG';

%Cost Aggregation METHOD : GF BF BOX NL ST
caName='BF';

%Post Process METHOD : SG WM NP
ppName='NP';

%C_ALPHA
costAlpha='0';

%make random name of file

imwrite(imgL,lImg);
imwrite(imgR,rImg);


%% exec command
% Usage: [CC_METHOD] [CA_METHOD] [PP_METHOD] [C_ALPHA] [lImg] [rImg] [lDis] [maxDis] [disSc]
command = ['!SSCA.exe ' ccName '  ' caName '  ' ppName '  ' costAlpha ' "' lImg '" "' rImg '" "' lDis '" ' num2str( maxDis ) ' ' num2str( disScale )]
eval(command);

imgL_d= double(imread(lDis));

%% remove temp files
delete (lImg)
delete( rImg)
delete (lDis)
%delete( rDis)

%% show result
cd(backFolder);

display(['finish' namePerfix] )
end
