#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright 2024 Markus Heinrich Toribio.
#
# SPDX-License-Identifier: GPL-3.0-or-later
#


import numpy
from gnuradio import gr

class beamscan_spectrum_estimator(gr.basic_block):
    """
    Spatial spectrum estimator for ULA with 4 elements.
    """
    def __init__(self, num_samples=51, signal_freq=1, rx1_phase_cal=1, rx2_phase_cal=1, rx3_phase_cal=1, rx4_phase_cal=1):
        gr.basic_block.__init__(self,
            name="Beamscan spatial spectrum estimator",
            in_sig=[numpy.complex64, numpy.complex64, numpy.complex64, numpy.complex64],
            out_sig=[numpy.float32,])

    def forecast(self, noutput_items, ninputs):
        # ninputs is the number of input connections
        # setup size of input_items[i] for work call
        # the required number of input items is returned
        #   in a list where each element represents the
        #   number of required items for each input
        ninput_items_required = [noutput_items] * ninputs
        return ninput_items_required

    def general_work(self, input_items, output_items):
        # For this sample code, the general block is made to behave like a sync block
        ninput_items = min([len(items) for items in input_items])
        noutput_items = min(len(output_items[0]), ninput_items)
        output_items[0][:noutput_items] = input_items[0][:noutput_items]
        self.consume_each(noutput_items)
        return noutput_items
