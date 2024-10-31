from typing import Callable
import itertools
import logging
import os
import random
import math

import cocotb_test.simulator
import pytest

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
from cocotb.binary import BinaryRepresentation, BinaryValue

from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSource, AxiStreamSink

# model

class MovingAverageModel():
    def __init__(self, snapshot_count, input_bit_length, internal_sum_bitlen, out_bitlen):
        self.sum = 0
        self.input_bit_length = input_bit_length
        self.input_byte_length = input_bit_length//8
        assert input_bit_length%8 == 0
        self.internal_sum_bitlen = internal_sum_bitlen
        self.out_bitlen = out_bitlen
        self.shiftreg = [0 for _ in range(snapshot_count)]
        self.snapshot_count = snapshot_count
        self.snapshot_exponent = int(math.log2(snapshot_count))

    def work(self, xi):
        self.shiftreg.append(xi)
        last = self.shiftreg.pop(0)
        #print(self.sum)
        self.sum += xi - last
        result = self.sum>>self.snapshot_exponent
        return result

    def work_samples(self, xs):
        res = "ERROR"
        for xi in [xs[i:i+self.input_byte_length] for i in range(0, len(xs), self.input_byte_length)]:
            xi = BinaryValue(bytes(xi)[::-1], n_bits=self.input_bit_length)
            res = self.work(xi)
        return res

# cocotb

class TB(object):
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

        self.source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst)
        self.sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst)

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

async def run_test(dut, payload_sizes: Callable, payload_data: Callable, idle_inserter: Callable):

    random.seed(0xdeadbeef)
    tb = TB(dut)

    await tb.reset()

    tb.set_idle_generator(idle_inserter)


    input_bit_length = dut.WORD_LENGTH_IN.value
    assert input_bit_length % 8 == 0
    snapshot_count = dut.SNAPSHOT_COUNT.value
    assert snapshot_count & (snapshot_count-1) == 0, "must be power of 2"

    model = MovingAverageModel(snapshot_count, input_bit_length, dut.WORD_LENGTH_RESULT.value, dut.WORD_LENGTH_OUT.value)

    # initialize to get past initial sample delay
    await tb.source.send(b"\x00")
    await tb.source.send(b"\x00")
    await tb.sink.recv()
    payload_list = [payload_data(l) for l in payload_sizes()]
    expected_delayed = 0
    for i, test_data in enumerate(payload_list):
        test_frame = AxiStreamFrame(test_data)
        await tb.source.send(test_frame)

        expected = model.work_samples(test_data)

        #print(test_data)
        print(i, len(payload_list)-1)
        rx_frame = await tb.sink.recv()
        if tb.sink.byte_lanes * 8 == tb.sink.width:
            print(rx_frame.tdata)
            output_data = int.from_bytes(rx_frame.tdata, "little")
        else:
            output_data = 0
            for i, v in enumerate(rx_frame.tdata):
                output_data |= v << (tb.sink.byte_size*i)
        assert output_data == expected_delayed
        expected_delayed = expected

    assert tb.sink.empty()

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

def cycle_pause():
    return itertools.cycle([1, 1, 1, 0])

def size_list():
    data_width = len(cocotb.top.s_axis_tdata)
    byte_width = data_width // 8
    return [byte_width]*1000

def random_payload(length):
    random_bytes_iterator = (random.getrandbits(8) for _ in itertools.count())
    return bytearray(itertools.islice(random_bytes_iterator, length))

if cocotb.SIM_NAME:
    factory = TestFactory(run_test)
    factory.add_option("payload_data", [random_payload])
    factory.add_option("payload_sizes", [size_list])
    factory.add_option("idle_inserter", [None, cycle_pause])
    factory.generate_tests()

# cocotb-test

tests_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', 'rtl'))

@pytest.mark.parametrize("word_length_in", [16, 32, 64, 80])
#@pytest.mark.parametrize("word_length_out", [8, 16, 32, 64])
@pytest.mark.parametrize("snapshot_count", [8, 16, 32, 64])
def test_moving_average(request, word_length_in, snapshot_count):

    dut = "moving_average"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}
    parameters['WORD_LENGTH_IN'] = word_length_in
    #parameters['WORD_LENGTH_OUT'] = word_length_out
    parameters['SNAPSHOT_COUNT'] = snapshot_count
    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}
    extra_env['COCOTB_RESOLVE_X'] = 'RANDOM'

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
