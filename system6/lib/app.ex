# Handle timeout and broadcast limit but it can't count the messages sent since it's not the one sending them!
# Messages received and sent are coutned in beb and if a timeout occurs the App has to notify the beb to stop and print
# the information it has stored
defmodule App do
  def start peer_id do
    receive do
      { :bind, rb } ->
        wait_pls rb, peer_id
    end
  end

  defp wait_pls rb, peer_id do
    receive do
      { :bind_peers, peers } ->
        wait_broadcast rb, peers, peer_id
    end
  end

  defp wait_broadcast rb, peers, peer_id do
    receive do
      { :broadcast, broadcasts_left, timeout } ->
        app_id = self()
        spawn fn -> Timeout.start app_id, timeout end
        msg_report = Map.new(peers, fn peer ->
          {peer, {0, 0}}
        end)
        broadcast rb, peers, msg_report, broadcasts_left, peer_id
    end
  end

  defp broadcast rb, peers, msg_report, broadcasts_left, peer_id do
    if broadcasts_left > 0 do
      # include pid and sequence number so that it's unique?
      send rb, { :rb_broadcast, "#{inspect self()}-#{broadcasts_left}" } 
      # As far as the app is concerned, messages were broadcast
      msg_report = Enum.reduce(peers, msg_report, fn peer, acc ->
        Map.update(acc, peer, {0,0}, fn {x, y} -> {x + 1, y} end)
      end)

      next rb, peers, msg_report, broadcasts_left - 1, peer_id
    end
    next rb, peers, msg_report, broadcasts_left, peer_id
  end

  # The problem with previous approaches is that even though 
  # the death message arrives it is back in the mailbox. 
  # Therefore it takes time to pattern match it
  defp next rb, peers, msg_report, broadcasts_left, peer_id do
    # Immediately stop if any of the two messages are in mailbox
    receive do
      { :timeout } ->
        send peer_id, { :timeout }
        printResults peers, msg_report
    after
      0 ->
        receive do
          { :rb_deliver, from, msg } ->
            msg_report = Map.update(msg_report, from, {0, 0}, fn {x, y} -> {x, y + 1} end)
            broadcast rb, peers, msg_report, broadcasts_left, peer_id
        after
          0 -> next rb, peers, msg_report, broadcasts_left, peer_id
        end
    end

# We used to do this, network congestion, this is app specific
#      {:rb_send, to} ->
#        msg_report = Map.update(msg_report, to, {0, 0}, fn {x, y} -> {x + 1, y} end)
#        next beb, peers, msg_report, broadcasts_left
  end

  defp printResults peers, msg_report do
    status = Enum.reduce peers, inspect(self()), fn peer, acc ->
              "#{acc} #{inspect(Map.get(msg_report, peer))}"
            end
    IO.puts status
    exit(:normal)
  end
end
