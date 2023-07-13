function waveform = nwb_retrieve_waveform_AIBS(nwb, unit_no)

peak_channel_id = mod( ...
    nwb.units.vectordata.get('peak_channel_id').data(unit_no)+1, ... 
    1000);

waveform = nwb.units.waveform_mean.data(:, ...
unit_no*384-384+peak_channel_id);

end
