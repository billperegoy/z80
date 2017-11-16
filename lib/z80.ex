defmodule Z80 do
  @moduledoc """
  Documentation for Z80.
  """

  def run do
    {:ok, rom_contents} = File.read("/Users/bill/Projects/z80/lib/level1.rom")
    Rom.fetch(rom_contents)
  end
end

