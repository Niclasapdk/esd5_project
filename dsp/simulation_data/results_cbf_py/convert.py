import numpy as np

with open("results", "rb") as f:
    raw = f.read()

slices = [raw[i:i+4*51] for i in range(0, len(raw), 4*51)]
spectrums = np.asarray([np.frombuffer(s, dtype=np.float32) for s in slices])
np.save("python_results.npy", spectrums)
# rename to {snapshot_count}_snapshots.npy naming convention manually
