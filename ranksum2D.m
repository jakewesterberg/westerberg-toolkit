function [z, zsig] = ranksum2D(x,y,t)

if nargin < 3
    t=9;
end

if nargin < 2
    for ii = 1 : size(x,2)
        %[~, z(ii)] = ttest2(x(:,ii),y(:,ii));
        z(ii) = signtest(x(:,ii), 0, 'Tail', 'right');
    end
else
    for ii = 1 : size(x,2)
        %[~, z(ii)] = ttest2(x(:,ii),y(:,ii));
        z(ii) = signtest(x(:,ii),y(:,ii));
    end
end

zsig = find(movsum((z<0.05), [0 t]) == t+1, 1);

end