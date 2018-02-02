defmodule ElixirBroadcastTest do
  use ExUnit.Case
  doctest ElixirBroadcast

  test "greets the world" do
    assert ElixirBroadcast.hello() == :world
  end
end
