import numpy as np
import os
import ctypes

cwd = os.path.dirname(__file__)
output_dir = os.path.abspath(os.path.join(cwd, "rtl", "autogenerated"))
os.makedirs(output_dir, exist_ok=True)

rx1_phase_cal = 0
rx2_phase_cal = 0
rx3_phase_cal = 0
rx4_phase_cal = 0

phi_scan_step = 2
phi_scan_min = -50 # inclusive
phi_scan_max = 51 # exclusive
phi_scan_max -= 1 # don't touch

d = 0.5 # wavelengths

steering_angles = np.arange(phi_scan_min, phi_scan_max+1, phi_scan_step)
phi_scan_len = len(steering_angles)
print(f"PHI_SCAN_NUM_STEPS={phi_scan_len}")
with open(os.path.join(output_dir, "beamscan_header.vh"), "w") as f:
    f.write(f"parameter PHI_SCAN_NUM_STEPS = {phi_scan_len};")
steervec = lambda n, cal: np.exp(-1j * (np.pi * n * np.sin(np.deg2rad(steering_angles)) + np.deg2rad(cal)))
steering_vectors = np.asarray([ # (antenna, scan angle)
        steervec(0, rx1_phase_cal),
        steervec(1, rx2_phase_cal),
        steervec(2, rx3_phase_cal),
        steervec(3, rx4_phase_cal)])
# fixed point
I_steering_vectors_fp = np.real(steering_vectors*0x7ff).astype(np.int16)
Q_steering_vectors_fp = np.imag(steering_vectors*0x7ff).astype(np.int16)

for i_ant, (Is, Qs) in enumerate(zip(I_steering_vectors_fp, Q_steering_vectors_fp)):
    ant = i_ant+1
    with open(os.path.join(output_dir, f"I_steervecs_{ant}.hex"), "w") as f:
        for I in Is:
            f.write(hex(ctypes.c_ushort(I).value).replace("0x", "") + "\n")
    with open(os.path.join(output_dir, f"Q_steervecs_{ant}.hex"), "w") as f:
        for Q in Qs:
            f.write(hex(ctypes.c_ushort(Q).value).replace("0x", "") + "\n")
