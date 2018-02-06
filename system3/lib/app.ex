# Handle timeout and broadcast limit but it can't count the 
# messages sent since it's not the one sending them!
# Messages received and sent are coutned in beb and if a 
# timeout occurs the APP has to notify the beb to stop and print
# the information it has stored
defmodule App do
  def start do
    receive do
      {:bind_beb, beb} ->
        wait_peers beb
    end
  end

  defp wait_peers beb do
    receive do
      {:bind_peers, peers} ->
        wait_broadcast beb, peers
    end
  end

  defp wait_broadcast beb, peers do
    receive do
      {:broadcast, broadcasts_left, timeout} ->
        app_id = self()
        spawn fn -> Timeout.start app_id, timeout end
   
        msg_report = Map.new(peers, fn peer ->
          {peer, {0, 0}}
        end)
        broadcast beb, peers, msg_report, broadcasts_left
    end
  end

  def broadcast(beb, peers, msg_report, broadcasts_left) do
    if broadcasts_left > 0 do
      send beb, {:beb_broadcast}
      next beb, peers, msg_report, broadcasts_left - 1
    end
    next beb, peers, msg_report, broadcasts_left
  end

  def next beb, peers, msg_report, broadcasts_left do
    receive do
      {:timeout} ->
        send beb, {:timeout}
        printResults peers, msg_report
      {:beb_deliver, from} ->
        msg_report = Map.update(msg_report, from, {0, 0}, fn {x, y} -> {x, y + 1} end)
        broadcast(beb, peers, msg_report, broadcasts_left)
      {:beb_send, to} ->
        msg_report = Map.update(msg_report, to, {0, 0}, fn {x, y} -> {x + 1, y} end)
        next beb, peers, msg_report, broadcasts_left
    end
  end

  defp printResults peers, msg_report do
    status = Enum.reduce peers, inspect(self()), fn peer, acc ->
              "#{acc} #{inspect(Map.get(msg_report, peer))}"
            end
    IO.puts status
    exit(:normal)
  end
end
