#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright 2024 Markus Heinrich Toribio.
#
# SPDX-License-Identifier: GPL-3.0-or-later
#


import numpy
from gnuradio import gr
import socket
import struct
import pmt

class raw_ethernet_sink(gr.sync_block):
    """
    A sink which will output data to raw ethernet
    """
    def __init__(self, interface, dest_mac, samples_per_frame):
        gr.sync_block.__init__(self,
            name="raw_ethernet_sink",
            in_sig=[numpy.uint16],
            out_sig=None)
        self.interface = interface
        self.dest_mac = bytes.fromhex(" ".join(dest_mac.split(":")))
        self.socket = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.IPPROTO_RAW)
        self.socket.bind((self.interface, 0))
        self.src_mac = self.get_mac_address(self.interface)

        MAX_ETHERNET_PAYLOAD_SIZE = 1500 - 14  # MTU - Ethernet header size
        MAX_SAMPLES_PER_FRAME = MAX_ETHERNET_PAYLOAD_SIZE // 2  # uint16 samples
        self.samples_per_frame = min(samples_per_frame, MAX_SAMPLES_PER_FRAME)

    def get_mac_address(self, iface):
        import fcntl
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        info = fcntl.ioctl(
            s.fileno(),
            0x8927,  # SIOCGIFHWADDR
            struct.pack('256s', bytes(iface[:15], 'utf-8'))
        )
        return info[18:24]

    def work(self, input_items, output_items):
        in0 = input_items[0]
        ninput = len(in0)

        payload = in0[:self.samples_per_frame].tobytes()

        # Define Ethernet frame components
        dest_mac = self.dest_mac  # Broadcast or target MAC
        src_mac = self.src_mac
        ethertype = struct.pack('!H', 0x88B5)  # Custom EtherType

        # Construct Ethernet frame
        ethernet_frame = dest_mac + src_mac + ethertype + payload
        self.socket.send(ethernet_frame)

        return self.samples_per_frame # tell the scheduler how much data we processed
