defmodule Beb do
  def main do
    receive do
      {:bind, pl, app} ->
        receive do
          {:bind_peers, peers} ->
            next pl, peers, app
        end
    end
  end

  defp next(pl, peers, app) do
    receive do
      {:timeout} -> :noop
      {:pl_deliver, from} ->
        send app, {:beb_deliver, from}
        next(pl, peers, app)
      {:beb_broadcast} -> broadcast(pl, peers, app) # We might want to add a message here
    end
  end

  # Broadcast while still receiving messages and checking for timeout
  defp broadcast(pl, peers, app) do
    Enum.each(peers, fn peer ->
      receive do
          {:timeout} -> exit(:normal)
          {:pl_deliver, from} ->
            send app, {:beb_deliver, from}
      after
        0 -> :noop
      end

      send pl, {:pl_send, peer, pl}
      send app, {:beb_send, peer}
    end)
    next(pl, peers, app)
  end
end
