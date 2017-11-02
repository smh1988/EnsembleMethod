%time-error [over] algoResults on dataset
avrErrors=zeros(1,4);
avrTime=zeros(1,4);
%tmp=zeros
for i=1:15
    for a=1:4
        avrErrors(a)=avrErrors(a)+algoResults(i).ErrorRates(a);
        avrTime(a)=avrTime(a)+algoResults(i).TimeCosts(a);
    end
end

avrErrors=avrErrors(:)/0.15;
avrTime=avrTime(:)/15;
methodNames={'WCSM', 'ARWSM', 'FCVFSM', 'ELAS'};

hold on;
scatter(avrErrors,avrTime);
text(avrErrors,avrTime,methodNames);
hold off;