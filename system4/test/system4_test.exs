defmodule System4Test do
  use ExUnit.Case
  doctest System4

  test "greets the world" do
    assert System4.hello() == :world
  end
end
