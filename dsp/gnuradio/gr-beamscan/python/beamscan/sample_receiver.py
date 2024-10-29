#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright 2024 Markus Heinrich Toribio.
#
# SPDX-License-Identifier: GPL-3.0-or-later
#


import numpy
from gnuradio import gr
from gnuradio import uhd

class sample_receiver(gr.sync_block):
    """
    docstring for block sample_receiver
    """
    def __init__(self, num_samps=50, signal_freq=2.44e9, samp_rate=100e6, n210_1_addr="192.168.10.2", n210_2_addr="192.168.10.3", x300_addr="192.168.40.1"):
        gr.sync_block.__init__(self,
            name="sample_receiver",
            in_sig=None,
            out_sig=[numpy.complex64, numpy.complex64, numpy.complex64, numpy.complex64])
        self.num_samps = num_samps
        self.signal_freq = signal_freq
        self.samp_rate = samp_rate
        self.n210_1_addr = n210_1_addr
        self.n210_2_addr = n210_2_addr
        self.x300_addr = x300_addr
        sdr_args = f"addr0={n210_1_addr},addr1={n210_2_addr},addr2={x300_addr}"
        self.n210_1 = uhd.usrp.MultiUSRP(sdr_args)

    def work(self, input_items, output_items):
        out = output_items[0]
        # <+signal processing here+>
        out[:] = 1
        return len(output_items[0])


