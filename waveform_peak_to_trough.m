function p2t_samples = waveform_peak_to_trough(waveform_data)

[~, I1] = max(waveform_data);
[~, I2] = min(waveform_data);

p2t_samples = abs(I1-I2);

end