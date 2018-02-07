defmodule Peer do
  def start do
    receive do
      { :bind, peers } ->
        wait_broadcast peers
    end
  end

  defp wait_broadcast peers do
    receive do
      { :broadcast, broadcasts_left, timeout } ->
        initialMap = Map.new(peers, fn peer ->
          {peer, {0, 0}}
        end)

        parent_id = self()
        :timer.send_after(timeout, { :timeout })
        next peers, initialMap, broadcasts_left
    end
  end

  # Receiving and broadcasting messages
  defp next peers, msg_report, broadcasts_left do
    if broadcasts_left <= 0 do
      receive_all_messages(peers, msg_report)
    end

    msg_report = Enum.reduce(peers, msg_report, fn peer, acc ->
      receive do
        { :timeout } ->
          printResults peers, acc
      after
        0 ->
          receive do 
            { :msg, pid } ->
              acc = Map.update(acc, pid, {0, 0}, fn {x, y} -> {x, y + 1} end)
          after
            # Need to check the mailbox, but do
            # not need to wait for messages/timeout
            0 -> 0
          end
      end

      # Broadcasting
      send peer, { :msg, self() }
      Map.update(acc, peer, {0, 0}, fn {x, y} -> {x + 1, y} end)
    end)

    next peers, msg_report, broadcasts_left - 1
  end

  # Once there are no messages left for broadcasting,
  # just wait for other messages or timeout
  defp receive_all_messages peers, msg_report do
    receive do
      { :timeout } ->
        printResults peers, msg_report
    after
      0 ->
        receive do 
          { :msg, pid } ->
            msg_report = Map.update(msg_report, pid, {0, 0}, fn {x, y} -> {x, y + 1} end)
            receive_all_messages peers, msg_report
        after
          0 -> receive_all_messages peers, msg_report
        end
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
