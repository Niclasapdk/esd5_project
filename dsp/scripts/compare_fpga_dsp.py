import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import scienceplots

# Use LaTeX fonts in matplotlib for consistency with your document
plt.rcParams.update({
    "text.usetex": True,
    "font.family": "serif",
    "font.serif": ["Computer Modern"],
    "font.size": 11,  # Base font size to match LaTeX
})

data_dir = os.path.abspath(os.path.join(__file__, "..", "..", "simulation_data"))
cbf_dir = os.path.join(data_dir, "results_cbf_parallel_spectrum_estimator")
py_cbf_dir = os.path.join(data_dir, "results_cbf_py")
py_mvdr_dir = os.path.join(data_dir, "results_mvdr_py")
fig_out_dir = os.path.abspath(os.path.join(data_dir, "..", "..", "gitfigures", "system_design", "dsp", "sim_plots"))

def normalize_ar(ar: np.ndarray):
    return ar / np.abs(ar).max()

def sim_basename(snapshots, word_length_power, snr_dB, basedir=cbf_dir):
    f = f"{snapshots}_snapshots_{word_length_power}_word_length_power_{snr_dB}dB_snr"
    return os.path.abspath(os.path.join(basedir, f))

def get_sim_data(snapshots, word_length_power, snr_dB, basedir=cbf_dir):
    basename = sim_basename(snapshots, word_length_power, snr_dB, basedir=basedir)
    data = np.load(basename + ".npy")
    aux = {}
    with open(basename + ".txt", "r") as f:
        lines = f.readlines()
        for l in lines:
            l = l.strip().split(": ")
            aux[l[0]] = int(float(l[1]))
    return data[-1], aux

def get_py_sim_data(snapshots, snr_dB, targets=2, basedir=py_cbf_dir):
    fname= os.path.join(basedir, f"{targets}_targets_{snapshots}_snapshots_{snr_dB}dB_snr.npy")
    data = np.load(fname)
    return data[-1]

def gen_snapshot_plot(word_length_power:int, snapshots:list, snr:int, source_locations=[-20, 40]):
    fig, ax = plt.subplots()
    ax.set_title("Moving average snapshot count")
    ax.set_xlabel("Steering angle [degrees]")
    ax.set_ylabel("Normalized power")
    leg = []
    scan_angles = np.arange(-50, 51, 2)
    for s in snapshots:
        data, aux = get_sim_data(s, word_length_power, snr)
        leg.append(f"N={aux['Moving average snapshots']}")
        ax.plot(scan_angles, data, "-x", linewidth=2)
    ax.legend(leg, fontsize=10)
    ax.vlines(source_locations, 0, 1, colors="r", linestyle="dashed")
    # Add subtitle
    subtitle = f"(Simulated, fixed-point, WL={word_length_power})"
    fig.text(0.2, 0.015, subtitle, ha='center', fontsize=10)
    return fig

def gen_wordlength_plot(word_length_power:list, snapshots:int, snr:int, source_locations=[-20, 40]):
    fig, ax = plt.subplots()
    ax.set_title("Word length for power")
    ax.set_xlabel("Steering angle [degrees]")
    ax.set_ylabel("Normalized power")
    leg = []
    scan_angles = np.arange(-50, 51, 2)
    for wl in word_length_power:
        data, aux = get_sim_data(snapshots, wl, snr)
        leg.append(f"WL={aux['Word length power']}")
        ax.plot(scan_angles, data, "-x", linewidth=2)
    ax.legend(leg, fontsize=10)
    ax.vlines(source_locations, 0, 1, colors="r", linestyle="dashed")
    # Add subtitle
    subtitle = f"(Simulated, fixed-point, N={snapshots})"
    fig.text(0.2, 0.015, subtitle, ha='center', fontsize=10)
    return fig

def gen_cmp_plot(power_word_lengths:list, snapshots:list, snr_dB: int, source_locations=[-20,40]):
    if isinstance(power_word_lengths, int):
        power_word_lengths = [power_word_lengths]
    assert isinstance(power_word_lengths, list)
    if isinstance(snapshots, int):
        snapshots = [snapshots]
    assert isinstance(snapshots, list)
    n_snapshots = len(snapshots)
    fig, axs = plt.subplots(n_snapshots, 1, sharex=True, figsize=(6.4, 2.6 * n_snapshots))
    fig.suptitle("Comparison of CBF implementations", fontsize=13)
    scan_angles = np.arange(-50, 51, 2)
    # Ensure axs is always iterable
    if n_snapshots == 1:
        axs = [axs]
    for idx, s in enumerate(snapshots):
        ax = axs[idx]
        ax.set_title(f"Snapshot count N={s}", fontsize=10)
        ax.set_ylabel("Normalized power")
        leg = []
        # Plot floating-point data
        data_fp = get_py_sim_data(s, snr_dB)
        data_fp = normalize_ar(data_fp)
        ax.plot(scan_angles, data_fp, "-x", linewidth=2)
        leg.append(f"Floating-point")
        # Plot fixed-point data for each power word length
        for pwl in power_word_lengths:
            data_fx, aux = get_sim_data(s, pwl, snr_dB)
            ax.plot(scan_angles, data_fx, "-o", linewidth=2)
            leg.append(f"Fixed-point WL={pwl}")
        ax.vlines(source_locations, 0, 1, colors="r", linestyle="dashed")
        ax.legend(leg, fontsize=10, loc='lower right')
    axs[-1].set_xlabel("Steering angle [degrees]")
    # Add note below the figure
    note = f"(Simulated data, SNR={snr_dB}dB)"
    fig.text(0.2, 0.015, note, ha='center', fontsize=10)
    return fig

