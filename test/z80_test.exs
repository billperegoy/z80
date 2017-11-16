defmodule Z80Test do
  use ExUnit.Case
  doctest Z80

  test "NOP" do
    assert Instruction.decode(<<0x00>>) == "NOP"
  end

  test "LD C, 23" do 
    assert Instruction.decode(<<0x0e>>, <<23>>) == "LD C, 23"
  end
end
