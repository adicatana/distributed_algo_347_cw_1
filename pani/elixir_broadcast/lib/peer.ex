defmodule Peer do
  def main do
    receive do
      {:bind, peers} ->
        receive do
          {:broadcast, broadcasts_left, timeout} ->
            initialMap = Map.new(peers, fn peer ->
              {peer, {0, 0}}
            end)

            spawn fn -> Timeout.start(self(), timeout) end
            next peers, initialMap, broadcasts_left
        end
    end
  end

  def next peers, msg_report, broadcasts_left do
    if broadcasts_left <= 0 do
      receive_all_messages(peers, msg_report)
    end

    msg_report = Enum.reduce(peers, msg_report, fn peer, acc ->
      receive do
          {:timeout} ->
            printResults peers, acc
          {:msg, pid} ->
            #Process.sleep(10)
            acc = Map.update(acc, pid, {0, 0}, fn {x, y} -> {x, y + 1} end)
      after
        0 -> :noop
      end

      send peer, {:msg, self()}
      Map.update(acc, peer, {0, 0}, fn {x, y} -> {x + 1, y} end)
    end)

    next peers, msg_report, broadcasts_left - 1
  end

  defp receive_all_messages(peers, msg_report) do
    receive do
      {:timeout}  ->
        printResults peers, msg_report
      {:msg, pid} ->
        #Process.sleep(10)
        msg_report = Map.update(msg_report, pid, {0, 0}, fn {x, y} -> {x, y + 1} end)
        receive_all_messages(peers, msg_report)
    after
      0 ->
        #IO.puts("3")

        printResults peers, msg_report
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
