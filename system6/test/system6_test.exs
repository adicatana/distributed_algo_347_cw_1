defmodule System6Test do
  use ExUnit.Case
  doctest System6

  test "greets the world" do
    assert System6.hello() == :world
  end
end
