function Y = upsample_stream_repeat_hold(X, T1, T2, varargin)
%UPSAMPLE_STREAM_REPEAT_HOLD  Upsample a stream by "repeat/hold" between timestamps.
%
%   Y = upsample_stream_repeat_hold(X, T1, T2)
%   takes samples X at times T1 and returns Y at times T2 such that
%   Y(t) equals the most recent X sample at or before t (zero-order hold).
%   Values are repeated (held) until the next T1 sample time.
%
%   X can be:
%     - [N x 1] vector (scalar stream)
%     - [N x D] matrix (D channels/features)
%   T1 must be [N x 1] (or [1 x N]) numeric or datetime.
%   T2 must be [M x 1] (or [1 x M]) same type/units as T1.
%
%   Optional name-value:
%     'FillBeforeFirst' : value used for T2 earlier than first T1 time.
%                         Default = NaN (or NaN row for multichannel).
%     'AssumeSorted'    : true/false. If false (default), T1 will be sorted
%                         and X reordered accordingly.
%
%   Example:
%     T1 = [0 0.3 1.2 2.0]';  X = [10 11 12 13]';
%     T2 = (0:0.1:2.2)'; 
%     Y  = upsample_stream_repeat_hold(X,T1,T2);
%
% Jake-style note: This is a "previous sample" mapping; no interpolation.

% -------------------- parse/validate --------------------
p = inputParser;
p.addParameter('FillBeforeFirst', [], @(v) true);
p.addParameter('AssumeSorted', false, @(b) islogical(b) && isscalar(b));
p.parse(varargin{:});
fillBefore = p.Results.FillBeforeFirst;
assumeSorted = p.Results.AssumeSorted;

% force columns
T1 = T1(:);
T2 = T2(:);

% allow row-vector X but interpret as Nx1 if lengths match
if isvector(X)
    X = X(:);
end

N = numel(T1);
if size(X,1) ~= N
    error('X must have the same number of rows as numel(T1). Got size(X,1)=%d, numel(T1)=%d.', size(X,1), N);
end

% type handling: numeric or datetime
if ~(isnumeric(T1) || isdatetime(T1))
    error('T1 must be numeric or datetime.');
end
if class(T2) ~= class(T1)
    error('T2 must be the same type as T1 (both numeric or both datetime).');
end

% sort T1 if needed
if ~assumeSorted
    [T1, order] = sort(T1);
    X = X(order, :);
else
    if any(diff(T1) < 0)
        error('T1 is not sorted ascending. Either sort it or set AssumeSorted=false.');
    end
end

% handle duplicate T1 timestamps by keeping the LAST sample at each time
if any(diff(T1) == 0)
    % stable unique, keep last occurrence
    [Tu, ~, ic] = unique(T1, 'stable');
    Xlast = nan(numel(Tu), size(X,2), 'like', X);
    for k = 1:numel(Tu)
        idx = find(ic == k, 1, 'last');
        Xlast(k,:) = X(idx,:);
    end
    T1 = Tu;
    X = Xlast;
    N = numel(T1);
end

M = numel(T2);
D = size(X,2);

% default fill for times before first T1
if isempty(fillBefore)
    fillBefore = nan(1, D);
else
    % allow scalar fill to broadcast
    if isscalar(fillBefore)
        fillBefore = repmat(fillBefore, 1, D);
    else
        fillBefore = reshape(fillBefore, 1, []);
        if numel(fillBefore) ~= D
            error('FillBeforeFirst must be scalar or have %d elements (one per channel).', D);
        end
    end
end

% -------------------- core mapping (zero-order hold) --------------------
% For each T2(m), find the last T1(n) such that T1(n) <= T2(m).
% Use discretize with edges [-Inf; T1(2:end); Inf] so each bin maps to a T1 index.
edges = [-inf; T1(2:end); inf];
bin = discretize(T2, edges);   % returns 1..N for >=T1(1); NaN for <T1(1)

Y = nan(M, D, 'like', X);

% fill before first sample
pre = isnan(bin);
if any(pre)
    Y(pre, :) = repmat(fillBefore, sum(pre), 1);
end

% fill using held values
ok = ~pre;
if any(ok)
    Y(ok, :) = X(bin(ok), :);
end

end