%2017-Robust Stereo Matching code-SNP_RSM - modified code
function [confidence, methods] = fn_confidence_measure(image, dsiL,dsiR, max_disparity, min_disparity, confParam)
image=rgb2gray(image);
% Compute left and right disparity maps. 
[~, disparityL] = min(dsiL, [], 3); 
disparityL = disparityL + min_disparity -1; 

% generate right dsi. 
%[dsiR, disparityR] = dsi_left2right(dsiL, min_disparity, max_disparity); 
[~, disparityR] =min(dsiR, [], 3); 
disparityR = disparityR - min_disparity + 1;

% Reshape DSI and compute sorted DSI. 
[M, N, k] = size(dsiL);
dsi = reshape(dsiL, [M*N k])';
dsi_s = sort(dsi); % sometimes sorted costs are convinient to use. 

% Variables and parameters. 
methods = cell(1, 3); 
confidence = zeros(22, M*N);
cnt = 1;

% Compute c_1, c_2, c^_2 in the paper as well as sum of matching costs and
% number of inflection points (NOI). 
[c_1, c_2, c_hat_2, c_sum, NOI] = compute_base_costs(dsi);

% Transform to probability density functions. 
pdf = bsxfun(@rdivide, exp(-dsi/confParam.sigma^2), sum(exp(-dsi/confParam.sigma^2)));

% 01. Minimum Cost.
if confParam.useCost == true 
    confidence(cnt, :) = -c_1; 
    methods{cnt} = 'MC'; 
    cnt = cnt + 1;
end

% 02. Peak ratio. 
if confParam.usePKR == true 
    confidence(cnt, :) = c_hat_2 ./ c_1; 
    methods{cnt} = 'PKR';
    cnt = cnt + 1; 
end

% 03. Naitve Peak ratio. 
if confParam.usePKRN == true
    confidence(cnt, :) = c_2 ./ c_1;
    methods{cnt} = 'PKRN'; 
    cnt = cnt + 1; 
end

% 04. Maximum margin. 
if confParam.useMM == true 
    confidence(cnt, :) = c_hat_2 - c_1; 
    methods{cnt} = 'MM'; 
    cnt = cnt + 1; 
end

% 05. Naive maximum margin. 
if confParam.useMMN == true 
    confidence(cnt, :) = c_2 - c_1;
    methods{cnt} = 'MMN'; 
    cnt = cnt + 1; 
end

% 06. Winner margin. 
if confParam.useWM == true 
    confidence(cnt, :) = (c_hat_2 - c_1)./c_sum; 
    methods{cnt} = 'WMN'; 
    cnt = cnt + 1; 
end

% 07. Naive winner margin.
if confParam.useWMN == true 
    confidence(cnt, :) = (c_2 - c_1)./c_sum;
    methods{cnt} = 'WMN'; 
    cnt = cnt + 1; 
end

% 08. Left-right difference. 
if confParam.useLRD == true
    confidence(cnt, :) = compute_LRD(disparityL, c_1, c_2, dsiR);
    methods{cnt} = 'LRD'; 
    cnt = cnt + 1; 
end

% 09. Local curvature.
if confParam.useLC == true
    confidence(cnt, :) = compute_LC(dsi);
    methods{cnt} = 'LC'; 
    cnt = cnt + 1; 
end

% 10. Perturbation.
if confParam.usePER == true
    confidence(cnt, :) = compute_perturbation(dsi_s);
    methods{cnt} = 'PER';
    cnt = cnt + 1; 
end

% 11. Attainable maximum likelihood. 
if confParam.useAML == true
    confidence(cnt, :) = compute_AML(dsi_s); 
    methods{cnt} = 'AML'; 
    cnt = cnt + 1; 
end

% 12. Number of inflection (NOI) points. 
if confParam.useNOI == true
    confidence(cnt, :) = NOI; 
    methods{cnt} = 'NOI'; 
    cnt = cnt + 1; 
