defmodule System3Test do
  use ExUnit.Case
  doctest System3

  test "greets the world" do
    assert System3.hello() == :world
  end
end
