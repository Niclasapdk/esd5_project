import math
import numpy as np
import os
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
from multiprocessing import Pool
import logging

def conv(inpath, outpath):
    logging.info(f"Converting {inpath} to {outpath}")
    with open(inpath, "rb") as f:
        raw = f.read()
    slices = [raw[i:i+8*4] for i in range(0, len(raw), 8*4)]
    spectrums = np.asarray([np.frombuffer(s, dtype=np.complex64) for s in slices]).T
    zero_columns = np.all(spectrums == 0, axis=0)
    spectrums = spectrums[:, ~zero_columns]
    np.save(outpath, spectrums, allow_pickle=False)

def steervecs(n: np.ndarray, cal: np.ndarray, steering_angles: np.ndarray):
    cal = np.reshape(cal, (1, 4))
    n = np.reshape(n, (1, 4))
    steering_angles = np.reshape(steering_angles, (len(steering_angles), 1))
    return np.exp(-1j * (np.pi * n * np.sin(np.deg2rad(steering_angles)) + np.deg2rad(cal)))

def rolling_cbf(data: np.ndarray, steering_angles: np.ndarray, snapshot_count: int):
    assert data.shape[0] == 4, "expected a (4,N) array"
    assert math.log2(snapshot_count) == int(math.log2(snapshot_count)), "expected power of 2"
    num_spec_samps = num_spectrum_samples(data, snapshot_count)
    logging.info(f"Rolling cbf with")
    logging.info(f"\tSnapshot count: {snapshot_count}")
    logging.info(f"\tData shape: {data.shape}")
    logging.info(f"\tSpectrum samples: {num_spec_samps}")
    vecs = steervecs(np.asarray([0, 1, 2, 3]), np.asarray([0, 0, 0, 0]), steering_angles).astype(np.complex64)
    spectrums = np.zeros((len(steering_angles), num_spec_samps))
    doa = np.zeros(num_spec_samps)
    for i in range(num_spec_samps):
        start_idx = i * snapshot_count
        stop_idx = (i + 1) * snapshot_count
        sig_beamformed = vecs @ data[:, start_idx:stop_idx]
        spec = np.mean(np.square(np.abs(sig_beamformed)), axis=1).astype("float32")
        spectrums[:, i] = spec
        doa[i] = steering_angles[np.argmax(spec)]
    return spectrums / spectrums.max(), doa

def rolling_mvdr(data: np.ndarray, steering_angles: np.ndarray, snapshot_count: int):
    assert data.shape[0] == 4, "expected a (4,N) array"
    assert math.log2(snapshot_count) == int(math.log2(snapshot_count)), "expected power of 2"
    num_spec_samps = num_spectrum_samples(data, snapshot_count)
    logging.info(f"Rolling mvdr with")
    logging.info(f"\tSnapshot count: {snapshot_count}")
    logging.info(f"\tData shape: {data.shape}")
    logging.info(f"\tSpectrum samples: {num_spec_samps}")
    vecs = steervecs(np.asarray([0, 1, 2, 3]), np.asarray([0, 0, 0, 0]), steering_angles).astype(np.complex64)
    spectrums = np.zeros((len(steering_angles), num_spec_samps), dtype=np.float32)
    doa = np.zeros(num_spec_samps)
    errs = 0
    for i in range(num_spec_samps):
        start_idx = i * snapshot_count
        stop_idx = (i + 1) * snapshot_count
        signals_in = np.asmatrix(data[:, start_idx:stop_idx].T, dtype=np.complex64)
        R = (signals_in.H @ signals_in) / snapshot_count
        all_zeros = not np.any(R)
        if all_zeros:
            continue
        try:
            R_inv = np.linalg.inv(R)
        except np.linalg.LinAlgError as e:
            errs += 1
            continue
        for j in range(vecs.shape[0]):
            s = np.asmatrix(vecs[j, :]).T
            denom = (s.H @ R_inv @ s)
            if np.isclose(denom, 0):
                continue
            P = 1 / denom
            spectrums[j, i] = P[0, 0].real
        doa[i] = steering_angles[np.argmax(spectrums[:, i])]
    logging.info(f"Encountered {errs} errors")
    return spectrums / spectrums.max(), doa

def num_spectrum_samples(data, snapshot_count):
    return data.shape[1] // snapshot_count

def pow2db(data):
    return 10 * np.log10(data)

def times(data, snapshot_count, samp_rate, num=1000000000000000):
    num_spec_samps = num_spectrum_samples(data, snapshot_count)
    num_spec_samps = min(num_spec_samps, num)
    samp_period = 1 / samp_rate
    t = np.zeros(num_spec_samps)
    for i in range(num_spec_samps):
        t[i] = samp_period * (i * snapshot_count) * 160
    return t

def process_cbf_plot(args):
    dtry, N, data_dir, fig_out_dir = args
    cache_dir = data_dir
    data_file = os.path.join(data_dir, f"data_try{dtry}")
    cache_file = os.path.join(cache_dir, ".cache_" + os.path.basename(data_file) + ".npy")
    doa_trace_file = os.path.join(data_dir, f"doa_data{dtry}")
    if not os.path.exists(cache_file):
        conv(data_file, cache_file)
    data = np.load(cache_file)
    steering_angles = np.asarray([i for i in range(-65, 66, 2)])
    samp_rate = 5.12e6
    t = times(data, N, samp_rate)
    cbf, doa = rolling_cbf(data, steering_angles, N)
    doa_trace = get_real_doa(doa_trace_file, N, cbf)
    f, axs = plt.subplots(2, 1, sharex=True, figsize=(6.4, 6.4))
    f.suptitle(f"CBF for N={N}", fontsize=11)
    axs[0].set_title("Spatial Spectrum vs. Time")
    axs[0].set_xlabel("Time [s]")
    axs[0].set_ylabel("Steering angle [\u00b0]")
    axs[0].pcolormesh(t, steering_angles, cbf, shading='auto')
    axs[1].set_title("Angle of Arrival estimation")
    axs[1].set_xlabel("Time [s]")
    axs[1].set_ylabel("Angle of max power [\u00b0]")
    axs[1].plot(t, doa)
    axs[1].plot(t, doa_trace)
    axs[1].legend(["Output", "Real DOA"])
    out_path = os.path.join(fig_out_dir, f"cbf_{N}_snapshots_from_data{dtry}.png")
    f.tight_layout()  # call this last
    logging.info(f"Saving figure to {out_path}")
    f.savefig(out_path, bbox_inches='tight', dpi=300)
    plt.close()
    return True