def gen_snr_plot(snapshots:int, snrs:list, source_locations=[-20, 40]):
    assert isinstance(snapshots, int)
    n_snrs = len(snrs)
    fig, axs = plt.subplots(n_snrs, 1, sharex=True, figsize=(6.4, 2.6 * n_snrs))
    fig.suptitle("Comparison of MVDR and CBF", fontsize=13)
    scan_angles = np.arange(-50, 51, 2)
    # Ensure axs is always iterable
    if n_snrs == 1:
        axs = [axs]
    for idx, snr in enumerate(snrs):
        ax = axs[idx]
        ax.set_title(f"SNR={snr}dB", fontsize=10)
        ax.set_ylabel("Normalized power")
        leg = []
        data_cbf = normalize_ar(get_py_sim_data(snapshots, snr, basedir=py_cbf_dir))
        ax.plot(scan_angles, data_cbf, "-x", linewidth=2)
        leg.append(f"CBF")
        data_mvdr = normalize_ar(get_py_sim_data(snapshots, snr, basedir=py_mvdr_dir))
        ax.plot(scan_angles, data_mvdr, "-o", linewidth=2)
        leg.append(f"MVDR")
        ax.vlines(source_locations, 0, 1, colors="r", linestyle="dashed")
        ax.legend(leg, fontsize=10, loc='lower right')
    axs[-1].set_xlabel("Steering angle [degrees]")
    # Add note below the figure
    note = f"(Simulated, floating-point, N={snapshots})"
    fig.text(0.2, 0.015, note, ha='center', fontsize=10)
    return fig

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", default=fig_out_dir)
    parser.add_argument("-s", "--snapshots", nargs="+", help="Snapshot counts to use ()", required=True)
    parser.add_argument("-w", "--wordlengths", nargs="+", help="Word lengths for representing power ()", required=True)
    parser.add_argument("-wc", "--wordlengths-comparison", nargs="*", help="Word lengths for representing power (for comparison plot)", required=True)
    parser.add_argument("-sc", "--snapshots-comparison", nargs="*", help="Snapshot counts (for comparison plot)", required=True)
    parser.add_argument("--snr", nargs="*", help="SNR in dB (for comparison plot)", required=False, default=[80])
    parser.add_argument("--source-locations", nargs="*", help="Locations of signal sources in simulation data file", default=[-20, 40])
    args = parser.parse_args()
    out_dir = args.output_dir
    snapshots = [int(s) for s in args.snapshots]
    wordlengths = [int(wl) for wl in args.wordlengths]
    s_cmp = [int(s) for s in args.snapshots_comparison]
    wl_cmp = [int(wl) for wl in args.wordlengths_comparison]
    snrs = [int(s) for s in args.snr]
    source_locations = [float(sl) for sl in args.source_locations]
    print(f"[+] Output directory: {out_dir}")
    print(f"[+] Snapshot counts: {snapshots}")
    print(f"[+] Power word lengths: {wordlengths}")
    print(f"[+] SNR in dB: {snrs}")
    print(f"[+] Snapshot counts (for comparison): {s_cmp}")
    print(f"[+] Power word lengths (for comparison): {wl_cmp}")
    os.makedirs(out_dir, exist_ok=True)
    if len(snapshots) > 1:
        for wl in wordlengths:
            for snr in snrs:
                f = gen_snapshot_plot(wl, snapshots, snr, source_locations=source_locations)
                out_path = os.path.abspath(os.path.join(out_dir, f"fixed_point_snapshot_count_{wl}_wordlength_{snr}dB_snr.png"))
                print(f"[+] Saving snapshot figure at {out_path}")
                f.savefig(out_path, bbox_inches='tight', dpi=300)
                plt.close()
    if len(wordlengths) > 1:
        for s in snapshots:
            for snr in snrs:
                f = gen_wordlength_plot(wordlengths, s, snr, source_locations=source_locations)
                out_path = os.path.abspath(os.path.join(out_dir, f"fixed_point_wordlength_{s}_snapshots_{snr}dB_snr.png"))
                print(f"[+] Saving wordlength figure at {out_path}")
                f.savefig(out_path, bbox_inches='tight', dpi=300)
                plt.close()
    if len(wl_cmp) > 0 and len(s_cmp) > 0:
        for snr in snrs:
            f = gen_cmp_plot(wl_cmp, s_cmp, snr, source_locations=source_locations)
            out_path = os.path.abspath(os.path.join(out_dir, f"implementation_comparison_{snr}dB_snr.png"))
            print(f"[+] Saving comparison figure at {out_path}")
            f.savefig(out_path, bbox_inches='tight', dpi=300)
            plt.close()
    if len(snrs) > 0:
        for s in snapshots:
            f = gen_snr_plot(s, snrs)
            out_path = os.path.abspath(os.path.join(out_dir, f"snr_comparison_{s}_snapshots.png"))
            print(f"[+] Saving SNR figure at {out_path}")
            f.savefig(out_path, bbox_inches='tight', dpi=300)
            plt.close()
    print("[+] Done")
