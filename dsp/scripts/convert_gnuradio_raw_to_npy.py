import numpy as np
import os

def conv(inpath, outpath):
    print(f"[+] Converting {inpath} to {outpath}")
    with open(inpath, "rb") as f:
        raw = f.read()
    slices = [raw[i:i+4*51] for i in range(0, len(raw), 4*51)]
    spectrums = np.asarray([np.frombuffer(s, dtype=np.float32) for s in slices])
    np.save(outpath, spectrums)

data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "simulation_data"))

dirs = [
    os.path.abspath(os.path.join(data_dir, "results_cbf_py")),
    os.path.abspath(os.path.join(data_dir, "results_mvdr_py")),
]
files_to_convert = []
for d in dirs:
    files = os.listdir(d)
    for f in files:
        if f.endswith(".raw"):
            files_to_convert.append(os.path.abspath(os.path.join(d, f)))

for fname in files_to_convert:
    inpath = fname
    outpath = fname.replace(".raw", ".npy")
    conv(inpath, outpath)
