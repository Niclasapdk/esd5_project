import os
import logging
import itertools
import cocotb_test.simulator
import pytest
import math

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSource, AxiStreamSink

##################
##### cocotb #####
##################

class TB(object):
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

        self.sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst)

    def set_backpressure_generator(self, generator=None):
        if generator:
            self.sink.set_pause_generator(generator())

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

async def run_test(dut, payload_lengths=None, payload_data=None, idle_inserter=None, backpressure_inserter=None):
    tb = TB(dut)

    await tb.reset()

    tb.set_backpressure_generator(backpressure_inserter)

    test_frames = []

    tb.log.debug("sending IQ-samples")
    sample_width = dut.SAMPLE_WIDTH.value
    bits_in_rx_axis = (sample_width*2)
    assert bits_in_rx_axis%8 == 0, "expect even byte number on output"
    bytes_in_rx_axis = bits_in_rx_axis//8
    tb.log.debug(f"sample_width: {sample_width}")
    tb.log.debug(f"bytes_in_rx_axis: {bytes_in_rx_axis}")
    sample_width_bytes = math.ceil(sample_width/8)
    for I_slice, Q_slice in [payload_data(sample_width, x) for x in payload_lengths()]:
        I_samples = [I_slice[i:i+sample_width_bytes] for i in range(0, len(I_slice), sample_width_bytes)]
        Q_samples = [Q_slice[i:i+sample_width_bytes] for i in range(0, len(Q_slice), sample_width_bytes)]
        # Iterate over the zipped I and Q samples
        for I_sample, Q_sample in zip(I_samples, Q_samples):
            I = I_sample[0:sample_width]
            Q = Q_sample[0:sample_width]
            test_frame = (I, Q)
            test_frames.append(test_frame)
            dut.I_in.value = int.from_bytes(I)
            dut.Q_in.value = int.from_bytes(Q)
            dut.input_valid.value = 1
            await RisingEdge(dut.clk)
            dut.input_valid.value = 0
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)

    tb.log.debug("receiving from AXI stream")
    tb.log.debug(test_frames)
    i = 0
    while not tb.sink.empty():
        i += 1
        a = await tb.sink.recv()
        tb.log.debug(a.tdata)
    tb.log.debug(f"num sent {len(test_frames)}")
    tb.log.debug(f"num recv {i}")
    assert False
    for test_frame in test_frames:
        rx_frames = []
        for i in range(bytes_in_rx_axis):
            rx_frame = await tb.sink.recv()
            rx_frames.append(rx_frame.tdata)
            assert not rx_frame.tuser
        tb.log.debug(rx_frames)

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

def cycle_pause():
    return itertools.cycle([1, 1, 1, 0])

def size_list():
    data_width = max(len(cocotb.top.m_axis_tdata), cocotb.top.S_DATA_WIDTH.value)
    byte_width = data_width // 8
    return list(range(1, byte_width*4+1))+[512]+[1]*64
    # return [1, 4]

# Function to generate incrementing payloads for a specific word length and buffer length
def incrementing_payload(word_length_bits, buffer_length):
    word_length_bytes = math.ceil(word_length_bits / 8)
    # Create I and Q byte arrays with the specific word length and buffer length
    I = bytearray(itertools.islice(itertools.cycle(range(0x100)), word_length_bytes * buffer_length))
    Q = bytearray(itertools.islice(itertools.cycle(range(0x100)), word_length_bytes * buffer_length))
    return I, Q

if cocotb.SIM_NAME:
    factory = TestFactory(run_test)
    factory.add_option("payload_lengths", [size_list])
    factory.add_option("payload_data", [incrementing_payload])
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.add_option("backpressure_inserter", [None, cycle_pause])
    factory.generate_tests()

#######################
##### cocotb-test #####
#######################

tests_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(tests_dir, "..", "rtl"))
lib_eth_dir = os.path.abspath(os.path.join(tests_dir, "..", "..", "verilog-ethernet"))
lib_eth_axis_rtl_dir = os.path.abspath(os.path.join(lib_eth_dir, "lib", "axis", "rtl"))

@pytest.mark.skipif(os.getenv("SIM") in ("ghdl", "nvc"), reason="Verilog not suported")
@pytest.mark.parametrize("sample_width", [8, 12, 16])
def test_sample_to_axis_adapter(sample_width):
    dut = "sample_to_axis_adapter"
    sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(lib_eth_axis_rtl_dir, "axis_adapter.v"),
        os.path.join(lib_eth_axis_rtl_dir, "axis_fifo.v"),
        os.path.join(lib_eth_axis_rtl_dir, "axis_fifo_adapter.v")
        ]
    top = dut
    module = os.path.splitext(os.path.basename(__file__))[0]
    params = {}
    params["SAMPLE_WIDTH"] = sample_width
    params["AXI_DATA_WIDTH"] = 8
    extra_env = {f'PARAM_{k}': str(v) for k, v in params.items()}
    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=sources,
        toplevel=top,
        module=module,
        parameters=params,
        extra_env=extra_env
    )
