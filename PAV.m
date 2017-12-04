function v = PAV(dat)
%PAV uses the pair adjacent violators method to produce a monotonic smoothing
%of dat
%
%written by Sean Collins (2006) as part of the EMAP toolbox

dims = size(dat);
num = dims(2);
len = dims(1);
v= dat;
for j=1:num
	lvls = 1:len;
	lvls = lvls';
	lvlsets = [lvls lvls];
	flag = 1;
	while (flag)
		deriv = diff(v(:,j));
		if length(find(deriv < 0)) == 0
			break;
		end
		viol = find(deriv < 0);
		start = lvlsets(viol(1),1);
		last = lvlsets(viol(1)+1,2);
		sum = 0;
		n = last-start+1;
		for i=start:last
			sum = sum + v(i,j);
		end
		val = sum/n;
		for i=start:last
			v(i,j) = val;
			lvlsets(i,1) = start;
			lvlsets(i,2) = last;
		end
	end
end