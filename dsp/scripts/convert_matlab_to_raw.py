import scipy.io
import numpy as np
import os

data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "simulation_data"))

files = os.listdir(data_dir)
files_to_convert = []
for f in files:
    if f.endswith(".mat"):
        files_to_convert.append(os.path.abspath(os.path.join(data_dir, f)))

for fname in files_to_convert:
    print(fname)
    mat = scipy.io.loadmat(fname)
    interleaved_data = mat.get("signal").astype("complex64").flatten()
    max_magnitude = np.abs(interleaved_data).max()
    normalized_data = interleaved_data / max_magnitude
    with open(fname.replace(".mat", ".raw"), "wb") as f:
        normalized_data.tofile(f)
