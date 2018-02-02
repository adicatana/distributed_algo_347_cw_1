defmodule Peer do
  def main do
    receive do
      {:bind, peers} ->
        receive do
          {:broadcast, broadcasts_left, timeout} ->
            initialMap = Enum.reduce peers, %{}, fn peer, acc ->
                          Map.put acc, peer, {0, 0}
                         end
            startTime = Time.utc_now
            next peers, initialMap, broadcasts_left, timeout, startTime
        end
    end
  end

  def next peers, msg_report, broadcasts_left, timeout, startTime do
    timePassed = Time.diff(Time.utc_now(), startTime, :milliseconds)
    timeLeft = timeout - timePassed
    if timeLeft > 0 do
      # For now just interleave between sending and receiving
      if broadcasts_left > 0 do

        msg_report = Enum.reduce peers, msg_report, fn peer, acc ->
                       Map.update(acc, peer, {0, 0}, fn {x, y} -> {x + 1, y} end)
                     end

        for peer <- peers, do:
            send peer, {:msg, self()}
      end
      receive do
        {:msg, pid} ->
          msg_report = Map.update(msg_report, pid, {0, 0}, fn {x, y} -> {x, y + 1} end)
          next peers, msg_report, broadcasts_left - 1, timeout, startTime
      after
        timeLeft -> printResults peers, msg_report
      end
    end
  end

  defp printResults peers, msg_report do
    status = Enum.reduce peers, inspect(self()), fn peer, acc ->
              "#{acc} #{inspect(Map.get(msg_report, peer))}"
            end
    IO.puts status
  end
end
