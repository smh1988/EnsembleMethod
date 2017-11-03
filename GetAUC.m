function [ value ] = GetAUC( rocCurve ,pers)
%AUC computing the area under the ROC curve
%   based on 2012-A Quantitative Evaluation of Confidence Measures for
%   Stereo Vision (section 4.1)

value = trapz(pers,rocCurve);
end

