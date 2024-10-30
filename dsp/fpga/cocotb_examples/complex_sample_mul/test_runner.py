from cocotb_test.simulator import run
import pytest
import os

tests_dir = os.path.dirname(__file__)


@pytest.mark.skipif(os.getenv("SIM") in ("ghdl", "nvc"), reason="Verilog not suported")
# @pytest.mark.parametrize("seed", range(10))
def test_complex_sample_mul():
    run(verilog_sources=[os.path.join(tests_dir, "complex_sample_mul.v")], toplevel="complex_sample_mul", module="tb_complex_sample_mul", waves=True)


if __name__ == "__main__":
    test_complex_sample_mul()
