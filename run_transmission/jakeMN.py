# -*- coding: utf-8 -*-
"""
Created on Thu Oct 12 11:12:42 2023

@author: jakew
"""

import ccg_jxx
import numpy as np
import matplotlib.pyplot as plt
import pickle

from sklearn.preprocessing import StandardScaler
from scipy.cluster.vq import kmeans2

import scipy.cluster.hierarchy as sch

import pca_basic

def ccgs(spikes_file, FR_file):
    spikes = np.load(spikes_file)
    FR = np.load(FR_file)
    ccgjitter = ccg_jxx.get_ccgjitter(spikes, FR)
    ccgjitter = ccgjitter.real
    ccgjitter = np.squeeze(ccgjitter[:,:,0])
    
    n_good_units = np.sum(FR > 2)
    t_range = range(399,599)
    
    temp_ccg = np.zeros((n_good_units, n_good_units, 200))
    ctr0 = 0
    ctr1 = 0
    ctr2 = 0
    while True:
        if ctr1 > ctr2:
            temp_ccg[ctr2, ctr1, :] = ccgjitter[ctr0, t_range] 
            ctr1 += 1
            ctr0 += 1
            if ctr1 > n_good_units-1:
                ctr2 += 1
                ctr1 = ctr2
        else:
            ctr1 +=1
        
        if ctr0 > np.size(ccgjitter, axis=0)-1:
            break
            
        
    adj_matrix =  np.mean(temp_ccg[:,:,100:113], axis=2) - np.mean(temp_ccg[:,:,87:100], axis=2)
    adj_matrix = adj_matrix + -1*adj_matrix.T - np.diag(np.diag(adj_matrix))
    
    ccgjitter = temp_ccg    
    
    np.save(FR_file[:-6] + "ccgjitter.npy", ccgjitter)
    np.save(FR_file[:-6] + "adjacency_matrix.npy", adj_matrix)
    
    # plt.figure(figsize=(5,4))
    # plt.imshow(adj_matrix, vmax=0.000002, vmin=-0.000002, cmap='bwr')
    # plt.colorbar()
    # plt.xlabel('To')
    # plt.ylabel('From')
    # plt.title('Diff of CCG (+/-13 ms) grating')
    
    return adj_matrix       

