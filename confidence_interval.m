function [mean_out, lower_out, upper_out] = confidence_interval(data_in, methd, lvl)

if ~exist('methd', 'var')
    methd = 'mean';
end

if ~exist('lvl', 'var')
    lvl = 1.96;
end

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
        mean_out = nanmean(data_in,2);
    else
        mean_out = nanmedian(data_in,2);
    end
    upper_out = mean_out + lvl*(nanstd(data_in,[],2) ./ (sqrt(size(data_in,2))));
    lower_out = mean_out - lvl*(nanstd(data_in,[],2) ./ (sqrt(size(data_in,2))));

end

end