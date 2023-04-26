function run_transmission(condition, file_path)

if nargin < 1
    condition = 'early_global_oddball';
end
if nargin < 2
    file_path = 'D:\manuscript\WesterbergEtAl_2023_TBD_GLO\compiled-datasets\RASTERS\';
end

complete_path = [file_path condition];
mice = find_in_dir(complete_path, '.mat');

for ii = mice

    file_name = ii{1};
    load(file_name)
    
    %input into modular_network: neuron x ori x trial x time
    ccg_raster  = permute(rasters, [1 4 3 2]); clear rasters
    ccg_raster  = ccg_raster(:,:,:,151:650);
    ccg_raster = cat(2, ccg_raster, ccg_raster);
    ccg_FR      = squeeze(sum(sum(sum(ccg_raster, 3), 2), 4)) ./ ...
        (size(ccg_raster, 4)/1000 * size(ccg_raster, 2) * size(ccg_raster, 3));

    file_name_spikes = [file_name(1:end-4) '_spikes.npy'];
    file_name_FR = [file_name(1:end-4) '_FR.npy'];
    file_name_ccgjitter = [file_name(1:end-4) '_ccgjitter.npy'];

    writeNPY(ccg_raster, file_name_spikes)
    writeNPY(ccg_FR, file_name_FR)

    pyrun('import sys')
    pyrun('sys.path.append(''C:/Users/jakew/OneDrive/Documents/Github/westerberg-toolkit/run_transmission'')')
    pyrun('import ccg_jxx')
    pyrun('from jitter import jitter')
    pyrun('import scipy')
    pyrun('import numpy as np')
    pyrun(['spikes = np.load(''' file_name_spikes ''')'])
    pyrun(['FR = np.load(''' file_name_FR ''')'])
    pyrun('ccgjitter = ccg_jxx.get_ccgjitter(spikes, FR)')
    pyrun('ccgjitter = ccgjitter.real')
    pyrun('ccgjitter = np.squeeze(ccgjitter[:,:,0])')
    pyrun(['np.save(''' file_name_ccgjitter ''', ccgjitter)'])

end

end