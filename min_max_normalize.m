function dat = min_max_normalize(dat, bl_epoch, and_correct)

dat = 'not currently working'

% if nargin < 3
%     and_correct = 1;
% end
% 
% if ndims(dat) == 2
%     dat = dat ./ repmat(nanstd(dat(:,bl_epoch), [], 2), 1, size(dat,2));
% elseif ndims(dat) == 3
%     dat = dat ./ repmat(nanstd(dat(:,bl_epoch,:), [], 2), 1, size(dat,2), 1);
% end
% 
% if and_correct
%     if ndims(dat) == 2
%         dat = dat - repmat(nanmean(dat(:,bl_epoch),2), 1, size(dat,2));
%     elseif ndims(dat) == 3
%         dat = dat - repmat(nanmean(dat(:,bl_epoch,:),2), 1, size(dat,2), 1);
%     end
% end

end