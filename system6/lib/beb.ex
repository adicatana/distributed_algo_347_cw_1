defmodule Beb do
  def main do
    receive do
      {:bind, pl, rb} ->
        receive do
          {:bind_peers, peers} ->
            next pl, peers, rb
        end
    end
  end

  defp next(pl, peers, rb) do
    receive do
      {:death} ->
        send rb, {:death}
        exit(:kill)
      {:timeout} ->
        exit(:normal)
      {:pl_deliver, from, msg} ->
        send rb, {:beb_deliver, from, msg}
        next(pl, peers, rb)
      {:beb_broadcast, msg} -> broadcast(pl, peers, rb, msg)
    end
  end

  # Broadcast while still receiving messages and checking for timeout
  defp broadcast(pl, peers, rb, msg) do
    Enum.each(peers, fn peer ->
      receive do
        {:death} ->
          send rb, {:death}
          exit(:normal)
        {:timeout} ->
          exit(:normal)
      after
        0 -> 0
      end

      receive do
          {:pl_deliver, from, msg} ->
            send rb, {:beb_deliver, from, msg}
      after
        0 -> :noop
      end

      send pl, {:pl_send, peer, msg}
      send rb, {:beb_send, peer}
    end)
    next(pl, peers, app)
  end
end
