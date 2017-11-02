@echo off
cls
echo Usage: [CC_METHOD] [CA_METHOD] [PP_METHOD] [C_ALPHA] [lImg] [rImg] [lDis] [maxDis] [disSc]

rem 	string ccName = argv[ 1 ];Cost Computation METHOD : GRD CEN BSM CG
Set ccName=CG
rem		string caName = argv[ 2 ];Cost Aggregation METHOD : GF BF BOX NL ST
Set caName=BF
rem		string ppName = argv[ 3 ];Post Process METHOD : SG WM NP
Set ppName=NP
rem 	double costAlpha = atof( argv[ 4 ] );C_ALPHA
Set costAlpha=0
rem 	string lFn = argv[ 5 ];lImg
Set lFn=814723687tempL.png
rem 	string rFn = argv[ 6 ];rImg
Set rFn=814723687tempR.png
rem 	string lDisFn = argv[ 7 ];lDis
Set lDisFn=out_%ccName%_%caName%_%ppName%.png
rem 	int maxDis = atoi( argv[ 8 ] );maxDis
Set maxDis=64
rem 	int disSc  = atoi( argv[ 9 ] );disSc
Set disSc=4

SSCA.exe %ccName% %caName% %ppName% %costAlpha% %lFn% %rFn%  %lDisFn% %maxDis% %disSc% 
%lDisFn%