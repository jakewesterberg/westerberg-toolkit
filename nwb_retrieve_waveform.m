function waveform = nwb_retrieve_waveform(nwb, unit_id)

peak_channel_id = nwb.units.vectordata.get('peak_channel_id').data(unit_id);

waveform = nwb.units.waveform_mean.data(:, ...
unit_id*128-128+peak_channel_id);

end