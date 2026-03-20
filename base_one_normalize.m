function normed_data = base_one_normalize(data_in)

%95 max is default
target_val = 0.05;
max_val = max(max(abs(data_in),3),2);

normed_data = nan(size(data_in));
for ii = 1 : size(data_in,1)

    temp_data = squeeze(data_in(ii,:,:));
    temp_data = abs(temp_data(:));
    [~,p] = sort(temp_data,'descend');
    r = 1:length(temp_data);
    r(p) = r;
    r2 = r/max(r);
    [~, I] = min(r2-target_val);

    normed_data(ii,:,:) = data_in(ii,:,:) ./ temp_data(I);

end

end