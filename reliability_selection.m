function [output_targ_choice_nrs, output_ndist_choice_nrs, output_sdist_choice_nrs, ...
    output_crit_percent_nrs, output_hit_crit_nrs, summary] = ...
    reliability_selection(dat_in1, dat_in2, dat_in3, samples_in, counts_in, boots_in)

set_size = 6;
save_pops = true;

summary.samples = samples_in;
summary.counts = counts_in;
summary.boots = boots_in;
summary.crit_percent = 95;
summary.smooth_win = 2;

max_counts = max(counts_in);
num_counts = numel(counts_in);

targ_chosen = zeros(boots_in, size(dat_in1, 2), num_counts, 'logical');
sdist_chosen = zeros(boots_in, size(dat_in1, 2), num_counts, 'logical');
ndist_chosen = zeros(boots_in*(set_size-2), size(dat_in1, 2), num_counts, 'logical');

targ_pops = zeros(boots_in, size(dat_in1, 2), num_counts, max_counts, 'uint16');
sdist_pops = zeros(boots_in, size(dat_in1, 2), num_counts, max_counts, 'uint16');
ndist_pops = zeros(boots_in*(set_size-2), size(dat_in1, 2), num_counts, max_counts, 'uint16');

boots_ref = summary.boots;
counts_ref = summary.counts;
crit_ref = summary.crit_percent;
smooth_win = summary.smooth_win;

output_targ_choice_nrs = nan(numel(counts_ref), size(dat_in1, 2));
output_ndist_choice_nrs = nan(numel(counts_ref), size(dat_in1, 2));
output_sdist_choice_nrs = nan(numel(counts_ref), size(dat_in1, 2));
output_crit_percent_nrs = nan(numel(counts_ref), size(dat_in1, 2));
output_hit_crit_nrs = nan(numel(counts_ref), size(dat_in1, 2));

