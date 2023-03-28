function dat = common_average_reference(dat)

%chan x time x trial

if ndims(dat) == 2
    dat = dat - repmat(nanmean(dat,1), size(dat,1), 1);
elseif ndims(dat) == 3
    dat = dat - repmat(nanmean(dat,1), size(dat,1), 1, 1);
end

end