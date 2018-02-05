defmodule System5Test do
  use ExUnit.Case
  doctest System5

  test "greets the world" do
    assert System5.hello() == :world
  end
end
