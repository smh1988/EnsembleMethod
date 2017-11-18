function AMLR=AML(imgsize,CostVolume,sortedCostVol)


%% Attainable Maximum AML (AML)
disp('calculate AML')
tic

maxdisp=size(CostVolume,3);
sigma=0.2;
AMLR=zeros(imgsize);
for x=1:imgsize(1)
    for y=1:imgsize(2)
        den = 0;
        for d=1:maxdisp
            den=den+exp(- ((CostVolume(x,y,d)-sortedCostVol(x,y,1))^2) ./ ( 2*(sigma^2) ) ); 
        end
        if(den==0)
            AMLR(x,y)=0;
        else
            AMLR(x,y)=1/den;
        end
    end
end 

disp('AML finished on:')
toc
end