function [h_corrected,h_real,crit_val,k] = cbpstat(mat1,mat2,rand_num,a1,a2,bs_corr_or_not,bs)
if nargin<6
    bs_corr_or_not=0;
end
if nargin<5
    a2=0.05;
end
if nargin<4
    a1=0.05;
end
if nargin<3
    rand_num=1000;
end
k=nan(1,rand_num);
all=cat(1,mat1,mat2);
[h_real,~,~,s]=ttest2(mat1,mat2,'Alpha',a1);
num1=size(mat1,1);
num2=size(mat2,1);
for rep = 1:rand_num
    rand=all(randperm(size(all,1)),:);
    [h_sim,~,~,s_sim]=ttest2(rand(1:num1,:),rand(num1+1:num1+num2,:));
    highest=1;
    [L,Num]=spm_bwlabel(double(h_sim),18);
    for clst=1:Num
        curr_size=abs(trapz(s_sim.tstat(L==clst)));
        if curr_size>highest
            highest=curr_size;
        end
    end 
    k(rep)=highest;
end
critbin=a2*rand_num;
critbin=ceil(critbin);
[val,~]=sort(k,'descend');
crit_val = val(critbin);
if bs_corr_or_not==1
    [h_bs,~,~,s_bs] = ttest2(mat1(:,bs),mat2(:,bs));
    [L_bs,Num_bs]=spm_bwlabel(h_bs,18);
    highest=0;
    for clst=1:Num_bs
        curr_size = abs(trapz(s_bs.tstat(L_bs==clst)));
        if curr_size>highest
            highest = curr_size;
        end
    end
    crit_val = max([crit_val,highest]);
end
[L_real, Num_real] = spm_bwlabel(double(h_real),18);
h_corrected = L_real;
for clst=1:Num_real
    if abs(trapz(s.tstat(L_real==clst)))<crit_val
        h_corrected(L_real==clst)=0;
    end
end

h_corrected(h_corrected>0) = 1;
h_corrected = logical(h_corrected);
 
end