end

% Probabilistic measures. 
% 12. Maximum likelihood measure. 
if confParam.useMLM == true
    confidence(cnt, :) = max(pdf); 
    methods{cnt} = 'MLM'; 
    cnt = cnt + 1; 
end

% 13. Negative entropy measure. 
if confParam.useNEM == true 
    confidence(cnt, :) = -sum((pdf).*log(pdf)); 
    methods{cnt} = 'NEM'; 
    cnt = cnt + 1; 
end

% 14. Left-right consistency (LRC). 
if confParam.useLRC == true
    confidence(cnt, :) = compute_LRC(disparityL, disparityR);
    methods{cnt} = 'LRC'; 
    cnt = cnt + 1;
end

% 15. Disparity variance (VAR) measures.
if confParam.useDispVar == true
    for k = 1:length(confParam.radius_DVAR)
        confidence(cnt, :) = -compute_Var(disparityL, confParam.radius_DVAR(k)); 
        methods{cnt} = sprintf('DVAR%d', confParam.radius_DVAR(k)); 
        cnt = cnt + 1;
    end
end

% 16. Median deviation (MDD). 
if confParam.useMedDev == true 
    for k = 1:length(confParam.radius_MDD)
        confidence(cnt, :) = -compute_MedDev(disparityL, confParam.radius_MDD(k)); 
        methods{cnt} = sprintf('MDD%d', confParam.radius_MDD(k));
        cnt = cnt + 1;
    end
end

% 17. Distance to Discontinuity (DTD). 
if confParam.useDTD == true
   confidence(cnt, :) = compute_DD(disparityL); 
   methods{cnt} = 'DTD'; 
   cnt = cnt + 1; 
end

% 18. Magnitude of image gradients. 
if confParam.useGRAD == true
    confidence(cnt, :) = compute_ImGrad(image);
    methods{cnt} = 'GRAD'; 
    cnt = cnt + 1; 
end

% 19. Distance to edge (DTE). 
if confParam.useDTE == true
   confidence(cnt, :) = compute_DD(image); 
   methods{cnt} = 'DTE'; 
   cnt = cnt + 1;
end

% Prior-based confidence measures. 
% 20. prior-based confidence metric (distance to border). 
if confParam.useDistLeftBorder == true
    confidence(cnt, :) = compute_DistLeftBorder(disparityL, max_disparity);
    methods{cnt} = 'DLB';
    cnt = cnt + 1; 
end

% 21. prior-based confidence metric (distance to border). 
if confParam.useDistImgBorder == true
    trunc_val = 5;
    confidence(cnt, :) = compute_DistBorder(disparityL, trunc_val);
    methods{cnt} = 'DIB';
    cnt = cnt + 1; 
end

confidence(cnt:end, :) = [];
end

