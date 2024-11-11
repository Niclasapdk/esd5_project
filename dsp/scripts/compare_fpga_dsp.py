import os
import numpy as np
import matplotlib.pyplot as plt

data_dir = os.path.abspath(os.path.join(__file__, "..", "..", "simulation_data"))
cbf_dir = os.path.join(data_dir, "results_cbf_parallel_spectrum_estimator")

def fname(snapshots, word_length_power, basedir=cbf_dir):
    f = f"{snapshots}_snapshots_{word_length_power}_word_length_power.npy"
    return os.path.abspath(os.path.join(basedir, f))

cbf_spectrums = np.load(fname(8, 64))
scan_angles = np.arange(-50, 51, 2)
for i in range(cbf_spectrums.shape[0]):
    plt.plot(scan_angles, cbf_spectrums[i])
plt.show()
