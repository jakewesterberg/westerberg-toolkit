function waveform = nwb_retrieve_waveform(nwb, unit_no, ch_per_probe)

peak_channel_id = mod( ...
    nwb.units.vectordata.get('peak_channel_id').data(unit_no)+1, ... 
    1000);

waveform = nwb.units.waveform_mean.data(:, ...
unit_no*ch_per_probe-ch_per_probe+peak_channel_id);

end
