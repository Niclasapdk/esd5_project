"""
Embedded Python Blocks:

Each time this file is saved, GRC will instantiate the first class it finds
to get ports and parameters of your block. The arguments to __init__  will
be the parameters. All of them are required to have default values!
"""

import numpy as np
from gnuradio import gr


class blk(gr.basic_block):
    """Beamscan spatial spectrum estimator for 4 channel ULA"""

    def __init__(self, num_samples=51, signal_freq=2.44e9, array_d=0.5, phi_scan_min=-50, phi_scan_max=50, phi_step=2, rx1_phase_cal=0, rx2_phase_cal=0, rx3_phase_cal=0, rx4_phase_cal=0):
        """arguments to this function show up as parameters in GRC"""
        # must change default phi values to pass static vector_len checks (goofy but that's how gnuradio is)
        self.spectrum_len = 1+(phi_scan_max-phi_scan_min)//phi_step
        gr.basic_block.__init__(
            self,
            name='Beamscan spatial spectrum estimator',   # will show up in GRC
            in_sig=[np.complex64, np.complex64, np.complex64, np.complex64],
            out_sig=[(np.float32, self.spectrum_len), np.float32, np.float32]
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
        signals_in = np.asarray([input_items[0][:self.num_samples],
                                 input_items[1][:self.num_samples],
                                 input_items[2][:self.num_samples],
                                 input_items[3][:self.num_samples]])
        steervecs = self.steering_vectors
        sig_beamformed = np.matmul(steervecs, signals_in) # dimension: phi X snapshot
        spectrum = np.mean(np.square(np.abs(sig_beamformed)), axis=1).astype("float32")
        peak_value = np.max(spectrum).astype("float32")
        doa = self.steering_angles[np.argmax(spectrum)]
        output_items[0][:] = spectrum
        output_items[1][:] = doa
        output_items[2][:] = peak_value
        for i in range(4):
            self.consume(i, self.num_samples)
        return len(output_items[0])
