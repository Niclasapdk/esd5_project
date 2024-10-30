#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Beamscan spatial spectrum estimation
# Author: markus
# GNU Radio version: 3.10.11.0

from PyQt5 import Qt
from gnuradio import qtgui
from gnuradio import blocks
import pmt
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import sys
import signal
from PyQt5 import Qt
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
import reference_implementation_ula_beamscan_2ch_epy_block_0 as epy_block_0  # embedded python block
import sip
import threading



class reference_implementation_ula_beamscan_2ch(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "Beamscan spatial spectrum estimation", catch_exceptions=True)
        Qt.QWidget.__init__(self)
        self.setWindowTitle("Beamscan spatial spectrum estimation")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except BaseException as exc:
            print(f"Qt GUI: Could not set Icon: {str(exc)}", file=sys.stderr)
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("gnuradio/flowgraphs", "reference_implementation_ula_beamscan_2ch")

        try:
            geometry = self.settings.value("geometry")
            if geometry:
                self.restoreGeometry(geometry)
        except BaseException as exc:
            print(f"Qt GUI: Could not restore geometry: {str(exc)}", file=sys.stderr)
        self.flowgraph_started = threading.Event()

        ##################################################
        # Variables
        ##################################################
        self.phi_step = phi_step = 1
        self.phi_scan_min = phi_scan_min = -50
        self.phi_scan_max = phi_scan_max = 50
        self.spectrum_len = spectrum_len = 1+(phi_scan_max-phi_scan_min)//phi_step
        self.samp_rate = samp_rate = 32000

        ##################################################
        # Blocks
        ##################################################

        self.qtgui_vector_sink_f_0 = qtgui.vector_sink_f(
            spectrum_len,
            phi_scan_min,
            phi_step,
            "Steering angle",
            "Power",
            "",
            1, # Number of inputs
            None # parent
        )
        self.qtgui_vector_sink_f_0.set_update_time(0.10)
        self.qtgui_vector_sink_f_0.set_y_axis(0, 10)
        self.qtgui_vector_sink_f_0.enable_autoscale(True)
        self.qtgui_vector_sink_f_0.enable_grid(False)
        self.qtgui_vector_sink_f_0.set_x_axis_units("degrees")
        self.qtgui_vector_sink_f_0.set_y_axis_units("")
        self.qtgui_vector_sink_f_0.set_ref_level(0)


        labels = ['', '', '', '', '',
            '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
            "magenta", "yellow", "dark red", "dark green", "dark blue"]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]

        for i in range(1):
            if len(labels[i]) == 0:
                self.qtgui_vector_sink_f_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_vector_sink_f_0.set_line_label(i, labels[i])
            self.qtgui_vector_sink_f_0.set_line_width(i, widths[i])
            self.qtgui_vector_sink_f_0.set_line_color(i, colors[i])
            self.qtgui_vector_sink_f_0.set_line_alpha(i, alphas[i])

        self._qtgui_vector_sink_f_0_win = sip.wrapinstance(self.qtgui_vector_sink_f_0.qwidget(), Qt.QWidget)
        self.top_layout.addWidget(self._qtgui_vector_sink_f_0_win)
        self.epy_block_0 = epy_block_0.blk(num_samples=3, signal_freq=2.44e9, array_d=0.5, phi_scan_min=phi_scan_min, phi_scan_max=phi_scan_max, phi_step=phi_step, rx1_phase_cal=0, rx2_phase_cal=0, rx3_phase_cal=0, rx4_phase_cal=0)
        self.blocks_throttle2_0 = blocks.throttle( gr.sizeof_gr_complex*1, samp_rate, True, 0 if "auto" == "auto" else max( int(float(0.1) * samp_rate) if "auto" == "time" else int(0.1), 1) )
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_gr_complex*1, '/home/markus/uni/esd5_project/dsp/simulation_data/ula_4ch_sim_data_1_target.raw', True, 0, 0)
        self.blocks_file_source_0.set_begin_tag(pmt.PMT_NIL)
        self.blocks_deinterleave_0 = blocks.deinterleave(gr.sizeof_gr_complex*1, 1)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_deinterleave_0, 2), (self.epy_block_0, 2))
        self.connect((self.blocks_deinterleave_0, 3), (self.epy_block_0, 3))
        self.connect((self.blocks_deinterleave_0, 1), (self.epy_block_0, 1))
        self.connect((self.blocks_deinterleave_0, 0), (self.epy_block_0, 0))
        self.connect((self.blocks_file_source_0, 0), (self.blocks_throttle2_0, 0))
        self.connect((self.blocks_throttle2_0, 0), (self.blocks_deinterleave_0, 0))
        self.connect((self.epy_block_0, 0), (self.qtgui_vector_sink_f_0, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("gnuradio/flowgraphs", "reference_implementation_ula_beamscan_2ch")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_phi_step(self):
        return self.phi_step

    def set_phi_step(self, phi_step):
        self.phi_step = phi_step
        self.set_spectrum_len(1+(self.phi_scan_max-self.phi_scan_min)//self.phi_step)
        self.qtgui_vector_sink_f_0.set_x_axis(self.phi_scan_min, self.phi_step)

    def get_phi_scan_min(self):
        return self.phi_scan_min

    def set_phi_scan_min(self, phi_scan_min):
        self.phi_scan_min = phi_scan_min
        self.set_spectrum_len(1+(self.phi_scan_max-self.phi_scan_min)//self.phi_step)
        self.qtgui_vector_sink_f_0.set_x_axis(self.phi_scan_min, self.phi_step)

    def get_phi_scan_max(self):
        return self.phi_scan_max

    def set_phi_scan_max(self, phi_scan_max):
        self.phi_scan_max = phi_scan_max
        self.set_spectrum_len(1+(self.phi_scan_max-self.phi_scan_min)//self.phi_step)

    def get_spectrum_len(self):
        return self.spectrum_len

    def set_spectrum_len(self, spectrum_len):
        self.spectrum_len = spectrum_len

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.blocks_throttle2_0.set_sample_rate(self.samp_rate)




def main(top_block_cls=reference_implementation_ula_beamscan_2ch, options=None):

    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()

    tb.start()
    tb.flowgraph_started.set()

    tb.show()

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        Qt.QApplication.quit()

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    timer = Qt.QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    qapp.exec_()

if __name__ == '__main__':
    main()