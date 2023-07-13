function [mean_out, lower_out, upper_out] = confidence_interval(data_in, methd, lvl)

flag_stdonly = 0;

if ~exist('methd', 'var')
    methd = 'mean';
end

if ~exist('lvl', 'var')
    lvl = 1.96;
end


if flag_stdonly
% data_in = 3dim matrix (channel x time x trial)
if numel(size(data_in))==3
    if strcmp('mean', methd)
        mean_out = nanmean(data_in,3);
    else
        mean_out = nanmedian(data_in,3);
    end
    upper_out = mean_out + (nanstd(data_in,[],3));% ./ (sqrt(size(data_in,3))));
    lower_out = mean_out - (nanstd(data_in,[],3));% ./ (sqrt(size(data_in,3))));
else

    if strcmp('mean', methd)
        mean_out = nanmean(data_in);
    else
        mean_out = nanmedian(data_in);
    end
    upper_out = mean_out + (nanstd(data_in));% ./ (sqrt(size(data_in,1))));
    lower_out = mean_out - (nanstd(data_in));% ./ (sqrt(size(data_in,1))));

end

else
% data_in = 3dim matrix (channel x time x trial)
if numel(size(data_in))==3
    if strcmp('mean', methd)
        mean_out = nanmean(data_in,3);
    else
        mean_out = nanmedian(data_in,3);
    end
    upper_out = mean_out + lvl*(nanstd(data_in,[],3) ./ (sqrt(size(data_in,3))));
    lower_out = mean_out - lvl*(nanstd(data_in,[],3) ./ (sqrt(size(data_in,3))));
else

    if strcmp('mean', methd)
        mean_out = nanmean(data_in);
    else
        mean_out = nanmedian(data_in);
    end
    upper_out = mean_out + lvl*(nanstd(data_in) ./ (sqrt(size(data_in,1))));
    lower_out = mean_out - lvl*(nanstd(data_in) ./ (sqrt(size(data_in,1))));

end   

end
end