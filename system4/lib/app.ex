# Handle timeout and broadcast limit but it can't count the 
# messages sent since it's not the one sending them!
# Messages received and sent are coutned in beb and if a 
# timeout occurs the APP has to notify the beb to stop and print
# the information it has stored
defmodule App do
  def start peer_id do
    receive do
      { :bind_beb, beb } ->
        wait_peers beb, peer_id
    end
  end

  defp wait_peers beb, peer_id do
    receive do
      { :bind_peers, peers } ->
        wait_broadcast beb, peers, peer_id
    end
  end

  defp wait_broadcast beb, peers, peer_id do
    receive do
      { :broadcast, broadcasts_left, timeout } ->
        :timer.send_after(timeout, { :timeout })   
        msg_report = Map.new(peers, fn peer ->
          {peer, {0, 0}}
        end)
        broadcast beb, peers, msg_report, broadcasts_left, peer_id
    end
  end

  def broadcast beb, peers, msg_report, broadcasts_left, peer_id do
    if broadcasts_left > 0 do
      send beb, { :beb_broadcast }
      next beb, peers, msg_report, broadcasts_left - 1, peer_id
    end
    next beb, peers, msg_report, broadcasts_left, peer_id
  end

  def next beb, peers, msg_report, broadcasts_left, peer_id do
    receive do
      { :timeout } ->
        send beb, { :timeout }
        printResults peers, msg_report, peer_id
      { :beb_deliver, from } ->
        msg_report = Map.update(msg_report, from, {0, 0}, fn {x, y} -> {x, y + 1} end)
        broadcast beb, peers, msg_report, broadcasts_left, peer_id
      { :beb_send, to } ->
        msg_report = Map.update(msg_report, to, {0, 0}, fn {x, y} -> {x + 1, y} end)
        next beb, peers, msg_report, broadcasts_left, peer_id
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
