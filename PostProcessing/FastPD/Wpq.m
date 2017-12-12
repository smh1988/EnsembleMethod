function [result  ] = Wpq(p,q,dp,dq)
%this function for compute (10) formula
p=p(:);
q=q(:);
result=0;
if(dp==dq)
    return;
end

gammaC=3.6;
expCompute= exp( - pdist([p;q])/gammaC );
result=  max(  [  expCompute(:) ; 0.0003]  );
