import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_booth_radix4(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    dut.resetn.value = 0

    dut.M.value = 6
    dut.A.value = 5

    await ClockCycles(dut.clk, 2)

    dut.resetn.value = 1

    await ClockCycles(dut.clk, 5)

    assert dut.product.value == 30
    assert dut.valid.value == 1
