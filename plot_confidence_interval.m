function fill_name = plot_confidence_interval(lower, upper, x, color, fa)

if length(lower)~=length(upper)
    error('lower and upper vectors must be same length')
end

if nargin<5
    fa = 0.2;
end

if nargin<4
    color='b';
end

if nargin<3
    x=1:length(lower);
end

% convert to row vectors so fliplr can work
if find(size(x)==(max(size(x))))<2
x=x'; end
if find(size(lower)==(max(size(lower))))<2
lower=lower'; end
if find(size(upper)==(max(size(upper))))<2
upper=upper'; end

fill_name = fill([x fliplr(x)],[upper fliplr(lower)],color, 'facealpha', fa, 'edgecolor', 'none');

end


