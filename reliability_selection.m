function [output_targ_choice_nrs, output_ndist_choice_nrs, output_sdist_choice_nrs, ...
    output_crit_percent_nrs, output_hit_crit_nrs, summary] = ...
    reliability_selection(dat_in1, dat_in2, dat_in3, samples_in, counts_in, boots_in)

summary.samples = samples_in;
summary.counts = counts_in;
summary.boots = boots_in;
summary.crit_percent = 95;
summary.smooth_win = 2;

boots_ref = summary.boots;
counts_ref = summary.counts;
crit_ref = summary.crit_percent;
set_size = 6;
smooth_win = summary.smooth_win;

output_targ_choice_nrs = nan(numel(counts_ref), size(dat_in1, 2));
output_ndist_choice_nrs = nan(numel(counts_ref), size(dat_in1, 2));
output_sdist_choice_nrs = nan(numel(counts_ref), size(dat_in1, 2));
output_crit_percent_nrs = nan(numel(counts_ref), size(dat_in1, 2));
output_hit_crit_nrs = nan(numel(counts_ref), size(dat_in1, 2));

for SAMPLE = summary.samples

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

    for counts = 1 : numel(counts_ref)

        targ_choice_nrs = 0;
        ndist_choice_nrs = 0;
        sdist_choice_nrs = 0;

        parfor boots = 1 : boots_ref

            rsamps_nrs = [];

            try
            for stim_row = 1 : set_size
                not_full = true;
                while not_full
                    if stim_row == 1
                        rsamps_nrs(stim_row, :) = randsample(numel(reli_dat_pop_targ), ...
                            counts_ref(counts), false);
                        if sum(isnan(reli_dat_pop_targ(rsamps_nrs(stim_row,:)))) == 0
                            not_full = false;
                        end
                    elseif stim_row == 2
                        rsamps_nrs(stim_row, :) = randsample(numel(reli_dat_pop_sdist), ...
                            counts_ref(counts), false);
                        if sum(isnan(reli_dat_pop_sdist(rsamps_nrs(stim_row,:)))) == 0
                            not_full = false;
                        end
                    else
                        rsamps_nrs(stim_row, :) = randsample(numel(reli_dat_pop_ndist), ...
                            counts_ref(counts), false);
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

                if maxind == 1; targ_choice_nrs = targ_choice_nrs + 1;
                elseif maxind == 2; sdist_choice_nrs = sdist_choice_nrs + 1;
                else; ndist_choice_nrs = ndist_choice_nrs + 1; end
            end
        end

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