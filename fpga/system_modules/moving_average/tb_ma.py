import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
import os
import math as m
import random
###########################################
###############for debugging###############
###########################################
def logprint(msg):
    print(f"FROM_TB {msg}")

###########################################
###############for test of result##########
###########################################

###########################################
###############test and input values#######
###########################################


@cocotb.test()
async def top_test(dut):
    """test for multiplication using the complex_sample_mul task"""
    input_array = []

    for i in range(1, 51):
        #input_array.append(random.uniform(1, 10))
        input_array.append(random.randint(1,10))
    
    dut.en.value = 0
    await Timer(1)
    dut.clk.value = 0
    await Timer(1)
    dut.clk.value = 1
    dut.en.value = 1

    expected_sum = 0
    model_shiftreg = []

    for xi in input_array:
        dut.ma_input.value = xi
        model_shiftreg.append(xi)
        last = model_shiftreg.pop(0) if len(model_shiftreg) > dut.MA_SNAPSHOT_COUNT.value else 0
        expected_sum += xi - last
        expected_out = expected_sum/dut.MA_SNAPSHOT_COUNT.value
        await Timer(1)
        dut.clk.value = 0
        await Timer(1)
        dut.clk.value = 1
        print(f"Input: ma_input={xi}, Expected: ma_sum={expected_sum}, ma_out={expected_out}, Got: ma_sum={dut.ma_sum.value}, ma_out={dut.ma_out.value}")
        assert expected_sum == dut.ma_sum.value
        assert expected_out == dut.ma_out.value 

    await Timer(2)
    #assert False, "snorre was here"
   