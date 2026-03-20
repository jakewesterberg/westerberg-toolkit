function run_transmission(condition, file_path, nwb_path)
%visual oddballs distort signal propagation in mouse visual cortex
if nargin < 1
    condition = 'early_local_oddball';
end
if nargin < 2
    file_path = 'D:\manuscript\WesterbergEtAl_2023_TBD_GLO\compiled-datasets\RASTERS\';
end
if nargin < 3
    nwb_path = 'D:\manuscript\WesterbergEtAl_2023_TBD_GLO\nwb';
end

complete_path = [file_path condition];
mice = find_in_dir(complete_path, '.mat');
mice = mice(cell2mat(cellfun(@contains, mice, repmat({'.mat'}, size(mice)), 'UniformOutput', false)));
nwbs = find_in_dir(nwb_path, '.nwb');

for ii = mice

    file_name = ii{1};
    file_name_start = file_name(1:end-4);
    file_name_spikes = [file_name_start '_spikes.npy'];
    file_name_FR = [file_name_start '_FR.npy'];
    file_name_AM = [file_name_start '_adjacency_matrix.npy'];
    file_name_CL = [file_name_start '_cluster_labels.npy'];
    file_name_FC = [file_name_start '_fc_class'];
    file_name_UU = [file_name_start '_units_included.npy'];

    load(file_name)

    %input into modular_network: neuron x ori x trial x time
    ccg_raster  = permute(rasters, [1 4 3 2]); clear rasters
    ccg_raster  = ccg_raster(:,:,:,151:650);
    ccg_raster = cat(2, ccg_raster, ccg_raster);
    ccg_FR      = squeeze(sum(sum(sum(ccg_raster, 3), 2), 4)) ./ ...
        (size(ccg_raster, 4)/1000 * size(ccg_raster, 2) * size(ccg_raster, 3));

    writeNPY(ccg_raster, file_name_spikes)
    writeNPY(ccg_FR, file_name_FR)
    writeNPY(ccg_FR>2, file_name_UU);

    if ~exist(file_name_CL, 'file')

        pyrun('import sys')
        pyrun('sys.path.append(''C:/Users/jakew/OneDrive/Documents/Github/westerberg-toolkit/run_transmission'')')
        pyrun('import jakeMN')
        pyrun('import numpy as np')
        if ~exist(file_name_AM, 'file')
            pyrun(['adj_matrix = jakeMN.ccgs(r''' file_name_spikes ''', r''' file_name_FR ''')'])
        else
            pyrun(['adj_matrix = np.load(r''' file_name_AM ''')'])
        end
        pyrun('FC = jakeMN.functional_clustering(adj_matrix)')
        pyrun('FC.normalize()')
        pyrun('FC.pca()')
        pyrun('FC.probability_matrix(3)')
        pyrun('FC.linkage()')
        pyrun('FC.predict_cluster(k=3)')
        pyrun('cluster_labels = FC.clusters')
        pyrun(['np.save(r''' file_name_CL ''', cluster_labels)'])
        pyrun(['FC.save_class_file(r''' file_name_FC ''')'])

    end

end

end