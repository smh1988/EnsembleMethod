% prefix='cones';
% %images are B&W
% I1 = imread(['img/' prefix '_left.pgm']);
% I2 = imread(['img/' prefix '_right.pgm']);

I1 = imread('Adirondack/im0.png');
I2 = imread('Adirondack/im1.png');
imgGT=readpfm('Adirondack/disp0GT.pfm');
imgMask=imread('Adirondack/mask0nocc.png');
if(size(I1,3)==3)
    I1=rgb2gray(I1);
end
if(size(I2,3)==3)
    I2=rgb2gray(I2);
end
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
param.disp_max              = 64;
param.support_threshold     = 0.95;
param.support_texture       = 10;
param.candidate_stepsize    = 5;
param.incon_window_size     = 5;
param.incon_threshold       = 5;
param.incon_min_support     = 5;
param.add_corners           = 1;
param.grid_size             = 20;
param.beta                  = 0.02;
param.gamma                 = 15;
param.sigma                 = 3;
param.sradius               = 3;
param.match_texture         = 0;
param.lr_threshold          = 2;
param.speckle_sim_threshold = 1;
param.speckle_size          = 200;
param.ipol_gap_width        = 5000;
param.filter_median         = 1;
param.filter_adaptive_mean  = 0;
param.postprocess_only_left = 0;
param.subsampling           = 0;
tic
% perform actual matching
[imgL_d,imgR_d] = elasMex(I1',I2',param);
toc
imgL_d=imgL_d';
imgR_d=imgR_d';

Error = abs(imgL_d - imgGT) > 4;
imgMask = imgMask == 255;
Error(~imgMask) = 0;
ErrorRate = sum(Error(:))/sum(imgMask(:))*100;

figure; imshow(imgR_d,[])
figure;imshow(imgL_d,[])