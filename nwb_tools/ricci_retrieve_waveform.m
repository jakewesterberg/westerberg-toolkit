function waveform = ricci_retrieve_waveform(units, unit_no, probe_channel_count)

peak_channel_id = mod( units.chans(unit_no)+1, probe_channel_count);

waveform = units.wfMean(:, unit_no*probe_channel_count-probe_channel_count+peak_channel_id);

end
