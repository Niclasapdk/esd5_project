import cocotb
from cocotb.triggers import Timer

def logprint(msg):
    print(f"FROM_TB {msg}")

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

@cocotb.test()
async def complex_sample_mul_test(dut):
    """test for multiplication using the complex_sample_mul task"""
    Ix = [1, 2, 3, 4]
    Qx = [6, 2, 1, 4]
    Is = [8, 1, 2, 6]
    Qs = [8, 1, 5, 1]
    dut.I_x1.value = Ix[0]
    dut.I_x2.value = Ix[1]
    dut.I_x3.value = Ix[2]
    dut.I_x4.value = Ix[3]
    dut.Q_x1.value = Qx[0]
    dut.Q_x2.value = Qx[1]
    dut.Q_x3.value = Qx[2]
    dut.Q_x4.value = Qx[3]
    dut.I_s1.value = Is[0]
    dut.I_s2.value = Is[1]
    dut.I_s3.value = Is[2]
    dut.I_s4.value = Is[3]
    dut.Q_s1.value = Qs[0]
    dut.Q_s2.value = Qs[1]
    dut.Q_s3.value = Qs[2]
    dut.Q_s4.value = Qs[3]

    await Timer(2)
    I_e, Q_e = mul_model(Ix, Qx, Is, Qs)
    logprint(f"I_y: {dut.I_y.value}")
    assert I_e == dut.I_y.value, "Expected I value"
    assert Q_e == dut.Q_y.value, "Expected Q value"
    await Timer(2)