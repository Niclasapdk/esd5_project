from typing import Callable
import itertools
import logging
import os
import random
import math
import ctypes
import struct

import cocotb_test.simulator
import pytest

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
from cocotb.binary import BinaryRepresentation, BinaryValue

from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSource, AxiStreamSink

tests_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', 'rtl'))
lib_axis_rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', 'lib', 'eth', 'lib', 'axis', 'rtl'))
sim_data_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', '..', 'simulation_data'))

# cocotb

class TB(object):
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

        self.source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst)
        #self.sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst)

    def set_idle_generator(self, generator=None):
        if generator:
            self.source.set_pause_generator(generator())

    async def reset(self):
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)

async def run_test(dut, payload_data: Callable, idle_inserter: Callable):
    tb = TB(dut)
    await tb.reset()
    tb.set_idle_generator(idle_inserter)

    # initialize to get past initial sample delay
    payload = payload_data(10)
    test_frame = AxiStreamFrame(payload)
    await tb.source.send(test_frame)

    for i in range(1000):
        await RisingEdge(dut.clk)
    assert False, "haven't implemented testbench yet"

def cycle_pause():
    return itertools.cycle([1, 1, 1, 0])

def signal_payload(num_samples):
    # bytes = samples * antennas * complex and real * float32
    num_bytes = num_samples * 4 * 2 * 4
    with open(os.path.join(sim_data_dir, 'ula_4ch_sim_data_1_target.raw'), "rb") as f:
        raw = f.read()
    conv = lambda x: int(struct.unpack("f", x)[0]*0x7ff)
    twos_complement = lambda x: ctypes.c_ushort(x).value
    to_bytes = lambda x: x.to_bytes(length=2, byteorder="little")
    imm = bytearray()
    for i in range(0, num_bytes, 4):
        imm.extend(to_bytes(twos_complement(conv(raw[i:i+4]))))
    return imm

if cocotb.SIM_NAME:
    factory = TestFactory(run_test)
    factory.add_option("payload_data", [signal_payload])
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.generate_tests()

# cocotb-test

def test_cbf_spectrum_estimator(request):
    dut = "cbf_spectrum_estimator"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "cbf_power_estimator.v"),
        os.path.join(rtl_dir, "sq_abs_cmul_4ch.v"),
        os.path.join(rtl_dir, "moving_average.v"),
        os.path.join(lib_axis_rtl_dir, "axis_fifo_adapter.v"),
        os.path.join(lib_axis_rtl_dir, "axis_fifo.v"),
        os.path.join(lib_axis_rtl_dir, "axis_adapter.v"),
    ]

    parameters = {}
    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}
    #extra_env['COCOTB_RESOLVE_X'] = 'RANDOM'

    sim_build = os.path.join(tests_dir, "sim_build",
        request.node.name.replace('[', '-').replace(']', ''))

    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
    )
