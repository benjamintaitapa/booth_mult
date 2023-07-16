import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.binary import BinaryValue, BinaryRepresentation

@cocotb.test()
async def test_booth_radix4(dut):
    M = int(input("Provide M:"))
    A = int(input("Provide A:"))

    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    dut.resetn.value = 0

    dut.M.value = M
    dut.A.value = A

    await ClockCycles(dut.clk, 2)

    dut.resetn.value = 1

    await ClockCycles(dut.clk, 5)

    assert dut.product.value.signed_integer == M * A
    assert dut.valid.value == 1
