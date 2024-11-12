import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import scienceplots

data_dir = os.path.abspath(os.path.join(__file__, "..", "..", "simulation_data"))
cbf_dir = os.path.join(data_dir, "results_cbf_parallel_spectrum_estimator")
py_dir = os.path.join(data_dir, "results_cbf_py")
fig_out_dir = os.path.abspath(os.path.join(data_dir, "..", "..", "gitfigures", "system_design", "dsp", "sim_plots"))

py_fname = os.path.join(py_dir, "python_results.npy")

plt.style.use(['science','ieee'])
plt.rcParams.update({'font.size': '14'})

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

def get_py_sim_data(snapshots, basedir=py_dir):
    fname= os.path.join(py_dir, f"{snapshots}_snapshots.npy")
    data = np.load(fname)
    return data[-1]

def gen_snapshot_plot(word_length_power:int, snapshots:list, source_locations=[-20, 40]):
    fig = plt.figure()
    plt.title(f"Moving average snapshot count (simulated, fixed-point, WL={word_length_power})")
    plt.xlabel("Steering angle [degrees]")
    plt.ylabel("Normalized power")
    plt.vlines(source_locations, 0, 1, colors="r", linestyle="dashed")
    leg = ["Signal source"]
    scan_angles = np.arange(-50, 51, 2)
    for s in snapshots:
        data, aux = get_sim_data(s, word_length_power)
        leg.append(f"N={aux['Moving average snapshots']}")
        plt.plot(scan_angles, data, "-x", linewidth=2)
    plt.legend(leg)
    return fig

def gen_wordlength_plot(word_length_power:list, snapshots:int, source_locations=[-20, 40]):
    fig = plt.figure()
    plt.title(f"Word length for power (simulated, fixed-point, N={snapshots})")
    plt.xlabel("Steering angle [degrees]")
    plt.ylabel("Normalized power")
    plt.vlines(source_locations, 0, 1, colors="r", linestyle="dashed")
    leg = ["Signal source"]
    scan_angles = np.arange(-50, 51, 2)
    for wl in word_length_power:
        data, aux = get_sim_data(snapshots, wl)
        leg.append(f"WL={aux['Word length power']}")
        plt.plot(scan_angles, data, "-x", linewidth=2)
    plt.legend(leg)
    return fig

def gen_cmp_plot(power_word_lengths:list, snapshots:list, source_locations=[-20,40]):
    if isinstance(power_word_lengths, int):
        power_word_lengths = list(power_word_lengths)
    assert isinstance(power_word_lengths, list)
    if isinstance(snapshots, int):
        snapshots = list(snapshots)
    assert isinstance(snapshots, list)
    fig, (ax_py, ax_fpga) = plt.subplots(2, 1, sharex=True, figsize=(10,6), gridspec_kw={'wspace':0.5,'hspace':0.5})
    fig.suptitle("Comparison of implementations")
    ax_py.set_title(f"Floating-point")
    ax_py.set_ylabel("Normalized power")
    ax_py.vlines(source_locations, 0, 1, colors="r", linestyle="dashed")
    leg_py = ["Signal source"]
    ax_fpga.set_title(f"Fixed-point")
    ax_fpga.set_xlabel("Steering angle [degrees]")
    ax_fpga.set_ylabel("Normalized power")
    ax_fpga.vlines(source_locations, 0, 1, colors="r", linestyle="dashed")
    leg_fpga = ["Signal source"]
    scan_angles = np.arange(-50, 51, 2)
    for s in snapshots:
        data = get_py_sim_data(s)
        data = data / np.max(np.abs(data))
        leg_py.append(f"N={s}")
        ax_py.plot(scan_angles, data, "-x", linewidth=2)
    for s in snapshots:
        for pwl in power_word_lengths:
            data, aux = get_sim_data(s, pwl)
            leg_fpga.append(f"N={aux['Moving average snapshots']};WL={pwl}")
            ax_fpga.plot(scan_angles, data, "-x", linewidth=2)
    ax_py.legend(leg_py)
    ax_fpga.legend(leg_fpga)
    return fig

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", default=fig_out_dir)
    parser.add_argument("-s", "--snapshots", nargs="+", help="Snapshot counts to use ()", required=True)
    parser.add_argument("-w", "--wordlengths", nargs="+", help="Word lengths for representing power ()", required=True)
    parser.add_argument("-wc", "--wordlengths-comparison", nargs="*", help="Word lengths for representing power (for comparison plot)", required=True)
    parser.add_argument("-sc", "--snapshots-comparison", nargs="*", help="Word lengths for representing power (for comparison plot)", required=True)
    parser.add_argument("--source-locations", nargs="*", help="Locations of signal sources in simulation data file", default=[-20, 40])
    args = parser.parse_args()
    out_dir = args.output_dir
    snapshots:list = args.snapshots
    wordlengths:list = args.wordlengths
    s_cmp:list = args.snapshots_comparison
    wl_cmp:list = args.wordlengths_comparison
    source_locations = args.source_locations
    print(f"[+] Output directory: {out_dir}")
    print(f"[+] Snapshot counts: {snapshots}")
    print(f"[+] Power word lengths: {wordlengths}")
    print(f"[+] Snapshot counts (for comparison): {s_cmp}")
    print(f"[+] Power word lengths (for comparison): {wl_cmp}")
    os.makedirs(out_dir, exist_ok=True)
    if len(snapshots) > 1:
        for wl in wordlengths:
            f = gen_snapshot_plot(wl, snapshots, source_locations=source_locations)
            out_path = os.path.abspath(os.path.join(out_dir, f"fixed_point_snapshot_count_{wl}_wordlength.png"))
            print(f"[+] Saving snapshot figure at {out_path}")
            f.savefig(out_path)
    if len(wordlengths) > 1:
        for s in snapshots:
            f = gen_wordlength_plot(wordlengths, s, source_locations=source_locations)
            out_path = os.path.abspath(os.path.join(out_dir, f"fixed_point_wordlength_{s}_snapshots.png"))
            print(f"[+] Saving wordlength figure at {out_path}")
            f.savefig(out_path)
    if len(wl_cmp) > 0 and len(s_cmp) > 0:
        f = gen_cmp_plot(wl_cmp, s_cmp, source_locations=source_locations)
        out_path = os.path.abspath(os.path.join(out_dir, "implementation_comparison.png"))
        print(f"[+] Saving comparison figure at {out_path}")
        f.savefig(out_path)
    print("[+] Done")
