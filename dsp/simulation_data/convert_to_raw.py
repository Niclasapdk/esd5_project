import scipy.io
import numpy as np
import os

files = os.listdir()
files_to_convert = []
for f in files:
    if f.endswith(".mat"):
        files_to_convert.append(f)

for fname in files_to_convert:
    mat = scipy.io.loadmat(fname)
    interleaved_data = mat.get("signal").astype("complex64").flatten()
    max_magnitude = np.abs(interleaved_data).max()
    normalized_data = interleaved_data / max_magnitude
    with open(fname.replace(".mat", ".raw"), "wb") as f:
        normalized_data.tofile(f)
