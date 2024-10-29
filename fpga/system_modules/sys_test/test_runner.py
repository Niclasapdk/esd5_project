from cocotb_test.simulator import run
import pytest
import os

tests_dir = os.path.dirname(__file__)


@pytest.mark.skipif(os.getenv("SIM") in ("ghdl", "nvc"), reason="Verilog not suported")
# @pytest.mark.parametrize("seed", range(10))
def test_top():
    run(verilog_sources=[os.path.join(tests_dir, "top.v"),
                         os.path.join(tests_dir, "abs_sq_cmul.v"),
                         os.path.join(tests_dir, "ma.v")], 
                         toplevel="top", 
                         module = "tb_top",
                         waves=True)


if __name__ == "__main__":
    test_top()
