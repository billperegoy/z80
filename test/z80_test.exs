defmodule Z80Test do
  use ExUnit.Case
  doctest Z80

  test "greets the world" do
    assert Z80.hello() == :world
  end
end
