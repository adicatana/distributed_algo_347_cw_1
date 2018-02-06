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
      {:timeout} ->
        exit(:normal)
    after
      0 ->
        receive do
          {:pl_deliver, from, msg} ->
            send rb, {:beb_deliver, from, msg}
            next pl, peers, rb
          {:beb_broadcast, msg} -> broadcast(pl, peers, rb, msg)
        after
          0 -> next pl, peers, rb
        end
    end
  end

  # Broadcast while still receiving messages and checking for timeout
  defp broadcast(pl, peers, rb, msg) do
    Enum.each(peers, fn peer ->
      receive do
        {:timeout} ->
          exit(:normal)
      after
        0 -> 0
      end

      send pl, {:pl_send, peer, msg}

      receive do
          {:pl_deliver, from, msg} ->
            send rb, {:beb_deliver, from, msg}
      after
        0 -> 0
      end
    end)
    next pl, peers, rb
  end
end