def process_mvdr_plot(args):
    dtry, N, data_dir, fig_out_dir = args
    cache_dir = data_dir
    data_file = os.path.join(data_dir, f"data_try{dtry}")
    cache_file = os.path.join(cache_dir, ".cache_" + os.path.basename(data_file) + ".npy")
    doa_trace_file = os.path.join(data_dir, f"doa_data{dtry}")
    if not os.path.exists(cache_file):
        conv(data_file, cache_file)
    data = np.load(cache_file)
    steering_angles = np.asarray([i for i in range(-65, 66, 1)])
    samp_rate = 5.12e6
    t = times(data, N, samp_rate)
    mvdr, doa = rolling_mvdr(data, steering_angles, N)
    doa_trace = get_real_doa(doa_trace_file, N, mvdr)
    f, axs = plt.subplots(2, 1, sharex=True, figsize=(6.4, 6.4))
    f.suptitle(f"MVDR for N={N}", fontsize=11)
    axs[0].set_title("Spatial Spectrum vs. Time")
    axs[0].set_xlabel("Time [s]")
    axs[0].set_ylabel("Steering angle [\u00b0]")
    axs[0].pcolormesh(t, steering_angles, mvdr, shading='auto')
    axs[1].set_title("Angle of Arrival estimation")
    axs[1].set_xlabel("Time [s]")
    axs[1].set_ylabel("Angle of max power [\u00b0]")
    axs[1].plot(t, doa)
    axs[1].plot(t, doa_trace)
    axs[1].legend(["Output", "Real DOA"])
    out_path = os.path.join(fig_out_dir, f"mvdr_{N}_snapshots_from_data{dtry}.png")
    f.tight_layout()  # call this last
    logging.info(f"Saving figure to {out_path}")
    f.savefig(out_path, bbox_inches='tight', dpi=300)
    plt.close()
    return True

def get_real_doa(fname, N, spectrums, N_file=128):
    with open(fname, "r") as f:
        lines = f.readlines()
    assert len(lines) % 2 == 0, "must be even since deg, times pairs"

    def straight_line(x0, x1, y0, y1):
        num = x1 - x0
        a = (y1 - y0) / (x1 - x0)
        l = np.zeros(num)
        for x in range(num):
            l[x] = a*x + y0
        return l

    def scale(x, N, N_file):
        if x == -1:
            return spectrums.shape[1]
        return (x * N_file) // N

    degs = []
    times = []
    for i in range(0, len(lines), 2):
        deg_str = lines[i].strip()
        t_str = lines[i+1].strip()
        deg, chk = deg_str.split(" ")
        assert chk == "deg"
        t = list(map(lambda x: scale(int(x), N, N_file), t_str.split(" to ")))
        degs.append(int(deg))
        times.append((t[0], t[1]))

    doa = np.zeros(spectrums.shape[1])
    for i in range(len(degs)-1):
        t0 = times[i][0]
        t_trans0 = times[i][1]
        t_trans1 = times[i+1][0]
        y_now = degs[i]
        y_next = degs[i+1]
        l = straight_line(t_trans0, t_trans1, y_now, y_next)
        doa[t0:t_trans0] = y_now
        doa[t_trans0:t_trans1] = l
    doa[times[-1][0]:times[-1][1]] = degs[-1] # set last one
    return doa

if __name__ == "__main__":
    import matplotlib
    matplotlib.use('Agg')  # Use non-interactive backend
    from tqdm import tqdm

    # Set up logging to file
    logging.basicConfig(filename='processing.log', level=logging.INFO,
                        format='%(asctime)s %(processName)s %(levelname)s: %(message)s')

    # Use LaTeX fonts in matplotlib for consistency with your document
    plt.rcParams.update({
        "text.usetex": True,
        "font.family": "serif",
        "font.size": 11,  # Base font size to match LaTeX
    })

    data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "measured_data", "satimo"))
    fig_out_dir = os.path.abspath(os.path.join(data_dir, "..", "..", "..", "gitfigures", "system_design", "dsp", "meas_plots"))
    N_cbf = [2**i for i in range(3, 12)]
    N_mvdr = [2**i for i in range(7, 12)]

    cbf_tasks = []
    mvdr_tasks = []

    for dtry in range(1, 5):
        for N in N_cbf:
            cbf_tasks.append((dtry, N, data_dir, fig_out_dir))
        for N in N_mvdr:
            mvdr_tasks.append((dtry, N, data_dir, fig_out_dir))

    # Use multiprocessing to utilize all CPU cores
    with Pool() as pool:
        # Process CBF tasks with progress bar
        print("Processing CBF tasks:")
        for _ in tqdm(pool.imap_unordered(process_cbf_plot, cbf_tasks), total=len(cbf_tasks)):
            pass

        # Process MVDR tasks with progress bar
        print("Processing MVDR tasks:")
        for _ in tqdm(pool.imap_unordered(process_mvdr_plot, mvdr_tasks), total=len(mvdr_tasks)):
            pass
