defmodule Beb do
  def start do
    receive do
      {:bind, pl, rb} ->
        wait_peers pl, rb
    end
  end

  defp wait_peers pl, rb do
    receive do
      {:bind_peers, peers} ->
        next pl, peers, rb
    end
  end

  defp next pl, peers, rb do
    receive do
      {:pl_deliver, from, msg} ->
        send rb, {:beb_deliver, from, msg}
        next pl, peers, rb
      {:beb_broadcast, msg} ->
        broadcast pl, peers, rb, msg
    end
  end

  # Broadcast while still receiving messages and checking for timeout
  defp broadcast pl, peers, rb, msg do
    Enum.each(peers, fn peer ->
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