for SAMPLE = summary.samples

    disp(['working on SAMPLE ' num2str(SAMPLE)])

    reli_dat_pop_targ = nanmean(dat_in1(:,SAMPLE-smooth_win:SAMPLE+smooth_win),2);
    reli_dat_pop_ndist = nanmean(dat_in2(:,SAMPLE-smooth_win:SAMPLE+smooth_win),2);
    reli_dat_pop_sdist = nanmean(dat_in3(:,SAMPLE-smooth_win:SAMPLE+smooth_win),2);

    targ_nnan = ~isnan(reli_dat_pop_targ);
    ndist_nnan = ~isnan(reli_dat_pop_ndist);
    sdist_nnan = ~isnan(reli_dat_pop_sdist);

    reli_dat_pop_targ = reli_dat_pop_targ(targ_nnan);
    reli_dat_pop_ndist = reli_dat_pop_ndist(ndist_nnan);
    reli_dat_pop_sdist = reli_dat_pop_sdist(sdist_nnan);

    clear targ_nnan ndist_nnan sdist_nnan

    for counts = 1 : num_counts

        targ_choice_nrs = 0;
        ndist_choice_nrs = 0;
        sdist_choice_nrs = 0;
        cur_count = counts_ref(counts);

        stim_pops = zeros(set_size, cur_count, boots_ref);

        ndist_chosen1 = zeros(boots_in, size(dat_in1, 2), num_counts, 'logical');
        ndist_chosen2 = zeros(boots_in, size(dat_in1, 2), num_counts, 'logical');
        ndist_chosen3 = zeros(boots_in, size(dat_in1, 2), num_counts, 'logical');
        ndist_chosen4 = zeros(boots_in, size(dat_in1, 2), num_counts, 'logical');

        parfor boots = 1 : boots_ref

            rsamps_nrs = [];

            try
            for stim_row = 1 : set_size
                not_full = true;
                while not_full
                    if stim_row == 1
                        rsamps_nrs(stim_row, :) = randsample(numel(reli_dat_pop_targ), ...
                            cur_count, false);
                        if sum(isnan(reli_dat_pop_targ(rsamps_nrs(stim_row,:)))) == 0
                            not_full = false;
                        end
                    elseif stim_row == 2
                        rsamps_nrs(stim_row, :) = randsample(numel(reli_dat_pop_sdist), ...
                            cur_count, false);
                        if sum(isnan(reli_dat_pop_sdist(rsamps_nrs(stim_row,:)))) == 0
                            not_full = false;
                        end
                    else
                        rsamps_nrs(stim_row, :) = randsample(numel(reli_dat_pop_ndist), ...
                            cur_count, false);
                        if sum(isnan(reli_dat_pop_ndist(rsamps_nrs(stim_row,:)))) == 0
                            not_full = false;
                        end
                    end
                end
            end
            catch
                rsamps_nrs = [];
            end

            if ~isempty(rsamps_nrs)

                stim_pops(:,:,boots) = rsamps_nrs;

                stim_sum_nrs = nan(1,set_size);
                for stim_itt = 1 : set_size
                    if stim_itt == 1
                        stim_sum_nrs(stim_itt) = ...
                            sum(reli_dat_pop_targ(rsamps_nrs(stim_itt,:)));
                    elseif stim_itt == 2
                        stim_sum_nrs(stim_itt) = ...
                            sum(reli_dat_pop_sdist(rsamps_nrs(stim_itt,:)));
                    else
                        stim_sum_nrs(stim_itt) = ...
                            sum(reli_dat_pop_ndist(rsamps_nrs(stim_itt,:)));
                    end
                end
            
                [~, maxind] =  max(stim_sum_nrs);

                if maxind == 1
                    targ_choice_nrs = targ_choice_nrs + 1;
                    targ_chosen(boots, SAMPLE, counts) = 1;
                elseif maxind == 2
                    sdist_choice_nrs = sdist_choice_nrs + 1;
                    sdist_chosen(boots, SAMPLE, counts) = 1;
                elseif maxind == 3
                    ndist_choice_nrs = ndist_choice_nrs + 1;
                    ndist_chosen1(boots, SAMPLE, counts) =1;
                elseif maxind == 4
                    ndist_choice_nrs = ndist_choice_nrs + 1;
                    ndist_chosen2(boots, SAMPLE, counts) =1;
                elseif maxind == 5
                    ndist_choice_nrs = ndist_choice_nrs + 1;
                    ndist_chosen3(boots, SAMPLE, counts) =1;
                elseif maxind == 6
                    ndist_choice_nrs = ndist_choice_nrs + 1;
                    ndist_chosen4(boots, SAMPLE, counts) =1;
                end

            end
        end

        ndist_chosen_temp = [ndist_chosen1; ndist_chosen2; ndist_chosen3; ndist_chosen4];
        ndist_chosen(:,:,counts) = ndist_chosen_temp; clear ndist_chosen_temp;

        for boots = 1:boots_ref
            targ_pops(boots, SAMPLE, counts, 1:cur_count) = stim_pops(1, :, boots);
            sdist_pops(boots, SAMPLE, counts, 1:cur_count) = stim_pops(2, :, boots);
            ndist_pops(boots+boots_ref*1, SAMPLE, counts, 1:cur_count) = ...
                stim_pops(3, :, boots);
            ndist_pops(boots+boots_ref*2, SAMPLE, counts, 1:cur_count) = ...
                stim_pops(4, :, boots);
            ndist_pops(boots+boots_ref*3, SAMPLE, counts, 1:cur_count) = ...
                stim_pops(5, :, boots);
            ndist_pops(boots+boots_ref*4, SAMPLE, counts, 1:cur_count) = ...
                stim_pops(6, :, boots);
        end
        clear stim_pops

        if targ_choice_nrs | sdist_choice_nrs | ndist_choice_nrs

            output_targ_choice_nrs(counts, SAMPLE) = ...
                single(targ_choice_nrs);

            output_sdist_choice_nrs(counts, SAMPLE) = ...
                single(sdist_choice_nrs);

            output_ndist_choice_nrs(counts, SAMPLE) = ...
                single(ndist_choice_nrs);

            output_crit_percent_nrs(counts, SAMPLE) = ...
                single(targ_choice_nrs / (targ_choice_nrs + ndist_choice_nrs + sdist_choice_nrs) * 100);

            output_hit_crit_nrs(counts, SAMPLE) = ...
                output_crit_percent_nrs(counts, SAMPLE) > crit_ref;

        else

            output_targ_choice_nrs(counts, SAMPLE) = ...
                NaN;

            output_sdist_choice_nrs(counts, SAMPLE) = ...
                NaN;

            output_ndist_choice_nrs(counts, SAMPLE) = ...
                NaN;

            output_crit_percent_nrs(counts, SAMPLE) = ...
                NaN;

            output_hit_crit_nrs(counts, SAMPLE) = ...
                NaN;

        end
    end
end

summary.targ_pops = targ_pops; clear targ_pops;
summary.sdist_pops = sdist_pops; clear sdist_pops;
summary.ndist_pops = ndist_pops; clear ndist_pops;
summary.targ_chosen = targ_chosen; clear targ_chosen;
summary.sdist_chosen = sdist_chosen; clear sdist_chosen;
summary.ndist_chosen = ndist_chosen; clear ndist_chosen;

end