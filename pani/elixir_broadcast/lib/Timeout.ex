defmodule Timeout do
  def start(parent, timeout) do
    receive do
    after
      timeout ->
        send parent, {:timeout}
    end
  end
end
