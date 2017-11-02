function [ dir ] = getDatasetDir( datasetName, type )
%GETDATASETDIR this function gets the name and type of the dataset and
%returns the dir
if (strcmpi(type,'test')==0)&&( strcmpi(type,'train')==0)
    error('Type not defined.');
end

base='D:\QIAU\Semester five\Stereo Matching\Dataset';
switch datasetName
    case 'Middlebury'
        if strcmpi(type,'test')
            dir=[base,'\Middlebury\2014\MiddEval3\test'];
        else
            dir=[base,'\Middlebury\2014\MiddEval3\training'];
        end
    case 'KITTI'
        if strcmpi(type,'test')
            dir=[base,'\KITTI\data_stereo_flow\testing'];
        else
            dir=[base,'\KITTI\data_stereo_flow\training'];
        end
    case 'Sintel'
        if strcmpi(type,'test')
            error('This dataset does not have test data.');
        else
            dir=[base,'\Sintel\training'];
        end
    case {'Virtual KITTI','UE4','Tsukuba','CityScapes'}
        error('This dataset is not ready yet');
        
    otherwise
            error('This dataset does not exist');
end
    
    
end
