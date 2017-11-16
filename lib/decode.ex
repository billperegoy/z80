defmodule Decode do
  def reg8(<<7::size(3)>>), do: {:ok, "A"}
  def reg8(<<0::size(3)>>), do: {:ok, "B"}
  def reg8(<<1::size(3)>>), do: {:ok, "C"}
  def reg8(<<2::size(3)>>), do: {:ok, "D"}
  def reg8(<<3::size(3)>>), do: {:ok, "E"}
  def reg8(<<4::size(3)>>), do: {:ok, "H"}
  def reg8(<<5::size(3)>>), do: {:ok, "L"}
  def reg8(_), do: {:error, "Unknown register"}

  def reg16(<<0::size(2)>>), do: {:ok, "BC"}
  def reg16(<<1::size(2)>>), do: {:ok, "DE"}
  def reg16(<<2::size(2)>>), do: {:ok, "HL"}
  def reg16(<<3::size(2)>>), do: {:ok, "SP"}

  def cond_code(<<0x0::size(3)>>), do: "NZ"
  def cond_code(<<0x1::size(3)>>), do: "Z"
  def cond_code(<<0x2::size(3)>>), do: "NC"
  def cond_code(<<0x3::size(3)>>), do: "C"
  def cond_code(<<0x4::size(3)>>), do: "PO"
  def cond_code(<<0x5::size(3)>>), do: "PE"
  def cond_code(<<0x6::size(3)>>), do: "P"
  def cond_code(<<0x7::size(3)>>), do: "M"
end
