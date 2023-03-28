function dat = baseline_correct(dat, bl_epoch)

if ndims(dat) == 2
    dat = dat - repmat(nanmean(dat(:,bl_epoch),2), 1, size(dat,2));
elseif ndims(dat) == 3
    dat = dat - repmat(nanmean(dat(:,bl_epoch,:),2), 1, size(dat,2), 1);
end

end