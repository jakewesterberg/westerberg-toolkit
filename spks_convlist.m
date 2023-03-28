function l = spks_convlist(l,k)

% hlen    = floor(length(k)/2);
% llen    = length(l);
% begmean = mean(l(1:hlen))*ones(1,hlen);
% endmean = mean(l(llen-hlen:llen))*ones(1,hlen);
% ltmp    = [begmean l endmean];
% tmp    = conv(ltmp,k);
% start  = round(length(k)-1);
% finish = start+length(l)-1;
% cl     = tmp([start:finish]);

l           = conv([(mean(l(1:floor(length(k)/2)))*ones(1,floor(length(k)/2))) l (mean(l(length(l)-floor(length(k)/2):length(l)))*ones(1,floor(length(k)/2)))], k);
l           = l(round(length(k)-1):round(length(k)-1)+length(l)-1);

end