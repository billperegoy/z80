defmodule Rom do
  def fetch(rom), do: fetch(rom, 0)

  def fetch(<<>>, _address), do: nil

  def fetch(rom, address) do
    <<byte::8>> <> rest = rom

    if Instruction.two_byte?(<<byte::8>>) do
      <<operand::size(8)>> <> rest = rest
      Instruction.decode(address, <<byte::8>>, <<operand::8>>)
      fetch(rest, address + 2)
    else
      if Instruction.three_byte?(<<byte::8>>) do
        <<operand1::size(8)>> <> <<operand2::size(8)>> <> rest = rest
        Instruction.decode(address, <<byte::8>>, <<operand1::8>>, <<operand2::8>>)
        fetch(rest, address + 3)
      else
        Instruction.decode(address, <<byte::8>>)
        fetch(rest, address + 1)
      end
    end
  end
end
