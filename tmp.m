%HOG - RD [over] algorithm winner on slices

clc;
close all;

r=zeros(15,4);
index=1;
for i=1:size(algoResults,2)
        [~,indexMin]=min(algoResults(i).ErrorRates);
        r(index,1)=uint8(indexMin);
        r(index,2)=algoResults(i).ErrorRates(indexMin);
      
        r(index,3)=algoResults(i).FeatureValues(1);
        r(index,4)=algoResults(i).FeatureValues(2);
        index=index+1;
end
r=r(1:index-1,:);


figure
% cc=num2str(zeros(index-1,2));
% for i=1:index-1
%     switch r(i,1)
%         case 1
%             cc(i)='r+';
%             break;
%         case 2
%             cc(i)='g+';
%             break;
%         case 3
%             cc(i)='b+';
%             break;
%         case 4
%             cc(i)='y+';
%             break;
%
%     end
% end
 hold on
clear c
for i=1:index-1
    
    %plot(r(i,3),r(i,4),'o','color',[r(i,1) /4 r(i,1)/4 r(i,1)/4]);
    switch(r(i,1))
        case 1
            c='b*';
            d(1)=  plot(r(i,3),r(i,4),c);
        case 2
            c='mo';
             d(2)=  plot(r(i,3),r(i,4),c);
        case 3
            c='r+';
             d(3)=  plot(r(i,3),r(i,4),c);
        case 4
            c='gx';
             d(4)=  plot(r(i,3),r(i,4),c);
    end 
    
end

% scatter(r(i,3),r(i,4));
% a = r(:,1);
b=cellstr(['WCSM  '; 'ARWSM ' ;'FCVFSM' ;'ELAS  ' ]);
% clear c;
% for i=1:size(r,1)
%     c(i)=b(a(i));
% end
%
% dx = 0.1; dy = 0.1; % displacement so the text does not overlay the data points
% text(r(:,3), r(:,4), c);
%
xlabel('RD');
ylabel('HOG');

legend(d,b)

% plot(r(:,3),r(:,4),cc)
% ylim([0 5])
% hold on
% ax = gca;
% ax.ColorOrderIndex = 1;
% plot(r(:,2));
% hold off

% figure;
% plot(r(:,2),'--o')