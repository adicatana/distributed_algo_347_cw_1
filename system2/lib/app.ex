defmodule App do
  def start peer_id do
    receive do
      { :bind_pl, pl } ->
        receive_all_pls pl, peer_id
    end
  end

  defp receive_all_pls pl, peer_id do
    receive do
      { :bind_peers, peers } ->
        initiate_broadcast pl, peers, peer_id
    end    
  end

  defp initiate_broadcast pl, peers, peer_id do
    receive do
      { :broadcast, broadcasts_left, timeout } ->
        initialMap = Map.new(peers, fn peer ->
          {peer, {0, 0}}
        end)

        :timer.send_after(timeout, { :timeout })

        next pl, peers, initialMap, broadcasts_left, peer_id
    end
  end

  # Receiving and broadcasting messages
  defp next pl, peers, msg_report, broadcasts_left, peer_id do
    if broadcasts_left <= 0 do
      receive_all_messages peers, msg_report, peer_id
    end

    msg_report = Enum.reduce(peers, msg_report, fn peer, acc ->
      receive do
          { :timeout } ->
            printResults peers, acc, peer_id
          { :pl_deliver, pid } ->
            acc = Map.update(acc, pid, {0, 0}, fn {x, y} -> {x, y + 1} end)
      after
        # Need to check the mailbox, but do
        # not need to wait for messages/timeout      
        0 -> 0
      end

      # Broadcasting
      send pl, { :pl_send, peer, pl }
      Map.update(acc, peer, {0, 0}, fn {x, y} -> {x + 1, y} end)
    end)

    next pl, peers, msg_report, broadcasts_left - 1, peer_id
  end

  # Once there are no messages left for broadcasting,
  # just wait for other messages or timeout
  defp receive_all_messages peers, msg_report, peer_id do
    receive do
      { :timeout } ->
        printResults peers, msg_report, peer_id
      { :pl_deliver, pid } ->
        msg_report = Map.update(msg_report, pid, {0, 0}, fn {x, y} -> {x, y + 1} end)
        receive_all_messages peers, msg_report, peer_id
    end

  end

  defp printResults peers, msg_report, peer_id do
    status = Enum.reduce peers, inspect(self()), fn peer, acc ->
              "#{acc} #{inspect(Map.get(msg_report, peer))}"
            end
    IO.puts status
    send peer_id, { :timeout }
  end
end