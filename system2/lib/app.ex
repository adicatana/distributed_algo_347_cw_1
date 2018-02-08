defmodule App do
  def main do
    receive do
      {:bind_pl, pl} ->
        receive do
          {:bind_peers, peers} ->
            receive do
              {:broadcast, broadcasts_left, timeout} ->
                initialMap = Map.new(peers, fn peer ->
                  {peer, {0, 0}}
                end)

                me = self()
                spawn fn -> Timeout.start(me, timeout) end
                next pl, peers, initialMap, broadcasts_left
            end
        end
    end
  end

# the bug is that eerythin is too damn fast
  def next pl, peers, msg_report, broadcasts_left do
    if broadcasts_left <= 0 do
      receive_all_messages(peers, msg_report)
    end

    msg_report = Enum.reduce(peers, msg_report, fn peer, acc ->
      receive do
          {:timeout} ->
            printResults peers, acc
          {:pl_deliver, pid} ->
            acc = Map.update(acc, pid, {0, 0}, fn {x, y} -> {x, y + 1} end)
      after
        0 -> :noop
      end

      send pl, {:pl_send, peer, pl}
      Map.update(acc, peer, {0, 0}, fn {x, y} -> {x + 1, y} end)
    end)

    next pl, peers, msg_report, broadcasts_left - 1
  end

  defp receive_all_messages(peers, msg_report) do
    receive do
      {:timeout} ->
        printResults peers, msg_report
      {:pl_deliver, pid} ->
        msg_report = Map.update(msg_report, pid, {110, 101}, fn {x, y} -> {x, y + 1} end)
        receive_all_messages(peers, msg_report)
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
