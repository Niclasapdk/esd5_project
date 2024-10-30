#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: UHD Message Tuner
# Description: Tune a UHD source from a QT sink via messages (double-click a frequency to tune)
# GNU Radio version: 3.10.11.0

from PyQt5 import Qt
from gnuradio import qtgui
from PyQt5.QtCore import QObject, pyqtSlot
from gnuradio import blocks
import pmt
from gnuradio import eng_notation
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import sys
import signal
from PyQt5 import Qt
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import uhd
import time
import sip
import threading



class uhd_tune_msg(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "UHD Message Tuner", catch_exceptions=True)
        Qt.QWidget.__init__(self)
        self.setWindowTitle("UHD Message Tuner")
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

        self.settings = Qt.QSettings("gnuradio/flowgraphs", "uhd_tune_msg")

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
        self.initial_fc = initial_fc = 2.44e9
        self.gain = gain = 0.8
        self.lo_msg = lo_msg = 0
        self.gain_msg = gain_msg = gain
        self.freq_msg = freq_msg = initial_fc
        self.ant_msg = ant_msg = 'TX/RX'
        self.samp_rate = samp_rate = 25e6
        self.cmd_msg = cmd_msg = pmt.to_pmt({'antenna': ant_msg, 'gain': gain_msg, 'chan': 0, 'freq': freq_msg, 'lo_offset': lo_msg})
        self.bandwidth = bandwidth = 500e3

        ##################################################
        # Blocks
        ##################################################

        self.uhd_usrp_source_0 = uhd.usrp_source(
            ",".join(("addr1=192.168.10.2,addr0=192.168.10.3", "", "master_clock_rate=200e6")),
            uhd.stream_args(
                cpu_format="fc32",
                args='',
                channels=list(range(0,2)),
            ),
        )
        self.uhd_usrp_source_0.set_samp_rate(samp_rate)
        self.uhd_usrp_source_0.set_time_now(uhd.time_spec(time.time()), uhd.ALL_MBOARDS)

        self.uhd_usrp_source_0.set_center_freq(initial_fc, 0)
        self.uhd_usrp_source_0.set_antenna("TX/RX", 0)
        self.uhd_usrp_source_0.set_gain(gain, 0)

        self.uhd_usrp_source_0.set_center_freq(initial_fc, 1)
        self.uhd_usrp_source_0.set_antenna("TX/RX", 1)
        self.uhd_usrp_source_0.set_gain(gain, 1)
        self.qtgui_sink_x_0_0 = qtgui.sink_c(
            1024, #fftsize
            window.WIN_BLACKMAN_hARRIS, #wintype
            0, #fc
            bandwidth, #bw
            "", #name
            True, #plotfreq
            True, #plotwaterfall
            True, #plottime
            True, #plotconst
            None # parent
        )
        self.qtgui_sink_x_0_0.set_update_time(1.0/10)
        self._qtgui_sink_x_0_0_win = sip.wrapinstance(self.qtgui_sink_x_0_0.qwidget(), Qt.QWidget)

        self.qtgui_sink_x_0_0.enable_rf_freq(True)

        self.top_layout.addWidget(self._qtgui_sink_x_0_0_win)
        self.qtgui_sink_x_0 = qtgui.sink_c(
            1024, #fftsize
            window.WIN_BLACKMAN_hARRIS, #wintype
            0, #fc
            bandwidth, #bw
            "", #name
            True, #plotfreq
            True, #plotwaterfall
            True, #plottime
            True, #plotconst
            None # parent
        )
        self.qtgui_sink_x_0.set_update_time(1.0/10)
        self._qtgui_sink_x_0_win = sip.wrapinstance(self.qtgui_sink_x_0.qwidget(), Qt.QWidget)

        self.qtgui_sink_x_0.enable_rf_freq(True)

        self.top_layout.addWidget(self._qtgui_sink_x_0_win)
        self._lo_msg_tool_bar = Qt.QToolBar(self)
        self._lo_msg_tool_bar.addWidget(Qt.QLabel("LO Offset" + ": "))
        self._lo_msg_line_edit = Qt.QLineEdit(str(self.lo_msg))
        self._lo_msg_tool_bar.addWidget(self._lo_msg_line_edit)
        self._lo_msg_line_edit.editingFinished.connect(
            lambda: self.set_lo_msg(eng_notation.str_to_num(str(self._lo_msg_line_edit.text()))))
        self.top_grid_layout.addWidget(self._lo_msg_tool_bar, 1, 1, 1, 1)
        for r in range(1, 2):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(1, 2):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._gain_msg_tool_bar = Qt.QToolBar(self)
        self._gain_msg_tool_bar.addWidget(Qt.QLabel("Gain" + ": "))
        self._gain_msg_line_edit = Qt.QLineEdit(str(self.gain_msg))
        self._gain_msg_tool_bar.addWidget(self._gain_msg_line_edit)
        self._gain_msg_line_edit.editingFinished.connect(
            lambda: self.set_gain_msg(eng_notation.str_to_num(str(self._gain_msg_line_edit.text()))))
        self.top_grid_layout.addWidget(self._gain_msg_tool_bar, 0, 0, 1, 1)
        for r in range(0, 1):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._freq_msg_tool_bar = Qt.QToolBar(self)
        self._freq_msg_tool_bar.addWidget(Qt.QLabel("Frequency" + ": "))
        self._freq_msg_line_edit = Qt.QLineEdit(str(self.freq_msg))
        self._freq_msg_tool_bar.addWidget(self._freq_msg_line_edit)
        self._freq_msg_line_edit.editingFinished.connect(
            lambda: self.set_freq_msg(eng_notation.str_to_num(str(self._freq_msg_line_edit.text()))))
        self.top_grid_layout.addWidget(self._freq_msg_tool_bar, 0, 1, 1, 1)
        for r in range(0, 1):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(1, 2):
            self.top_grid_layout.setColumnStretch(c, 1)
        self.blocks_message_strobe_0 = blocks.message_strobe(cmd_msg, 2000)
        # Create the options list
        self._ant_msg_options = ['TX/RX', 'RX2']
        # Create the labels list
        self._ant_msg_labels = ['TX/RX', 'RX2']
        # Create the combo box
        self._ant_msg_tool_bar = Qt.QToolBar(self)
        self._ant_msg_tool_bar.addWidget(Qt.QLabel("Antenna" + ": "))
        self._ant_msg_combo_box = Qt.QComboBox()
        self._ant_msg_tool_bar.addWidget(self._ant_msg_combo_box)
        for _label in self._ant_msg_labels: self._ant_msg_combo_box.addItem(_label)
        self._ant_msg_callback = lambda i: Qt.QMetaObject.invokeMethod(self._ant_msg_combo_box, "setCurrentIndex", Qt.Q_ARG("int", self._ant_msg_options.index(i)))
        self._ant_msg_callback(self.ant_msg)
        self._ant_msg_combo_box.currentIndexChanged.connect(
            lambda i: self.set_ant_msg(self._ant_msg_options[i]))
        # Create the radio buttons
        self.top_layout.addWidget(self._ant_msg_tool_bar)


        ##################################################
        # Connections
        ##################################################
        self.msg_connect((self.blocks_message_strobe_0, 'strobe'), (self.qtgui_sink_x_0, 'freq'))
        self.msg_connect((self.blocks_message_strobe_0, 'strobe'), (self.qtgui_sink_x_0_0, 'freq'))
        self.msg_connect((self.blocks_message_strobe_0, 'strobe'), (self.uhd_usrp_source_0, 'command'))
        self.connect((self.uhd_usrp_source_0, 0), (self.qtgui_sink_x_0, 0))
        self.connect((self.uhd_usrp_source_0, 1), (self.qtgui_sink_x_0_0, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("gnuradio/flowgraphs", "uhd_tune_msg")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_initial_fc(self):
        return self.initial_fc

    def set_initial_fc(self, initial_fc):
        self.initial_fc = initial_fc
        self.set_freq_msg(self.initial_fc)
        self.uhd_usrp_source_0.set_center_freq(self.initial_fc, 0)
        self.uhd_usrp_source_0.set_center_freq(self.initial_fc, 1)

    def get_gain(self):
        return self.gain

    def set_gain(self, gain):
        self.gain = gain
        self.set_gain_msg(self.gain)
        self.uhd_usrp_source_0.set_gain(self.gain, 0)
        self.uhd_usrp_source_0.set_gain(self.gain, 1)

    def get_lo_msg(self):
        return self.lo_msg

    def set_lo_msg(self, lo_msg):
        self.lo_msg = lo_msg
        self.set_cmd_msg(pmt.to_pmt({'antenna': self.ant_msg, 'gain': self.gain_msg, 'chan': 0, 'freq': self.freq_msg, 'lo_offset': self.lo_msg}))
        Qt.QMetaObject.invokeMethod(self._lo_msg_line_edit, "setText", Qt.Q_ARG("QString", eng_notation.num_to_str(self.lo_msg)))

    def get_gain_msg(self):
        return self.gain_msg

    def set_gain_msg(self, gain_msg):
        self.gain_msg = gain_msg
        self.set_cmd_msg(pmt.to_pmt({'antenna': self.ant_msg, 'gain': self.gain_msg, 'chan': 0, 'freq': self.freq_msg, 'lo_offset': self.lo_msg}))
        Qt.QMetaObject.invokeMethod(self._gain_msg_line_edit, "setText", Qt.Q_ARG("QString", eng_notation.num_to_str(self.gain_msg)))

    def get_freq_msg(self):
        return self.freq_msg

    def set_freq_msg(self, freq_msg):
        self.freq_msg = freq_msg
        self.set_cmd_msg(pmt.to_pmt({'antenna': self.ant_msg, 'gain': self.gain_msg, 'chan': 0, 'freq': self.freq_msg, 'lo_offset': self.lo_msg}))
        Qt.QMetaObject.invokeMethod(self._freq_msg_line_edit, "setText", Qt.Q_ARG("QString", eng_notation.num_to_str(self.freq_msg)))

    def get_ant_msg(self):
        return self.ant_msg

    def set_ant_msg(self, ant_msg):
        self.ant_msg = ant_msg
        self._ant_msg_callback(self.ant_msg)
        self.set_cmd_msg(pmt.to_pmt({'antenna': self.ant_msg, 'gain': self.gain_msg, 'chan': 0, 'freq': self.freq_msg, 'lo_offset': self.lo_msg}))

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.uhd_usrp_source_0.set_samp_rate(self.samp_rate)

    def get_cmd_msg(self):
        return self.cmd_msg

    def set_cmd_msg(self, cmd_msg):
        self.cmd_msg = cmd_msg
        self.blocks_message_strobe_0.set_msg(self.cmd_msg)

    def get_bandwidth(self):
        return self.bandwidth

    def set_bandwidth(self, bandwidth):
        self.bandwidth = bandwidth
        self.qtgui_sink_x_0.set_frequency_range(0, self.bandwidth)
        self.qtgui_sink_x_0_0.set_frequency_range(0, self.bandwidth)




def main(top_block_cls=uhd_tune_msg, options=None):

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
