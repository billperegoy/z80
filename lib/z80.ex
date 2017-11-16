defmodule Z80 do
  @moduledoc """
  Documentation for Z80.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Z80.hello
      :world

  """
  def hello do
    :world
  end
end

{:ok, rom} = File.read("/Users/bill/Projects/z80/lib/level1.rom")
Rom.extract(rom)
