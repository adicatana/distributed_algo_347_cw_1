defmodule Timeout do
  def start(parent, timeout) do
    receive do
    after
      timeout ->
        IO.puts "Nooo"
        send parent, :timeout
    end
  end
end
