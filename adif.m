function diffs = adif ( img , x ,y,w)
% special absolute Difference
ch=1;
weights=[0,0,0.5,0,0,0,0.5,0,1]';
base=double(img(x,y,ch));
% x=int8(x);
% y=int8(y);
% w=int8(w);
diffs(1)=base-double(img(x-w,y,ch));%!!!!!!!!
diffs(2)=base-double(img(x-w,y+w,ch));
diffs(3)=base-double(img(x,y+w,ch));
diffs(4)=base-double(img(x+w,y+w,ch));
diffs(5)=base-double(img(x+w,y,ch));
diffs(6)=base-double(img(x+w,y-w,ch));
diffs(7)=base-double(img(x,y-w,ch));
diffs(8)=base-double(img(x-w,y-w,ch));
diffs(9)=base;
diffs=abs(diffs)*weights;
end

