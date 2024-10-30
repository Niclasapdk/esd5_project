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
def mul_I(in_I_x1: int, in_Q_x1: int, in_I_x2: int, in_Q_x2: int) -> int:
    I = in_I_x1 * in_I_x2 - in_Q_x1 * in_Q_x2
    return I

def mul_Q(in_I_x1: int, in_Q_x1: int, in_I_x2: int, in_Q_x2: int) -> int:
    Q = in_I_x1 * in_Q_x2 + in_I_x2 * in_Q_x1 
    return Q


def abssq_mul_model(Ix1, Ix2, Ix3, Ix4, Qx1, Qx2, Qx3, Qx4, Is1, Is2, Is3, Is4, Qs1, Qs2, Qs3, Qs4):
    """model of multiplication"""
    I = 0
    Q = 0
    abssq_IQ = 0

    I = mul_I(Ix1, Qx1, Is1, Qs1) + mul_I(Ix2, Qx2, Is2, Qs2) + mul_I(Ix3, Qx3, Is3, Qs3) + mul_I(Ix4, Qx4, Is4, Qs4)
    Q = mul_Q(Ix1, Qx1, Is1, Qs1) + mul_Q(Ix2, Qx2, Is2, Qs2) + mul_Q(Ix3, Qx3, Is3, Qs3) + mul_Q(Ix4, Qx4, Is4, Qs4)
    abssq_IQ = (I*I)+(Q*Q)

    return abssq_IQ

@cocotb.test()
async def top_test(dut):
    """test for sys"""


    await Timer(2)

    ######################################################
    input_arrayIx1 = []
    input_arrayIx2 = []
    input_arrayIx3 = []
    input_arrayIx4 = []
    input_arrayQx1 = []
    input_arrayQx2 = []
    input_arrayQx3 = []
    input_arrayQx4 = []
    input_arrayIs1 = []
    input_arrayIs2 = []
    input_arrayIs3 = []
    input_arrayIs4 = []
    input_arrayQs1 = []
    input_arrayQs2 = []
    input_arrayQs3 = []
    input_arrayQs4 = []

    for i in range(1, 51):
        input_arrayIx1.append(random.randint(-10,10))
        input_arrayIx2.append(random.randint(-10,10))
        input_arrayIx3.append(random.randint(-10,10))
        input_arrayIx4.append(random.randint(-10,10))
        input_arrayQx1.append(random.randint(-10,10))
        input_arrayQx2.append(random.randint(-10,10))
        input_arrayQx3.append(random.randint(-10,10))
        input_arrayQx4.append(random.randint(-10,10))
        input_arrayIs1.append(random.randint(-10,10))
        input_arrayIs2.append(random.randint(-10,10))
        input_arrayIs3.append(random.randint(-10,10))
        input_arrayIs4.append(random.randint(-10,10))
        input_arrayQs1.append(random.randint(-10,10))
        input_arrayQs2.append(random.randint(-10,10))
        input_arrayQs3.append(random.randint(-10,10))
        input_arrayQs4.append(random.randint(-10,10))
    
    dut.en.value = 0
    await Timer(1)
    dut.clk.value = 0
    await Timer(1)
    dut.clk.value = 1
    dut.en.value = 1

    for k in range(len(input_arrayIs1)):
        dut.I_x1.value = input_arrayIx1[k]
        dut.I_x2.value = input_arrayIx2[k]
        dut.I_x3.value = input_arrayIx3[k]
        dut.I_x4.value = input_arrayIx4[k]

        dut.Q_x1.value = input_arrayQx1[k]
        dut.Q_x2.value = input_arrayQx2[k]
        dut.Q_x3.value = input_arrayQx3[k]
        dut.Q_x4.value = input_arrayQx4[k]

        dut.I_s1.value = input_arrayIs1[k]
        dut.I_s2.value = input_arrayIs2[k]
        dut.I_s3.value = input_arrayIs3[k]
        dut.I_s4.value = input_arrayIs4[k]

        dut.Q_s1.value = input_arrayQs1[k]
        dut.Q_s2.value = input_arrayQs2[k]
        dut.Q_s3.value = input_arrayQs3[k]
        dut.Q_s4.value = input_arrayQs4[k]
        
        await Timer(1)
        dut.clk.value = 0
        await Timer(1)
        dut.clk.value = 1
        
        abssqIQ = abssq_mul_model(input_arrayIx1[k], input_arrayIx2[k], input_arrayIx3[k], input_arrayIx4[k], 
                                  input_arrayQx1[k], input_arrayQx2[k], input_arrayQx3[k], input_arrayQx4[k], 
                                  input_arrayIs1[k], input_arrayIs2[k], input_arrayIs3[k], input_arrayIs4[k], 
                                  input_arrayQs1[k], input_arrayQs2[k], input_arrayQs3[k], input_arrayQs4[k])
        
        
        print(f"Expected: abssqIQ={abssqIQ}")
        logprint(f"AAAAAAAAAAAAAAresult: {dut.result_abs_sq_cmul.value.signed_integer}")
        assert abssqIQ == dut.result_abs_sq_cmul.value.signed_integer, "Expected abssqIQ"




    await Timer(2)

    #assert False, "snorre was here"
   