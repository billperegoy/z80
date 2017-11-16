defmodule Z80Test do
  use ExUnit.Case
  doctest Z80

  test "NOP" do
    assert Instruction.decode(<<0x00>>) == "NOP"
  end

  test "LD BC, (23)" do
    assert Instruction.decode(<<0x01>>, <<23>>) == "LD BC, (23)"
  end

  test "LD DE, (23)" do
    assert Instruction.decode(<<0x11>>, <<23>>) == "LD DE, (23)"
  end

  test "RET" do
    assert Instruction.decode(<<0xc9>>) == "RET"
  end

  test "LD C, 23" do 
    assert Instruction.decode(<<0x0e>>, <<23::size(8)>>) == "LD C, 23"
  end

  test "LD B, 23" do 
    assert Instruction.decode(<<0x06>>, <<23::size(8)>>) == "LD B, 23"
  end
end
