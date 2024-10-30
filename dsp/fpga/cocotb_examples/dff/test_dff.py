from cocotb_test.simulator import run
import pytest
import os

tests_dir = os.path.dirname(__file__)


@pytest.mark.skipif(os.getenv("SIM") in ("ghdl", "nvc"), reason="Verilog not suported")
# @pytest.mark.parametrize("seed", range(10))
def test_dff_verilog():
    run(verilog_sources=[os.path.join(tests_dir, "dff.v")], toplevel="dff", module="dff_cocotb", waves=True)


if __name__ == "__main__":
    test_dff_verilog()