%%-----------------------------------------------------------------------
%%----------- Functions for Confidence Metrics --------------------------
%%-----------------------------------------------------------------------
% 0. Compute Essential Costs. 
function [c_1, c_2, c_hat_2, c_sum, NOI] = compute_base_costs(dsi)
    % compute the first minimum. 
    [c_1, c_idx] = min(dsi);
    
    % compute the sum of matching costs. 
    c_sum = sum(dsi); 
    
    % index to all the local minima. 
    inflections = (conv2([dsi(1, :); dsi], [1 -1]', 'valid') < 0) & ... 
        (conv2([dsi; dsi(end, :)], [-1 1]', 'valid') < 0); 
    
    % compute the second minimum. 
    for k = 1:size(dsi, 2) 
        dsi(c_idx(k), k) = Inf; 
    end
    c_2 = min(dsi); 
    
    % compute the second 'local' minimum. 
    dsi(inflections == 0) = Inf;
    c_hat_2 = min(dsi); 
    
    % compute the number of inflection (NOI) points. 
    NOI = sum(inflections); 
end

%%-----------------------------------------------------------------------
%%---------------- Matching cost-baed confidence measures ---------------
%%-----------------------------------------------------------------------
% 1. Perturbtion (PER) measure. 
function value = compute_perturbation(dsi_s)
    s = 0.1; % tuning parameter. 
    value = -sum(exp( -((bsxfun(@minus, dsi_s(2:end, :), dsi_s(1, :))).^2 ./ s^2 )) ); 
end

% 2. Attainable Maximum Likelihood (AML) measure. 
function value = compute_AML(dsi_s)
    sigma = 0.2; % tuning parameter. 
    value = 1 ./ sum(exp( -((bsxfun(@minus, dsi_s(2:end, :), dsi_s(1, :))).^2 ./ (2*sigma^2) )) ); 
end

% 3. Local curvature (LC) measure. 
function value = compute_LC(dsi)
    gamma = 480;
    [d, n] = size(dsi); 
    new_dsi = ones(d + 2, n)*NaN; 
    new_dsi(2:end-1, :) = dsi; 
    [minVal, idx] = min(round(new_dsi)); 
    %FIX:
    value = zeros(1, n); 
    for k = 1:n
        value(k) = 0;%(max(new_dsi(idx(k) + 1, k), new_dsi(idx(k) - 1)) - minVal(k)) / gamma; 
    end
end

% 4. Left-right difference (LRD) measure. 
function value = compute_LRD(disparityL, c_1, c_2, dsiR )
    [M N ~] = size(disparityL); 
    lrd_map = zeros(M, N);
    for i = 1:M
        for j = 1:N
            left_value = disparityL(i,j);
            offset = double(j) - round(double(left_value));
            if offset > 0 && offset <= N 
                lrd_map(i,j) = abs(dsiR(i, offset, left_value) - min(dsiR(i, offset, :)));
            else
                lrd_map(i,j) = 0;
            end
        end
    end
    value = (c_2 - c_1)./(lrd_map(:)' + 0.0001); 
%     value = min(value, 10); % is truncation necessary? 
end

%%-----------------------------------------------------------------------
%%---------------- Disparity-based confidence measures ------------------
%%-----------------------------------------------------------------------
% 1. Left-right consistency (LRC) measure.
function lrc_map = compute_LRC(disparityL, disparityR) 
    [M N ~] = size(disparityL); 
    lrc_map = zeros(M, N);
       
    for i = 1:M
        for j = 1:N
            left_value = disparityL(i,j);
            offset = double(j) - round(double(left_value));
            if offset > 0 && offset <= N 
                right_value = disparityR(i, offset);  
                lrc_map(i,j) = abs(double(right_value) - double(left_value));
            else                          
                lrc_map(i,j) = -1; 
            end
        end
    end  
    lrc_map = -reshape(lrc_map, [1 M*N]) + max(disparityL(:)); 
end

% 2. Disparity variance (VAR) measure. 
function [varImg, meanImg] = compute_Var(image, r)
    wSize = r*2 + 1; 
    if size(image, 3) > 1
        image = double(rgb2gray(image));
    end
    [meanImg, denom] = compute_mean(image, r); 
    colImg = im2col(image_padding(image, wSize), [wSize wSize], 'sliding'); 
    varImg = sum(bsxfun(@minus, colImg, meanImg(:)').^2) ./ (denom(:)' - 1); 
    % varImg = min(sqrt(varImg), 20);
end

% 4.Distance to discontinuity (DTD) or edge (DTE) measures. 
% Result depends on input (disparity or image). 
function [distImg] = compute_DD(image)
    if size(image, 3) > 1 
        edge_map = edge(image(:, :, 1), 'canny');
        for k = 2:3 
            edge_map = max(edge(image, 'canny'), edge_map);
        end
    else
        edge_map = edge(image, 'canny');
    end
    distImg = bwdist(edge_map); 
    distImg = distImg(:); 
end

% 5. Median deviation (MDD) measure. 
function value = compute_MedDev(image, r)
    wSize = r*2 + 1; 
    value = medfilt2(image, [wSize wSize]) - image;
    value = abs(value(:)); 
end

%%-----------------------------------------------------------------------
%%---------------- Prior-based confidence measures ----------------------
%%-----------------------------------------------------------------------
% 1. Distance to the left border (DLB) measure. 
function value = compute_DistLeftBorder(disparity_map, max_disparity)
    [M, N] = size(disparity_map); 
    value = repmat(min((1:N), max_disparity), [M 1]); 
    value = value(:);
end

% 2. Distance to the border (DB) measure. 
function value = compute_DistBorder(disparity_map, trunc_val)
    [M, N] = size(disparity_map); 
    border_map = zeros(M, N); 
    border_map(1, :) = 1; 
    border_map(end, :) = 1; 
    border_map(:, 1) = 1; 
    border_map(:, end) = 1; 
    value = min(bwdist(border_map), trunc_val); 
    value = value(:);
end

%%-----------------------------------------------------------------------
%%-------------------- Miscellaneous functions --------------------------
%%-----------------------------------------------------------------------
% a1. Mean function. 
function [meanImg, denom] = compute_mean(image, r)
    [hei, wid, d] = size(image);
    denom = boxfilter(ones(hei, wid), r);
    if d > 1 
        meanImg = boxfilter(rgb2gray(image), r) ./ denom;
    else
        meanImg = boxfilter(image, r) ./ denom;
    end 
end

% a2. Image gradient function. 
function dx = compute_ImGrad(image)
    for k = 1:size(image, 3)
       image(:, :, k) = gradient(double(image(:, :, k)));
    end
    dx = reshape(max( abs(image), [], 3 ), 1, []); 
%     dx = dx(:)./max(dx(:)); 
end

% a3. Image padding. 
function [new_image] = image_padding(image, w_size)
    [M, N, d] = size(image); 
    half_w = floor(w_size / 2);
    new_image = zeros(M+w_size-1, N+w_size-1, d); 
    new_image(half_w + 1:end - half_w, half_w + 1:end - half_w, :) = image;
end

% a4. generate right dsi from left. 
function [dsiR, dispR] = dsi_left2right(dsiL, min_disparity, max_disparity)
    [M, N, d] = size(dsiL);
    
    disp('Computing DSI for the right image -------------'); 
    dsiR = ones(M, N, max_disparity).*(max(dsiL(:)));
    for depth = min_disparity:max_disparity
        dsiR(:, 1:end-depth, depth) = dsiL(:,depth+1:end, depth);
    end
    if min_disparity > 2
        dsiR(:, :, 1:min_disparity - 1) = []; 
    end
    
    [~, dispR] = min(dsiR, [], 3); 
    dispR = dispR - min_disparity + 1;
end

% a5. boxfilter; A.Hosni's code (fast cost volume filtering)
function imDst = boxfilter(imSrc, r)
    [hei, wid] = size(imSrc);
    imDst = zeros(size(imSrc));

    %cumulative sum over Y axis
    imCum = cumsum(imSrc, 1);
    %difference over Y axis
    imDst(1:r+1, :) = imCum(1+r:2*r+1, :);
    imDst(r+2:hei-r, :) = imCum(2*r+2:hei, :) - imCum(1:hei-2*r-1, :);
    imDst(hei-r+1:hei, :) = repmat(imCum(hei, :), [r, 1]) - imCum(hei-2*r:hei-r-1, :);

    %cumulative sum over X axis
    imCum = cumsum(imDst, 2);
    %difference over Y axis
    imDst(:, 1:r+1) = imCum(:, 1+r:2*r+1);
    imDst(:, r+2:wid-r) = imCum(:, 2*r+2:wid) - imCum(:, 1:wid-2*r-1);
    imDst(:, wid-r+1:wid) = repmat(imCum(:, wid), [1, r]) - imCum(:, wid-2*r:wid-r-1);
end