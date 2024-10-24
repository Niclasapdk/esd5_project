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


    index = 0
    clk = 1
    dut.en.value = 1

    while index < len(input_array):
        if clk == 1:
            dut.ma_input.value = input_array[index]
            index += 1
            await Timer(1)
            clk = 0
            dut.clk.value = 0
            await Timer(1)
            clk = 1
            dut.clk.value = 1
            


    await Timer(2)
    #assert False, "snorre was here"
   