class functional_clustering(object):
    def __init__(self, data, threshold=0.8):
        self.X = data
        self.n_neuron = np.shape(self.X)[0]
        self.Lin = []
        self.threshold=threshold

    def normalize(self):
        # 1. normalization (var=1 in all dims)
        self.X_n = StandardScaler().fit_transform(self.X)
        
    def pca(self, norm=True):
        if norm:
            self.Z, self.k = pca_basic.pca_basic(self.X_n, threshold=self.threshold)
        else:
            self.Z, self.k = pca_basic.pca_basic(self.X, threshold=self.threshold)

    def probability_matrix(self, k, data=[], iter_n = 1000, boot_n = 100):

        if  len(data)==0:
            data = self.Z.T

        n = self.n_neuron
        L = np.zeros((n,boot_n))
        for boot in range(boot_n):
            #if boot%10==0:
                #print(boot)
            # method1: random sub sample (99% of data) with random initiation
            #indices = np.sort(np.random.choice(range(n), size=round(n*0.99), replace=False))
            #clusters = kmeans2(Z_n[indices,:], k, iter=iter_n, thresh=5e-6,minit='random')
            # method2: random initiation
            clusters = kmeans2(np.nan_to_num(data), k, iter=iter_n, thresh=5e-6, minit='points')
            L[:,boot]=clusters[1]+3

        matrix = np.zeros((n,n))
        dist=[]
        for boot in range(boot_n):
            tmp = np.atleast_2d(L[:,boot]).T*(1/(np.atleast_2d(L[:,boot]))) 
            tmp[tmp!=1]=0
            matrix+=tmp
            matrix_previous=matrix-tmp
            #plt.figure()
            #plt.imshow(matrix/float(boot)-matrix_previous/float(boot-1))
            # compute distance between two adjacent similarity matrix
            #dist.append(np.linalg.norm(matrix/float(boot)-matrix_previous/float(boot-1)))
            dist.append(np.linalg.norm(matrix-matrix_previous))
        self.dist=np.array(dist)
        self.matrix=matrix/float(boot_n)
        return self.matrix

    def linkage(self, input=[]):
        """1. generate the linkage matrix
        input=[]: run hierarchical clustering on the coclustering matrix
        input!=[]: run hierarchical clusttering on the input
        """
        if len(input)==0:
            self.Lin = sch.linkage(self.matrix, 'ward')
        else:
            self.Lin = sch.linkage(input, 'ward')

        # 'ward' is one of the methods that can be used to calculate the distance between newly formed clusters. 
        # 'ward' causes linkage() to use the Ward variance minimization algorithm.

        # 2. compares the actual pairwise distances of all your samples to those implied by the hierarchical clustering. 
        #c, coph_dists = sch.cophenet(Lin, pdist(matrix))
        #print(c)

    def plot_matrix(self, figname=[], input=[], D=[], vmax=1, vmin=0, cmap='Purples'):
        if len(D)==0:
            D = self.matrix
        else:
            D = D
        # Compute and plot dendrogram.
        fig = plt.figure()
        axdendro = fig.add_axes([0.09,0.1,0.2,0.8])
        if len(self.Lin)>0:
        	Y = self.Lin
        else:
            if len(input)==0:
                Y = sch.linkage(self.matrix, method='ward')
            else:
                Y = sch.linkage(input, method='ward')
        Z = sch.dendrogram(Y, orientation='right')
        axdendro.set_xticks([])
        axdendro.set_yticks([])

        # Plot distance matrix.
        axmatrix = fig.add_axes([0.3,0.1,0.6,0.8])
        index = Z['leaves']
        D = D[index,:]
        D = D[:,index]
        self.D_ordered = D
        im = axmatrix.matshow(D, origin='lower', cmap=cmap, vmax=vmax, vmin=vmin)
        axmatrix.set_xticks([])
        axmatrix.set_yticks([])

        # Plot colorbar.
        axcolor = fig.add_axes([0.91,0.1,0.02,0.8])
        plt.colorbar(im, cax=axcolor)

        if len(figname)>0:
            plt.savefig(figname) 
    
    def predict_cluster(self, **args):
        """
        predict number of clusters based on distance threshold or number of k.
        clusters start from 1
        """
        # 7. Retrieve the Clusters
        # 7.1 knowing max_d from dendrogram
        if 'max_d' in args.keys():
            self.clusters = sch.fcluster(self.Lin, args['max_d'], criterion='distance')
            np.unique(self.clusters)
        elif 'k' in args.keys():
            # knowing K
            self.clusters = sch.fcluster(self.Lin, args['k'], criterion='maxclust')
        return self.clusters

    def plot_clusters(self,Y):
        plt.figure(figsize=(12,8))
        plt.subplot(221)
        cmap = plt.cm.get_cmap('RdYlBu')
        plt.scatter(Y[:,0], Y[:,1], 20, c=cmap(0.9))
        plt.title('tSNE with 2D waveform',fontsize=16)

        # label could be RS/FS or depth
        labels = self.clusters-1 #clusters #mini.labels_ #ypos_all #new_type_all #ypos_all #RF_cluster[1]
        n_cluster = len(np.unique(labels))
        plt.subplot(222)
        cmap = plt.cm.get_cmap('spectral')
        #a = plt.scatter(Y[np.where(waveform_class=='fs')[0],0], Y[np.where(waveform_class=='fs')[0],1], 20, c=cmap(0.2))
        #b = plt.scatter(Y[np.where(waveform_class=='rs')[0],0], Y[np.where(waveform_class=='rs')[0],1], 20, c=cmap(0.4))
        #plt.legend((a,b), ('FS', 'RS'))
        for i in range(n_cluster):
            plt.plot(Y[np.where(labels==i)[0],0], Y[np.where(labels==i)[0],1], 20, c=cmap(1./n_cluster*i), label='group'+str(i))
        plt.legend(loc='upper left', numpoints=1, ncol=2, fontsize=10, bbox_to_anchor=(0, 0))

        #plt.savefig('/Users/xiaoxuanj/work/work_allen/DynamicBrain/figures/sessionB_ns_sg_matrix_cluster_colorplot.pdf')
        
    def save_class_file(self, filename):
        with open(filename + '.pkl', 'wb') as f:
            pickle.dump(self, f)
        f.close()