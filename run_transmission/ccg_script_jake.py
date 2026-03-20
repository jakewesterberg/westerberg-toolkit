# -*- coding: utf-8 -*-
"""
Created on Thu Oct 12 11:12:42 2023

@author: jakew
"""

import sys

sys.path.append('C:/Users/jakew/OneDrive/Documents/Github/westerberg-toolkit/run_transmission')

import ccg_jxx
import numpy as np

def jake_ccgs(spikes_file, FR_file):
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
            temp_ccg[ctr1, ctr2, :] = ccgjitter[ctr0, t_range]
            ctr1 += 1
            ctr0 += 1
            if ctr1 > n_good_units-1:
                ctr2 += 1
                ctr1 = 0
        else:
            ctr1 +=1
        
        if ctr0 > np.size(ccgjitter, axis=0)-1:
            break
            
        
    ctr0 = 0
    ctr1 = 0
    ctr2 = 0    
    while True:
        if ctr1 < ctr2:
            temp_ccg[ctr1, ctr2, :] = np.flip(ccgjitter[ctr0, t_range])
            ctr1 += 1
            ctr0 += 1
            
        else:
            ctr1 +=1
            if ctr1 > n_good_units-1:
                ctr2 += 1
                ctr1 = 0
            
        if ctr0 > np.size(ccgjitter, axis=0)-1:
            break
        
    ccgjitter = temp_ccg    
    adj_matrix = np.mean(ccgjitter[:,:,87:99], axis=2) - np.mean(ccgjitter[:,:,100:112], axis=2)
    
    np.save(FR_file[:-6] + "ccgjitter.npy", ccgjitter)
    np.save(FR_file[:-6] + "adjacency_matrix.npy", adj_matrix)
        