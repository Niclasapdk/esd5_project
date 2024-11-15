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
py_dir = os.path.join(data_dir, "results_cbf_py")
fig_out_dir = os.path.abspath(os.path.join(data_dir, "..", "..", "gitfigures", "system_design", "dsp", "sim_plots"))

py_fname = os.path.join(py_dir, "python_results.npy")

def sim_basename(snapshots, word_length_power, basedir=cbf_dir):
    f = f"{snapshots}_snapshots_{word_length_power}_word_length_power"
    return os.path.abspath(os.path.join(basedir, f))

def get_sim_data(snapshots, word_length_power, basedir=cbf_dir):
    basename = sim_basename(snapshots, word_length_power, basedir=basedir)
    data = np.load(basename + ".npy")
    aux = {}
    with open(basename + ".txt", "r") as f:
        lines = f.readlines()
        for l in lines:
            l = l.strip().split(": ")
            aux[l[0]] = int(float(l[1]))
    return data[-1], aux

def get_py_sim_data(snapshots, snr_dB, basedir=py_dir):
    fname= os.path.join(basedir, f"{snapshots}_snapshots_{snr_dB}dB_snr.npy")
    data = np.load(fname)
    return data[-1]

def gen_snapshot_plot(word_length_power:int, snapshots:list, source_locations=[-20, 40]):
    fig, ax = plt.subplots()
    ax.set_title("Moving average snapshot count")
    ax.set_xlabel("Steering angle [degrees]")
    ax.set_ylabel("Normalized power")
    leg = []
    scan_angles = np.arange(-50, 51, 2)
    for s in snapshots:
        data, aux = get_sim_data(s, word_length_power)
        leg.append(f"$N={aux['Moving average snapshots']}$")
        ax.plot(scan_angles, data, "-x", linewidth=2)
    ax.legend(leg, fontsize=10)
    ax.vlines(source_locations, 0, 1, colors="r", linestyle="dashed")
    # Add subtitle
    subtitle = f"(Simulated, fixed-point, WL={word_length_power})"
    fig.text(0.2, 0.015, subtitle, ha='center', fontsize=10)
    return fig

def gen_wordlength_plot(word_length_power:list, snapshots:int, source_locations=[-20, 40]):
    fig, ax = plt.subplots()
    ax.set_title("Word length for power")
    ax.set_xlabel("Steering angle [degrees]")
    ax.set_ylabel("Normalized power")
    leg = []
    scan_angles = np.arange(-50, 51, 2)
    for wl in word_length_power:
        data, aux = get_sim_data(snapshots, wl)
        leg.append(f"$WL={aux['Word length power']}$")
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
    fig.suptitle("Comparison of implementations", fontsize=13)
    scan_angles = np.arange(-50, 51, 2)
    # Ensure axs is always iterable
    if n_snapshots == 1:
        axs = [axs]
    for idx, s in enumerate(snapshots):
        ax = axs[idx]
        ax.set_title(f"Snapshot count $N={s}$", fontsize=10)
        ax.set_ylabel("Normalized power")
        leg = []
        # Plot floating-point data
        data_fp = get_py_sim_data(s, snr_dB)
        data_fp = data_fp / np.max(np.abs(data_fp))
        ax.plot(scan_angles, data_fp, "-x", linewidth=2)
        leg.append(f"Floating-point $SNR={snr_dB}\\mathrm{dB}$")
        # Plot fixed-point data for each power word length
        for pwl in power_word_lengths:
            data_fx, aux = get_sim_data(s, pwl)
            ax.plot(scan_angles, data_fx, "-o", linewidth=2)
            leg.append(f"Fixed-point $WL={pwl}$")
        ax.vlines(source_locations, 0, 1, colors="r", linestyle="dashed")
        ax.legend(leg, fontsize=10, loc='lower right')
    axs[-1].set_xlabel("Steering angle [degrees]")
    # Add note below the figure
    note = "(Simulated data)"
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
    parser.add_argument("--snr-comparison", type=int, help="SNR in dB (for comparison plot)", required=True)
    parser.add_argument("--snr", nargs="*", help="SNR in dB (for comparison plot)", required=False, default=[80])
    parser.add_argument("--source-locations", nargs="*", help="Locations of signal sources in simulation data file", default=[-20, 40])
    args = parser.parse_args()
    out_dir = args.output_dir
    snapshots = [int(s) for s in args.snapshots]
    wordlengths = [int(wl) for wl in args.wordlengths]
    s_cmp = [int(s) for s in args.snapshots_comparison]
    wl_cmp = [int(wl) for wl in args.wordlengths_comparison]
    snr = [int(s) for s in args.snr]
    snr_cmp = args.snr_comparison
    source_locations = [float(sl) for sl in args.source_locations]
    print(f"[+] Output directory: {out_dir}")
    print(f"[+] Snapshot counts: {snapshots}")
    print(f"[+] Power word lengths: {wordlengths}")
    print(f"[+] SNR in dB: {snr}")
    print(f"[+] Snapshot counts (for comparison): {s_cmp}")
    print(f"[+] Power word lengths (for comparison): {wl_cmp}")
    print(f"[+] SNR in dB (for comparison): {snr_cmp}")
    os.makedirs(out_dir, exist_ok=True)
    if len(snapshots) > 1:
        for wl in wordlengths:
            f = gen_snapshot_plot(wl, snapshots, source_locations=source_locations)
            out_path = os.path.abspath(os.path.join(out_dir, f"fixed_point_snapshot_count_{wl}_wordlength.png"))
            print(f"[+] Saving snapshot figure at {out_path}")
            f.savefig(out_path, bbox_inches='tight', dpi=300)
    if len(wordlengths) > 1:
        for s in snapshots:
            f = gen_wordlength_plot(wordlengths, s, source_locations=source_locations)
            out_path = os.path.abspath(os.path.join(out_dir, f"fixed_point_wordlength_{s}_snapshots.png"))
            print(f"[+] Saving wordlength figure at {out_path}")
            f.savefig(out_path, bbox_inches='tight', dpi=300)
    if len(wl_cmp) > 0 and len(s_cmp) > 0:
        f = gen_cmp_plot(wl_cmp, s_cmp, snr_cmp, source_locations=source_locations)
        out_path = os.path.abspath(os.path.join(out_dir, "implementation_comparison.png"))
        print(f"[+] Saving comparison figure at {out_path}")
        f.savefig(out_path, bbox_inches='tight', dpi=300)
    if len(snr) > 0:
        out_path = os.path.abspath(os.path.join(out_dir, "snr_comparison.png"))
        print(f"[+] Saving SNR figure at {out_path}")
    print("[+] Done")
