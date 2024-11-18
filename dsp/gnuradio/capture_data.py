#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Capture data
# Author: markus
# GNU Radio version: 3.10.11.0

from gnuradio import blocks
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import uhd
import time
import threading




class capture_data(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Capture data", catch_exceptions=True)
        self.flowgraph_started = threading.Event()

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 5e6
        self.gain = gain = 80
        self.center_freq = center_freq = 2.44e9
        self.N = N = 8192

        ##################################################
        # Blocks
        ##################################################

        self.uhd_usrp_source_0_0 = uhd.usrp_source(
            ",".join(("addr0=192.168.10.3,addr1=192.168.10.4", "", "master_clock_rate=200e6")),
            uhd.stream_args(
                cpu_format="fc32",
                args='',
                channels=list(range(0,2)),
            ),
        )
        self.uhd_usrp_source_0_0.set_clock_source('external', 0)
        self.uhd_usrp_source_0_0.set_time_source('external', 0)
        self.uhd_usrp_source_0_0.set_clock_source('external', 1)
        self.uhd_usrp_source_0_0.set_time_source('external', 1)
        self.uhd_usrp_source_0_0.set_samp_rate(samp_rate)
        _last_pps_time = self.uhd_usrp_source_0_0.get_time_last_pps().get_real_secs()
        # Poll get_time_last_pps() every 50 ms until a change is seen
        while(self.uhd_usrp_source_0_0.get_time_last_pps().get_real_secs() == _last_pps_time):
            time.sleep(0.05)
        # Set the time to PC time on next PPS
        self.uhd_usrp_source_0_0.set_time_next_pps(uhd.time_spec(int(time.time()) + 1.0))
        # Sleep 1 second to ensure next PPS has come
        time.sleep(1)

        self.uhd_usrp_source_0_0.set_center_freq(center_freq, 0)
        self.uhd_usrp_source_0_0.set_antenna("TX/RX", 0)
        self.uhd_usrp_source_0_0.set_gain(gain, 0)

        self.uhd_usrp_source_0_0.set_center_freq(center_freq, 1)
        self.uhd_usrp_source_0_0.set_antenna("TX/RX", 1)
        self.uhd_usrp_source_0_0.set_gain(gain, 1)
        self.uhd_usrp_source_0 = uhd.usrp_source(
            ",".join(("addr0=192.168.10.2", "", "master_clock_rate=200e6")),
            uhd.stream_args(
                cpu_format="fc32",
                args='',
                channels=list(range(0,2)),
            ),
        )
        self.uhd_usrp_source_0.set_clock_source('internal', 0)
        self.uhd_usrp_source_0.set_samp_rate(samp_rate)
        _last_pps_time = self.uhd_usrp_source_0.get_time_last_pps().get_real_secs()
        # Poll get_time_last_pps() every 50 ms until a change is seen
        while(self.uhd_usrp_source_0.get_time_last_pps().get_real_secs() == _last_pps_time):
            time.sleep(0.05)
        # Set the time to PC time on next PPS
        self.uhd_usrp_source_0.set_time_next_pps(uhd.time_spec(int(time.time()) + 1.0))
        # Sleep 1 second to ensure next PPS has come
        time.sleep(1)

        self.uhd_usrp_source_0.set_center_freq(center_freq, 0)
        self.uhd_usrp_source_0.set_antenna("TX/RX", 0)
        self.uhd_usrp_source_0.set_gain(gain, 0)

        self.uhd_usrp_source_0.set_center_freq(center_freq, 1)
        self.uhd_usrp_source_0.set_antenna("TX/RX", 1)
        self.uhd_usrp_source_0.set_gain(gain, 1)
        self.blocks_interleave_0 = blocks.interleave(gr.sizeof_gr_complex*1, 1)
        self.blocks_head_0 = blocks.head(gr.sizeof_gr_complex*1, N)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_gr_complex*1, '/home/markus/uni/esd5_project/dsp/measured_data/good_shit_30_degrees_3', False)
        self.blocks_file_sink_0.set_unbuffered(False)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_head_0, 0), (self.blocks_file_sink_0, 0))
        self.connect((self.blocks_interleave_0, 0), (self.blocks_head_0, 0))
        self.connect((self.uhd_usrp_source_0, 0), (self.blocks_interleave_0, 0))
        self.connect((self.uhd_usrp_source_0, 1), (self.blocks_interleave_0, 1))
        self.connect((self.uhd_usrp_source_0_0, 0), (self.blocks_interleave_0, 2))
        self.connect((self.uhd_usrp_source_0_0, 1), (self.blocks_interleave_0, 3))


    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.uhd_usrp_source_0.set_samp_rate(self.samp_rate)
        self.uhd_usrp_source_0_0.set_samp_rate(self.samp_rate)

    def get_gain(self):
        return self.gain

    def set_gain(self, gain):
        self.gain = gain
        self.uhd_usrp_source_0.set_gain(self.gain, 0)
        self.uhd_usrp_source_0.set_gain(self.gain, 1)
        self.uhd_usrp_source_0.set_gain(self.gain, 2)
        self.uhd_usrp_source_0.set_gain(self.gain, 3)
        self.uhd_usrp_source_0_0.set_gain(self.gain, 0)
        self.uhd_usrp_source_0_0.set_gain(self.gain, 1)
        self.uhd_usrp_source_0_0.set_gain(self.gain, 2)
        self.uhd_usrp_source_0_0.set_gain(self.gain, 3)

    def get_center_freq(self):
        return self.center_freq

    def set_center_freq(self, center_freq):
        self.center_freq = center_freq
        self.uhd_usrp_source_0.set_center_freq(self.center_freq, 0)
        self.uhd_usrp_source_0.set_center_freq(self.center_freq, 1)
        self.uhd_usrp_source_0.set_center_freq(self.center_freq, 2)
        self.uhd_usrp_source_0.set_center_freq(self.center_freq, 3)
        self.uhd_usrp_source_0_0.set_center_freq(self.center_freq, 0)
        self.uhd_usrp_source_0_0.set_center_freq(self.center_freq, 1)
        self.uhd_usrp_source_0_0.set_center_freq(self.center_freq, 2)
        self.uhd_usrp_source_0_0.set_center_freq(self.center_freq, 3)

    def get_N(self):
        return self.N

    def set_N(self, N):
        self.N = N
        self.blocks_head_0.set_length(self.N)




def main(top_block_cls=capture_data, options=None):
    tb = top_block_cls()

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        sys.exit(0)

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    tb.start()
    tb.flowgraph_started.set()

    tb.wait()


if __name__ == '__main__':
    main()
