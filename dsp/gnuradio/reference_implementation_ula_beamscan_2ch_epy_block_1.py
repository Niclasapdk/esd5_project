"""
Embedded Python Blocks:

Each time this file is saved, GRC will instantiate the first class it finds
to get ports and parameters of your block. The arguments to __init__  will
be the parameters. All of them are required to have default values!
"""

import numpy as np
from gnuradio import gr


class blk(gr.basic_block):
    """MVDR spatial spectrum estimator for 4 channel ULA"""

    def __init__(self, num_samples=16, signal_freq=2.44e9, array_d=0.5, phi_scan_min=-50, phi_scan_max=50, phi_step=2, rx1_phase_cal=0, rx2_phase_cal=0, rx3_phase_cal=0, rx4_phase_cal=0):
        """arguments to this function show up as parameters in GRC"""
        # must change default phi values to pass static vector_len checks (goofy but that's how gnuradio is)
        self.spectrum_len = 1+(phi_scan_max-phi_scan_min)//phi_step
        gr.basic_block.__init__(
            self,
            name='MVDR spatial spectrum estimator',   # will show up in GRC
            in_sig=[np.complex64, np.complex64, np.complex64, np.complex64],
            out_sig=[(np.float32, self.spectrum_len)]
        )
        self.logger = gr.logger(self.alias())
        self.num_samples = num_samples
        self.signal_freq = signal_freq
        self.steering_step = phi_step
        self.d = array_d
        self.c = 299792458
        self.lambda_ = self.c / self.signal_freq
        self.steering_angles = np.arange(phi_scan_min, phi_scan_max+1, phi_step)
        steervec = lambda n, cal: np.exp(-1j * (np.pi * n * np.sin(np.deg2rad(self.steering_angles)) + np.deg2rad(cal)))
        self.win = np.hamming(self.num_samples)
        self.rx1_phase_cal = rx1_phase_cal
        self.rx2_phase_cal = rx2_phase_cal
        self.rx3_phase_cal = rx3_phase_cal
        self.rx4_phase_cal = rx4_phase_cal
        self.logger.info(f"creating block with spectrum length {self.spectrum_len}")
        # if an attribute with the same name as a parameter is found,
        # a callback is registered (properties work, too).
        self.steering_vectors = np.asarray([
                steervec(0, self.rx1_phase_cal),
                steervec(1, self.rx2_phase_cal),
                steervec(2, self.rx3_phase_cal),
                steervec(3, self.rx4_phase_cal)]).transpose() # e^{-j*phase_shift}
        # transpose steering vector array so indexing is (phi, antenna)
        self.logger.info(f"steering_vectors: {self.steering_vectors}")

    def general_work(self, input_items, output_items):
        for i in range(4):
            if len(input_items[i]) < self.num_samples:
                return 0
        signals_in = np.asmatrix(np.asarray([input_items[0][:self.num_samples],
                                 input_items[1][:self.num_samples],
                                 input_items[2][:self.num_samples],
                                 input_items[3][:self.num_samples]]).T)
        R = (signals_in.H @ signals_in) / self.num_samples
        R_inv = np.linalg.inv(R)
        spectrum = np.zeros(self.spectrum_len)
        for i in range(self.spectrum_len):
            s = np.asmatrix(self.steering_vectors[i]).T
            w = R_inv @ (s / (s.H @ R_inv @ s));
            sig_mvdr = signals_in @ w
            p_mvdr = np.mean(np.square(np.abs(sig_mvdr)), axis=0).astype(np.float32)[0,0]
            spectrum[i] = p_mvdr
        output_items[0][:] = spectrum
        for i in range(4):
            self.consume(i, self.num_samples)
        return len(output_items[0])
