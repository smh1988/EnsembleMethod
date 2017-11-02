function avgError = ELASParametric2(Params,ManipImages,tau)
%in version 2, we dont have global variables.
%global ManipImages tau;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parameter settings %%%%%%%%%%%%%%%%%%%%%%%%%%%
% // parameter settings
%   struct parameters {
%     int32_t disp_min;               // min disparity
%     int32_t disp_max;               // max disparity
%     float   support_threshold;      // max. uniqueness ratio (best vs. second best support match)
%     int32_t support_texture;        // min texture for support points
%     int32_t candidate_stepsize;     // step size of regular grid on which support points are matched
%     int32_t incon_window_size;      // window size of inconsistent support point check
%     int32_t incon_threshold;        // disparity similarity threshold for support point to be considered consistent
%     int32_t incon_min_support;      // minimum number of consistent support points
%     bool    add_corners;            // add support points at image corners with nearest neighbor disparities
%     int32_t grid_size;              // size of neighborhood for additional support point extrapolation
%     float   beta;                   // image likelihood parameter
%     float   gamma;                  // prior constant
%     float   sigma;                  // prior sigma
%     float   sradius;                // prior sigma radius
%     int32_t match_texture;          // min texture for dense matching
%     int32_t lr_threshold;           // disparity threshold for left/right consistency check
%     float   speckle_sim_threshold;  // similarity threshold for speckle segmentation
%     int32_t speckle_size;           // maximal size of a speckle (small speckles get removed)
%     int32_t ipol_gap_width;         // interpolate small gaps (left<->right, top<->bottom)
%     bool    filter_median;          // optional median filter (approximated)
%     bool    filter_adaptive_mean;   // optional adaptive mean filter (approximated)
%     bool    postprocess_only_left;  // saves time by not postprocessing the right image
%     bool    subsampling;            // saves time by only computing disparities for each 2nd pixel
%                                     // note: for this option D1 and D2 must be passed with size
%                                     //       width/2 x height/2 (rounded towards zero)


%for middlebury...
param.disp_min              = 1;
param.disp_max              = 0;%it should change for aevery image set
param.support_threshold     = 0.95;%=0.95  [0.6    0.99]
param.support_texture       = 10;%10   [5  15]
param.candidate_stepsize    = 5;%5     [3   10]
param.incon_window_size     = 5;%5     [3   10]
param.incon_threshold       = 5;%5     [3   10]
param.incon_min_support     = 5;%5     [3   10]
param.add_corners           = 1;
param.grid_size             = 20;%20     [10   50]
param.beta                  = Params(1);%=0.02  [0.005   0.5]
param.gamma                 = Params(2);%=3     [0      40]
param.sigma                 = Params(3);%=1     [0.1    5]
param.sradius               = Params(4);%=3     [1      10]
param.match_texture         = 0;
param.lr_threshold          = 2;%2     [1   10]
param.speckle_sim_threshold = 1;
param.speckle_size          = 200;%200     [100   400]
param.ipol_gap_width        = 5000;%5000     [1000   10000]
param.filter_median         = 1;
param.filter_adaptive_mean  = 0;
param.postprocess_only_left = 1;
param.subsampling           = 0;


err=zeros(size(ManipImages,2),1);
for imgNum=1:size(ManipImages,2)
    % perform actual matching
    param.disp_max=ManipImages(imgNum).maxDisp;
    [imgL_d,~] = elasMex(ManipImages(imgNum).imgL',ManipImages(imgNum).imgR',param);
    imgL_d=imgL_d';
    
    %EvaluateDisp
    Error = abs(imgL_d - ManipImages(imgNum).imgGT) > tau;
    Error(~ManipImages(imgNum).imgMask) = 0;
    err(imgNum) = sum(Error(:))/sum(ManipImages(imgNum).imgMask(:))*100;
end

avgError=mean(err);
display(num2str(avgError));
end