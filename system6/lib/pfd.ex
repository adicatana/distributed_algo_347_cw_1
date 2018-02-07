defmodule PFD do
  def start(delay) do
    receive do
      { :bind, pl, rb } ->
        receive do
          { :bind_peers, peers, process_map } ->
            Timeout.start self(), delay
            # Added a map from pfd PLs to id of the process so that
            # we can report which process crashed
            next pl, rb, peers, delay, MapSet.new(peers), MapSet.new, process_map
        end
    end
  end

  defp next pl, rb, processes, delay, alive, detected, process_map do
    receive do
      { :pl_deliver, from, :heartbeat_request } ->
        send pl, { :pl_send, from, :heartbeat_reply }
        next pl, rb, processes, delay, alive, detected, process_map
        { :pl_deliver, from, :heartbeat_reply } ->
        next pl, rb, processes, delay, MapSet.put(alive, from), detected, process_map
      { :timeout } ->
        more_detected = for p <- processes,
                        not MapSet.member?(alive, p) and
                        not MapSet.member?(detected, p),
                        do: p

        for p <- more_detected
        do
          # Get the corresponding dead process
          crashedP = Map.get(process_map, p)
          send rb, { :pfd_crash, crashedP }
        end

        for p <- alive, do: send pl, { :pl_send, p, :heartbeat_request }
        Timeout.start self(), delay
        next pl, rb, alive, delay, MapSet.new, MapSet.union(detected, MapSet.new(more_detected)), process_map
    end # receive
  end # next
end
