import itertools
import logging
import os
import random

import cocotb_test.simulator
import pytest

import cocotb
from cocotb.triggers import Timer
from cocotb.regression import TestFactory
from cocotb.binary import BinaryValue, BinaryRepresentation

#########
# Model #
#########

def mul_I(in_I_x1: int, in_Q_x1: int, in_I_x2: int, in_Q_x2: int) -> int:
    I = in_I_x1 * in_I_x2 - in_Q_x1 * in_Q_x2
    return I

def mul_Q(in_I_x1: int, in_Q_x1: int, in_I_x2: int, in_Q_x2: int) -> int:
    Q = in_I_x1 * in_Q_x2 + in_I_x2 * in_Q_x1 
    return Q

def mul_model(Ix, Qx, Is, Qs):
    """model of multiplication"""
    I = 0
    Q = 0
    assert len(Ix) == len(Qx) == len(Is) == len(Qs), "vecs should be equal length"
    for Ix, Qx, Is, Qs in zip(Ix, Qx, Is, Qs):
        I += mul_I(Ix, Qx, Is, Qs)
        Q += mul_Q(Ix, Qx, Is, Qs)
    return I, Q

def abscmul_model(Ix, Qx, Is, Qs):
    """model of abscmul. input parameters are lists"""
    I = 0
    Q = 0
    abs_sqIQ = 0
    assert len(Ix) == len(Qx) == len(Is) == len(Qs), "vecs should be equal length"
    for Ix, Qx, Is, Qs in zip(Ix, Qx, Is, Qs):
        I += mul_I(Ix, Qx, Is, Qs)
        Q += mul_Q(Ix, Qx, Is, Qs)
    abs_sqIQ = (I*I)+(Q*Q)
    return abs_sqIQ

def unsigned_bits_to_signed(x, bitlen):
    if x == 0:
        # weird edge case happens because:
        # BinaryValue(value=0, n_bits=8).signed_integer fails
        return 0
    val = BinaryValue(value=x, n_bits=bitlen, binaryRepresentation=BinaryRepresentation.TWOS_COMPLEMENT)
    return val.signed_integer

##########
# cocotb #
##########

class TB(object):
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

    def set_inputs(self, Ix, Qx, Is, Qs):
        """helper function for setting DUT inputs"""
        self.dut.I_x1.value = Ix[0]
        self.dut.I_x2.value = Ix[1]
        self.dut.I_x3.value = Ix[2]
        self.dut.I_x4.value = Ix[3]
        self.dut.Q_x1.value = Qx[0]
        self.dut.Q_x2.value = Qx[1]
        self.dut.Q_x3.value = Qx[2]
        self.dut.Q_x4.value = Qx[3]
        self.dut.I_s1.value = Is[0]
        self.dut.I_s2.value = Is[1]
        self.dut.I_s3.value = Is[2]
        self.dut.I_s4.value = Is[3]
        self.dut.Q_s1.value = Qs[0]
        self.dut.Q_s2.value = Qs[1]
        self.dut.Q_s3.value = Qs[2]
        self.dut.Q_s4.value = Qs[3]

async def run_basic_test(dut, payload_data):
    """test for multiplication using the complex_sample_mul task"""

    tb = TB(dut)
    input_bit_length = dut.WORD_LENGTH.value
    test_inputs = [payload_data(input_bit_length, 4) for _ in range(100)]
    for Ix, Qx, Is, Qs in test_inputs:
        tb.set_inputs(Ix, Qx, Is, Qs)
        await Timer(1)
        I_e, Q_e = mul_model(Ix, Qx, Is, Qs)
        abs_sqIQ_e = abscmul_model(Ix, Qx, Is, Qs)
        try:
            assert I_e == dut.I_tot.value.signed_integer, "Expected I value"
            assert Q_e == dut.Q_tot.value.signed_integer, "Expected Q value"
            assert abs_sqIQ_e == dut.result_abs_sq_cmul.value.signed_integer, "Expected abs_sqIQ"
        except:
            tb.log.error(f"{Ix=}, {Qx=}, {Is=}, {Qs=}")
            assert I_e == dut.I_tot.value.signed_integer, "Expected I value"
            assert Q_e == dut.Q_tot.value.signed_integer, "Expected Q value"
            assert abs_sqIQ_e == dut.result_abs_sq_cmul.value.signed_integer, "Expected abs_sqIQ"

def payload_data(bitlength, vector_len):
    """
    generator function for 2*vector_len words + 2*vector_len words
    (meant for generating vector_len samples and vector_len steering vectors)
    """
    Ix = [unsigned_bits_to_signed(random.getrandbits(bitlength), bitlength) for _ in range(vector_len)]
    Qx = [unsigned_bits_to_signed(random.getrandbits(bitlength), bitlength) for _ in range(vector_len)]
    Is = [unsigned_bits_to_signed(random.getrandbits(bitlength), bitlength) for _ in range(vector_len)]
    Qs = [unsigned_bits_to_signed(random.getrandbits(bitlength), bitlength) for _ in range(vector_len)]
    return Ix, Qx, Is, Qs

if cocotb.SIM_NAME:
    factory = TestFactory(run_basic_test)
    factory.add_option("payload_data", [payload_data])
    factory.generate_tests()
   
###############
# cocotb-test #
###############

tests_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', 'rtl'))

@pytest.mark.parametrize("word_length", [8, 12, 16])
def test_sq_abs_cmul_4ch(request, word_length):
    dut = "sq_abs_cmul_4ch"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}
    parameters['WORD_LENGTH'] = word_length
    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

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
