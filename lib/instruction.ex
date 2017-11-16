defmodule Instruction do
  def two_byte?(<<0::size(2)>> <> <<_dest::size(3)>> <> <<0x6::size(3)>>), do: true
  def two_byte?(<<0xFE::size(8)>>), do: true
  def two_byte?(<<0xD6::size(8)>>), do: true
  def two_byte?(<<0x20::size(8)>>), do: true
  def two_byte?(<<0x28::size(8)>>), do: true
  def two_byte?(_), do: false

  def three_byte?(<<0xC3::size(8)>>), do: true
  def three_byte?(<<0xCD::size(8)>>), do: true
  def three_byte?(<<0::size(2)>> <> <<_dest::size(2)>> <> <<0x1::size(4)>>), do: true
  def three_byte?(_), do: false
end
