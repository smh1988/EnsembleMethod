if exist('AllImages.mat', 'file') == 2
    load('AllImages.mat');
else
    dataset_root='D:/QIAU/Semester five/Stereo Matching/Dataset';
    %dataset_root='F:/_pro_/matlab/MyWork/StereoMatching/MyProjct/git/Arash/ensemble method (idea)/Dataset';
        
    %[1 90] --> Middlebury2014
    %[91 478] --> KITTI2012
    %[479 692] --> Sintel
    %[693 713] -->Middlebury2006
    %[714 719] -->Middlebury2005
    
    AllImages=struct;
    count=1;
    % AllImages(1).datasetName='Middlebury2014';
    % AllImages(1).ImageName='Adirondack_Q';
    % AllImages(1).LImage='\Middlebury\2014\MiddEval3\trainingQ\Adirondack\im0.png';
    % [0 255]
    % AllImages(1).RImage='\Middlebury\2014\MiddEval3\trainingQ\Adirondack\im1.png';
    % AllImages(1).LDispOcc='\Middlebury\2014\MiddEval3\trainingQ\Adirondack\disp0GT.pfm';
    % double [1 maxDisp]
    % AllImages(1).RDispOcc='\Middlebury\2014\MiddEval3\trainingQ\Adirondack\disp1GT.pfm';
    % AllImages(1).LDispNoc=[];
    % AllImages(1).RDispNoc=[];
    % AllImages(1).LMask='\Middlebury\2014\MiddEval3\trainingQ\Adirondack\mask0nocc.png';
    % AllImages(1).RMask='\Middlebury\2014\MiddEval3\trainingQ\Adirondack\mask1nocc.png';
    % AllImages(1).maxDisp=73;
    % AllImages(1).size=[496 718 3];
    % AllImages(1).type=true; %train=>true , test=>false (so some vars are NaN)
    
    %% reading MiddlEval3 2014
    % getting every picture pair
    
    % Are you going to use the training or test set?
    imgset{1} = 'training';
    imgset{2} = 'test';
    
    % Specify which resolution you are using for the stereo image set (F, H, or Q?)
    imgsize{1} = 'Q';
    imgsize{2} = 'H';
    imgsize{3} = 'F';
    
    image_names{1} = 'Adirondack';    image_names{2} = 'ArtL';    image_names{3} = 'Jadeplant';    image_names{4} = 'Motorcycle';    image_names{5} = 'MotorcycleE';    image_names{6} = 'Piano';    image_names{7} = 'PianoL';    image_names{8} = 'Pipes';    image_names{9} = 'Playroom';    image_names{10} = 'Playtable';    image_names{11} = 'PlaytableP';    image_names{12} = 'Recycle';    image_names{13} = 'Shelves';    image_names{14} = 'Teddy';    image_names{15} = 'Vintage';
    ndisp = [290, 256, 640, 280, 280, 260, 260, 300, 330, 290, 290, 260, 240, 256, 760];
    
    
    for a=1:2 %different types
        for b=1:3 %different qualities
            for im_num = 1:15
                AllImages(count).datasetName='Middlebury2014';
                AllImages(count).ImageName=[image_names{im_num} '_' imgsize{b}];
                loc=[dataset_root '/Middlebury/2014/MiddEval3/' imgset{a} imgsize{b} '/' image_names{im_num}];
                AllImages(count).LImage=[loc '/im0.png'];
                AllImages(count).RImage=[loc '/im1.png'];
                if a==1
                    AllImages(count).LDispOcc=[loc '/disp0GT.pfm'];
                    AllImages(count).RDispOcc=[loc '/disp1GT.pfm'];
                    %AllImages(count).LDispNoc=[];
                    %AllImages(count).RDispNoc=[];
                    AllImages(count).LMask=[loc '/mask0nocc.png'];
                    AllImages(count).RMask=[loc '/mask1nocc.png'];
                end
                %tmp=imread([AllImages(count).LImage]);
                %AllImages(count).size=size(tmp);
                
                if a==1
                    AllImages(count).type=true; %train=>true , test=>false (so some vars are NaN)
                else
                    AllImages(count).type=false;
                end
                
                % Adjust the range of disparities to the chosen resolution
                if b==1
                    AllImages(count).maxDisp = round(ndisp(im_num)/4);
                elseif b==2
                    AllImages(count).maxDisp = round(ndisp(im_num)/2);
                else
                    AllImages(count).maxDisp = round(ndisp(im_num));
                end
                
                count=count+1;
            end
        end
        
    end
    
    
    
    %% reading KITTI
    % Are you going to use the training or test set?
    imgset{1} = 'training';
    imgset{2} = 'testing';
    
    LimageStr=  [dataset_root '/KITTI/2012/data_stereo_flow/' '%s' '/colored_0/%06d_10.png']; %first frame
    RimageStr=  [dataset_root '/KITTI/2012/data_stereo_flow/' '%s' '/colored_1/%06d_10.png'];
    LDispNocStr=[dataset_root '/KITTI/2012/data_stereo_flow/' '%s' '/disp_noc/%06d_10.png'];
    RDispNocStr=[dataset_root '/KITTI/2012/data_stereo_flow/' '%s' '/disp_noc/%06d_10.png'];
    LDispOccStr=[dataset_root '/KITTI/2012/data_stereo_flow/' '%s' '/disp_occ/%06d_10.png'];
    RDispOccStr=[dataset_root '/KITTI/2012/data_stereo_flow/' '%s' '/disp_occ/%06d_10.png'];
    
    for a=1:2 %different types
        for im_num = 0:193 %for testing it is 194! ignored for now
            AllImages(count).datasetName='KITTI2012';
            AllImages(count).ImageName=int2str(im_num);
            AllImages(count).LImage=sprintf(LimageStr,imgset{a},im_num);
            AllImages(count).RImage=sprintf(RimageStr,imgset{a},im_num);
            if a==1
                AllImages(count).LDispOcc=sprintf(LDispOccStr,imgset{a},im_num);
                AllImages(count).RDispOcc=sprintf(RDispOccStr,imgset{a},im_num);
                AllImages(count).LDispNoc=sprintf(LDispNocStr,imgset{a},im_num);
                AllImages(count).RDispNoc=sprintf(RDispNocStr,imgset{a},im_num);
                %AllImages(count).LMask=[];
                %AllImages(count).RMask=[];
            end
            %tmp=imread(AllImages(count).LImage);%checking...
            %AllImages(count).size=size(tmp);
            
            if a==1
                AllImages(count).type=true; %train=>true , test=>false (so some vars are NaN)
            else
                AllImages(count).type=false;
            end
            
            AllImages(count).maxDisp = 256;
            
            count=count+1;
        end
    end
    
    %% reading Sintel
    %this dataset just has training set and has one quality
    %but because there are many frames in each folder and they are somehow
    %similar, it is a good idea to skip some frames...
    frameSkip=5;%number of frames to be skipped

    image_names{1} = 'alley_1';image_names{2} = 'alley_2';image_names{3} = 'ambush_2';image_names{4} = 'ambush_4';image_names{5} = 'ambush_5';image_names{6} = 'ambush_6';image_names{7} = 'ambush_7';image_names{8} = 'bamboo_1';image_names{9} = 'bamboo_2';image_names{10} = 'bandage_1';image_names{11} = 'bandage_2';image_names{12} = 'cave_2';image_names{13} = 'cave_4';image_names{14} = 'market_2';image_names{15} = 'market_5';image_names{16} = 'market_6';image_names{17} = 'mountain_1';image_names{18} = 'shaman_2';image_names{19} = 'shaman_3';image_names{20} = 'sleeping_1';image_names{21} = 'sleeping_2';image_names{22} = 'temple_2';image_names{23} = 'temple_3';
    image_frames=[50 50 21 33 50 20 50 50 50 50 50 50 50 50 50 40 50 50 50 50 50 50 50];
    LimageStr=  [dataset_root '/Sintel/training/final_left/' '%s' '/frame_%04d.png'];
    RimageStr=  [dataset_root '/Sintel/training/final_right/' '%s' '/frame_%04d.png'];
    %LDispNocStr=[];
    %RDispNocStr=[];disparities_viz
    LDispOccStr=[dataset_root '/Sintel/training/disparities/' '%s' '/frame_%04d.png'];
    %RDispOccStr=[];
    LMaskStr=[dataset_root '/Sintel/training/occlusions/' '%s' '/frame_%04d.png'];
    %RMaskStr=[];
    %what the hell is :masks showing the out­of­frame pixels ???
    
    for im_set_num=1:23
        for im_frame_num=1:frameSkip:image_frames(im_set_num)
            AllImages(count).datasetName='Sintel';
            AllImages(count).ImageName=[image_names{im_set_num} '_frame_' int2str(im_frame_num)];
            AllImages(count).LImage=sprintf(LimageStr,image_names{im_set_num},im_frame_num);
            AllImages(count).RImage=sprintf(RimageStr,image_names{im_set_num},im_frame_num);
            AllImages(count).LDispOcc=sprintf(LDispOccStr,image_names{im_set_num},im_frame_num);
            %AllImages(count).RDispOcc=[];
            %AllImages(count).LDispNoc=[];
            %AllImages(count).RDispNoc=[];
            AllImages(count).LMask=sprintf(LMaskStr,image_names{im_set_num},im_frame_num);
            %AllImages(count).RMask=[];
            %tmp=imread(AllImages(count).LImage);%checking...
            %AllImages(count).size=size(tmp);
            AllImages(count).type=true; %train=>true , test=>false (so some vars are NaN)
            AllImages(count).maxDisp = 1024;% TODO: what maxDisp should it be?
            count=count+1;
        end
    end
    
    
    %% reading Middlebury 2006
    % this data set does not have test set
    % all third-size, 2-view, single illumination/exposure datasets
    
    % Specify which resolution you are using for the stereo image set (F, H, or Q?)
    imgsize{1} = 't';
    %imgsize{2} = 'h';
    %imgsize{3} = 'f';

    image_names{1} = 'Aloe';    image_names{2} = 'Baby1';    image_names{3} = 'Baby2';    image_names{4} = 'Baby3';    image_names{5} = 'Bowling1';    image_names{6} = 'Bowling2';    image_names{7} = 'Cloth1';    image_names{8} = 'Cloth2';    image_names{9} = 'Cloth3';    image_names{10} = 'Cloth4';    image_names{11} = 'Flowerpots';    image_names{12} = 'Lampshade1';    image_names{13} = 'Lampshade2';    image_names{14} = 'Midd1';    image_names{15} = 'Midd2';  image_names{16} = 'Monopoly'; image_names{17} = 'Plastic'; image_names{18} = 'Rocks1'; image_names{19} = 'Rocks2'; image_names{20} = 'Wood1'; image_names{21} = 'Wood2';
    %mindisp = [];
    ndisp=[70,45,52,51,77,66,57,76,55,67,60,65,65,69,62,53,65,57,56,72,72];%these are calculated per image and not provided by the data set!
    %The exception is intensity 0, which means unknown disparity
    
    for a=1:1;%just has train set
        for b=1:1 %different qualities (curently reading third-size)
            for im_num = 1:21
                AllImages(count).datasetName='Middlebury2006';
                AllImages(count).ImageName=[image_names{im_num} '_' imgsize{b}];
                loc=[dataset_root '/Middlebury/2006/'  imgsize{b} '2' '/' 'ALL-2views/' image_names{im_num}];
                AllImages(count).LImage=[loc '/view1.png'];
                AllImages(count).RImage=[loc '/view5.png'];
                if a==1
                    AllImages(count).LDispOcc=[loc '/disp1.png'];
                    AllImages(count).RDispOcc=[loc '/disp5.png'];
                    AllImages(count).LDispNoc=[];
                    AllImages(count).RDispNoc=[];
                    AllImages(count).LMask=[];
                    AllImages(count).RMask=[];
                end
                %tmp=imread([AllImages(count).LImage]);
                %AllImages(count).size=size(tmp);
                
                if a==1
                    AllImages(count).type=true; %train=>true , test=>false (so some vars are NaN)
                else
                    AllImages(count).type=false;
                end
                
                % Adjust the range of disparities to the chosen resolution
