function [cnv] = spks_conv( cnv, k )
cnv_len = length(cnv);
cnv_pre = mean(cnv(:,1:floor(length(k)/2)),2)*ones(1,floor(length(k)/2));
cnv_post = mean(cnv(:,cnv_len-floor(length(k)/2):cnv_len),2)*ones(1,floor(length(k)/2));
cnv = conv2([ cnv_pre cnv cnv_post ], k, 'valid');
end