%                 if b==1
                     AllImages(count).maxDisp = 85;%FIX: as "2016-correctness prediction..." said 
%                 elseif b==2
%                     AllImages(count).maxDisp = round(ndisp(im_num)/2);
%                 else
%                     AllImages(count).maxDisp = round(ndisp(im_num));
%                 end
                
                count=count+1;
            end
        end
        
    end
    
    %% reading Middlebury 2005
    % 3 images of this data set does not have ground trouth
    % all third-size, 2-view, single illumination/exposure datasets
    
    %Specify which resolution you are using for the stereo image set (F, H, or Q?)
    imgsize{1} = 't';
    %imgsize{2} = 'h';
    %imgsize{3} = 'f';

    image_names{1} = 'Art';    image_names{2} = 'Books';    image_names{3} = 'Dolls';    image_names{4} = 'Laundry';    image_names{5} = 'Moebius';    image_names{6} = 'Reindeer';    
    %mindisp = [];
    ndisp=[75,74,74,77,73,67];
    %The exception is intensity 0, which means unknown disparity
    
    for a=1:1;%just has train set
        for b=1:1 %different qualities (curently reading third-size)
            for im_num = 1:6
                AllImages(count).datasetName='Middlebury2005';
                AllImages(count).ImageName=[image_names{im_num} '_' imgsize{b}];
                loc=[dataset_root '/Middlebury/2005/'  imgsize{b} '2' '/' 'ALL-2views/' image_names{im_num}];
                AllImages(count).LImage=[loc '/view1.png'];
                AllImages(count).RImage=[loc '/view5.png'];
                if a==1
                    AllImages(count).LDispOcc=[loc '/disp1.png'];
                    AllImages(count).RDispOcc=[loc '/disp5.png'];
                    AllImages(count).LDispNoc=[];
                    AllImages(count).RDispNoc=[];
                    AllImages(count).LMask=[];
                    AllImages(count).RMask=[];
                end
                %tmp=imread([AllImages(count).LImage]);
                %AllImages(count).size=size(tmp);
                
                if a==1
                    AllImages(count).type=true; %train=>true , test=>false (so some vars are NaN)
                else
                    AllImages(count).type=false;
                end
                
                % Adjust the range of disparities to the chosen resolution
%                 if b==1
                     AllImages(count).maxDisp =85;%FIX: as "2016-correctness prediction..." said
%                 elseif b==2
%                     AllImages(count).maxDisp = round(ndisp(im_num)/2);
%                 else
%                     AllImages(count).maxDisp = round(ndisp(im_num));
%                 end
                
                count=count+1;
            end
        end
        
    end
    save('AllImages.mat','AllImages');
    
    
end

